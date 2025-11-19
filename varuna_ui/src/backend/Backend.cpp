/*
 ═ ═*═════════════════════════════════════════════════════════════
 FILE: src/backend/Backend.cpp (FIX - qrand replacement)
 PHASE: Phase 4 - Backend Integration (C++/Python Bridge)
 LOCATION: varuna_ui/src/backend/Backend.cpp
 ═══════════════════════════════════════════════════════════════
 */

#include "Backend.h"
#include <QDebug>
#include <QJsonArray>
#include <QJsonParseError>
#include <QFile>
#include <QDir>
#include <QCoreApplication>
#include <QDateTime>
#include <QProcess>
#include <QRandomGenerator>  // FIX: Added for random number generation

Backend::Backend(QObject *parent)
: QObject(parent)
, m_waterLevel(0.0)
, m_rateOfChange(0.0)
, m_previousWaterLevel(0.0)
, m_mpuAngle(0.0)
, m_mpuWaterLevel(0.0)
, m_mpuStatus("UNKNOWN")
, m_temperature(0.0)
, m_humidity(0.0)
, m_dhtStatus("UNKNOWN")
, m_ultrasonicDistance(0.0)
, m_ultrasonicWaterLevel(0.0)
, m_ultrasonicStatus("UNKNOWN")
, m_pressureValue(0.0)
, m_pressureWaterLevel(0.0)
, m_pressureStatus("UNKNOWN")
, m_batteryLevel(0)
, m_isCharging(false)
, m_signalStrength(-99)
, m_uptime(0)
, m_cpuTemp(0)
, m_operatingMode("NORMAL")
, m_isOnline(false)
, m_updateInterval(60000)
{
    qDebug() << "Backend: Initializing...";

    // Initialize process
    m_sensorProcess = new QProcess(this);
    connect(m_sensorProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &Backend::handleProcessFinished);
    connect(m_sensorProcess, &QProcess::errorOccurred,
            this, &Backend::handleProcessError);

    // Set Python script path
    QString appPath = QCoreApplication::applicationDirPath();
    m_pythonScriptPath = QDir(appPath).filePath("../python/scripts/read_sensors.py");

    qDebug() << "Backend: Python script path:" << m_pythonScriptPath;

    // Initialize update timer
    m_updateTimer = new QTimer(this);
    connect(m_updateTimer, &QTimer::timeout, this, &Backend::readSensorData);

    // Initialize system stats timer (update every 5 seconds)
    m_statsTimer = new QTimer(this);
    connect(m_statsTimer, &QTimer::timeout, this, &Backend::updateSystemStats);
    m_statsTimer->start(5000);

    // Record start time
    m_startTime = QDateTime::currentDateTime();

    qDebug() << "Backend: Initialized successfully";
}

Backend::~Backend()
{
    stopMonitoring();
    if (m_sensorProcess) {
        m_sensorProcess->kill();
        m_sensorProcess->waitForFinished(1000);
    }
}

void Backend::startMonitoring()
{
    qDebug() << "Backend: Starting monitoring with interval:" << m_updateInterval << "ms";

    m_isOnline = true;
    emit isOnlineChanged();

    // Start timers
    m_updateTimer->start(m_updateInterval);

    // Do initial read
    readSensorData();
}

void Backend::stopMonitoring()
{
    qDebug() << "Backend: Stopping monitoring";

    m_updateTimer->stop();
    m_isOnline = false;
    emit isOnlineChanged();
}

void Backend::refreshData()
{
    qDebug() << "Backend: Manual refresh requested";
    readSensorData();
}

void Backend::setUpdateInterval(int milliseconds)
{
    if (milliseconds < 1000) {
        milliseconds = 1000;  // Minimum 1 second
    }

    m_updateInterval = milliseconds;

    if (m_updateTimer->isActive()) {
        m_updateTimer->setInterval(m_updateInterval);
    }

    qDebug() << "Backend: Update interval set to" << m_updateInterval << "ms";
}

void Backend::readSensorData()
{
    if (m_sensorProcess->state() != QProcess::NotRunning) {
        qWarning() << "Backend: Previous sensor read still running, skipping";
        return;
    }

    // Check if Python script exists
    if (!QFile::exists(m_pythonScriptPath)) {
        QString error = QString("Python script not found: %1").arg(m_pythonScriptPath);
        qWarning() << "Backend:" << error;
        m_lastError = error;
        emit lastErrorChanged();
        emit errorOccurred(error);

        // Use fallback simulated data
        useFallbackData();
        return;
    }

    qDebug() << "Backend: Executing Python script:" << m_pythonScriptPath;

    // Execute Python script
    m_sensorProcess->start("python3", QStringList() << m_pythonScriptPath);
}

void Backend::handleProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    if (exitStatus != QProcess::NormalExit || exitCode != 0) {
        QString error = QString("Python script failed with exit code %1: %2")
        .arg(exitCode)
        .arg(QString(m_sensorProcess->readAllStandardError()));
        qWarning() << "Backend:" << error;
        m_lastError = error;
        emit lastErrorChanged();
        emit errorOccurred(error);

        // Use fallback simulated data
        useFallbackData();
        return;
    }

    // Read output
    QByteArray output = m_sensorProcess->readAllStandardOutput();
    qDebug() << "Backend: Received data:" << output;

    // Parse JSON
    parseJsonData(output);
}

void Backend::handleProcessError(QProcess::ProcessError error)
{
    QString errorString;
    switch (error) {
        case QProcess::FailedToStart:
            errorString = "Failed to start Python script (python3 not found?)";
            break;
        case QProcess::Crashed:
            errorString = "Python script crashed";
            break;
        case QProcess::Timedout:
            errorString = "Python script timed out";
            break;
        default:
            errorString = "Unknown process error";
            break;
    }

    qWarning() << "Backend: Process error:" << errorString;
    m_lastError = errorString;
    emit lastErrorChanged();
    emit errorOccurred(errorString);

    // Use fallback simulated data
    useFallbackData();
}

void Backend::parseJsonData(const QByteArray &data)
{
    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        QString error = QString("JSON parse error: %1").arg(parseError.errorString());
        qWarning() << "Backend:" << error;
        m_lastError = error;
        emit lastErrorChanged();
        emit errorOccurred(error);
        return;
    }

    QJsonObject root = doc.object();

    // Update timestamp for rate calculation
    QDateTime now = QDateTime::currentDateTime();
    if (!m_lastReadingTime.isNull()) {
        qint64 timeDiff = m_lastReadingTime.msecsTo(now);
        if (timeDiff > 0) {
            calculateRateOfChange();
        }
    }
    m_lastReadingTime = now;

    // Parse MPU6050 data
    if (root.contains("mpu6050")) {
        QJsonObject mpu = root["mpu6050"].toObject();

        qreal newAngle = mpu["pitch_angle"].toDouble(0.0);
        qreal newWaterLevel = mpu["water_level_cm"].toDouble(0.0);
        QString newStatus = mpu["status"].toString("UNKNOWN");

        if (qAbs(m_mpuAngle - newAngle) > 0.01) {
            m_mpuAngle = newAngle;
            emit mpuAngleChanged();
        }

        if (qAbs(m_mpuWaterLevel - newWaterLevel) > 0.01) {
            m_previousWaterLevel = m_mpuWaterLevel;
            m_mpuWaterLevel = newWaterLevel;
            emit mpuWaterLevelChanged();
        }

        if (m_mpuStatus != newStatus) {
            m_mpuStatus = newStatus;
            emit mpuStatusChanged();
        }
    }

    // Parse DHT22 data
    if (root.contains("dht22")) {
        QJsonObject dht = root["dht22"].toObject();

        qreal newTemp = dht["temperature"].toDouble(0.0);
        qreal newHumidity = dht["humidity"].toDouble(0.0);
        QString newStatus = dht["status"].toString("UNKNOWN");

        if (qAbs(m_temperature - newTemp) > 0.1) {
            m_temperature = newTemp;
            emit temperatureChanged();
        }

        if (qAbs(m_humidity - newHumidity) > 0.1) {
            m_humidity = newHumidity;
            emit humidityChanged();
        }

        if (m_dhtStatus != newStatus) {
            m_dhtStatus = newStatus;
            emit dhtStatusChanged();
        }
    }

    // Parse consensus water level
    if (root.contains("consensus_level_cm")) {
        qreal newLevel = root["consensus_level_cm"].toDouble(0.0);

        if (qAbs(m_waterLevel - newLevel) > 0.01) {
            m_waterLevel = newLevel;
            emit waterLevelChanged();
        }
    }

    // Parse rate of change if provided
    if (root.contains("rate_of_change_cm_per_hour")) {
        qreal newRate = root["rate_of_change_cm_per_hour"].toDouble(0.0);

        if (qAbs(m_rateOfChange - newRate) > 0.01) {
            m_rateOfChange = newRate;
            emit rateOfChangeChanged();
        }
    }

    // Update operating mode based on readings
    updateOperatingMode();

    // Clear error if successful
    if (!m_lastError.isEmpty()) {
        m_lastError.clear();
        emit lastErrorChanged();
    }

    emit dataUpdated();
}

void Backend::calculateRateOfChange()
{
    if (m_previousWaterLevel == 0.0) {
        return;
    }

    qint64 timeDiff = m_lastReadingTime.msecsTo(QDateTime::currentDateTime());
    if (timeDiff <= 0) {
        return;
    }

    qreal levelDiff = m_mpuWaterLevel - m_previousWaterLevel;
    qreal hours = timeDiff / 3600000.0;  // Convert ms to hours

    qreal newRate = levelDiff / hours;

    if (qAbs(m_rateOfChange - newRate) > 0.01) {
        m_rateOfChange = newRate;
        emit rateOfChangeChanged();
    }
}

void Backend::updateOperatingMode()
{
    QString newMode;

    if (m_waterLevel >= 250) {
        newMode = "CRITICAL";
    } else if (m_waterLevel >= 200 || qAbs(m_rateOfChange) > 5) {
        newMode = "FLOOD";
    } else if (m_batteryLevel < 20) {
        newMode = "LOW_POWER";
    } else {
        newMode = "NORMAL";
    }

    if (m_operatingMode != newMode) {
        m_operatingMode = newMode;
        emit operatingModeChanged();
        qDebug() << "Backend: Operating mode changed to" << newMode;
    }
}

void Backend::updateSystemStats()
{
    // Update uptime
    qint64 secondsRunning = m_startTime.secsTo(QDateTime::currentDateTime());
    int newUptime = static_cast<int>(secondsRunning / 3600);  // Convert to hours

    if (m_uptime != newUptime) {
        m_uptime = newUptime;
        emit uptimeChanged();
    }

    // Read CPU temperature
    int newTemp = static_cast<int>(readCpuTemperature());
    if (m_cpuTemp != newTemp) {
        m_cpuTemp = newTemp;
        emit cpuTempChanged();
    }

    // Read battery level (simulated for now)
    int newBattery = readBatteryLevel();
    if (m_batteryLevel != newBattery) {
        m_batteryLevel = newBattery;
        emit batteryLevelChanged();
    }
}

qreal Backend::readCpuTemperature()
{
    // Try to read from Raspberry Pi thermal zone
    QFile tempFile("/sys/class/thermal/thermal_zone0/temp");
    if (tempFile.open(QIODevice::ReadOnly)) {
        QString tempStr = tempFile.readAll().trimmed();
        tempFile.close();

        bool ok;
        int tempMilliC = tempStr.toInt(&ok);
        if (ok) {
            return tempMilliC / 1000.0;  // Convert millicelsius to celsius
        }
    }

    // Fallback: simulated value
    // FIX: Use QRandomGenerator instead of qrand()
    return 45.0 + (QRandomGenerator::global()->bounded(10));
}

int Backend::readBatteryLevel()
{
    // TODO: Implement real battery reading from hardware
    // For now, return simulated value
    static int simulatedBattery = 78;

    // Simulate charging/discharging
    // FIX: Use QRandomGenerator instead of qrand()
    if (QRandomGenerator::global()->bounded(100) < 50) {
        simulatedBattery = qMin(100, simulatedBattery + 1);
    } else {
        simulatedBattery = qMax(0, simulatedBattery - 1);
    }

    return simulatedBattery;
}

void Backend::useFallbackData()
{
    // Use simulated data when Python script fails
    qDebug() << "Backend: Using fallback simulated data";

    static qreal simWaterLevel = 145.0;

    // FIX: Use QRandomGenerator instead of qrand()
    simWaterLevel += (QRandomGenerator::global()->bounded(100) - 50) / 10.0;
    simWaterLevel = qMax(0.0, qMin(300.0, simWaterLevel));

    m_waterLevel = simWaterLevel;
    m_mpuWaterLevel = simWaterLevel + (QRandomGenerator::global()->bounded(10) - 5) / 10.0;
    m_ultrasonicWaterLevel = simWaterLevel + (QRandomGenerator::global()->bounded(10) - 5) / 10.0;
    m_pressureWaterLevel = simWaterLevel + (QRandomGenerator::global()->bounded(10) - 5) / 10.0;

    m_mpuStatus = "SIMULATED";
    m_ultrasonicStatus = "SIMULATED";
    m_pressureStatus = "SIMULATED";

    m_temperature = 25.0 + (QRandomGenerator::global()->bounded(50)) / 10.0;
    m_humidity = 60.0 + (QRandomGenerator::global()->bounded(200)) / 10.0;
    m_dhtStatus = "SIMULATED";

    emit waterLevelChanged();
    emit mpuWaterLevelChanged();
    emit mpuStatusChanged();
    emit ultrasonicWaterLevelChanged();
    emit ultrasonicStatusChanged();
    emit pressureWaterLevelChanged();
    emit pressureStatusChanged();
    emit temperatureChanged();
    emit humidityChanged();
    emit dhtStatusChanged();
    emit dataUpdated();
}

/*
 ═ ═*═════════════════════════════════════════════════════════════
 END OF FILE: src/backend/Backend.cpp
 ═══════════════════════════════════════════════════════════════
 */
