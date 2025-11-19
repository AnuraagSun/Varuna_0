/*
 ═ ═*═════════════════════════════════════════════════════════════
 FILE: src/backend/Backend.h (FIX)
 PHASE: Phase 4 - Backend Integration (C++/Python Bridge)
 LOCATION: varuna_ui/src/backend/Backend.h
 ═══════════════════════════════════════════════════════════════
 */

#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QProcess>
#include <QTimer>
#include <QJsonObject>
#include <QJsonDocument>
#include <QString>
#include <QVariantMap>

class Backend : public QObject
{
    Q_OBJECT

    // Water level data
    Q_PROPERTY(qreal waterLevel READ waterLevel NOTIFY waterLevelChanged)
    Q_PROPERTY(qreal rateOfChange READ rateOfChange NOTIFY rateOfChangeChanged)

    // MPU-6050 data
    Q_PROPERTY(qreal mpuAngle READ mpuAngle NOTIFY mpuAngleChanged)
    Q_PROPERTY(qreal mpuWaterLevel READ mpuWaterLevel NOTIFY mpuWaterLevelChanged)
    Q_PROPERTY(QString mpuStatus READ mpuStatus NOTIFY mpuStatusChanged)

    // DHT22 data (if available)
    Q_PROPERTY(qreal temperature READ temperature NOTIFY temperatureChanged)
    Q_PROPERTY(qreal humidity READ humidity NOTIFY humidityChanged)
    Q_PROPERTY(QString dhtStatus READ dhtStatus NOTIFY dhtStatusChanged)

    // Ultrasonic data (placeholder for HC-SR04)
    Q_PROPERTY(qreal ultrasonicDistance READ ultrasonicDistance NOTIFY ultrasonicDistanceChanged)
    Q_PROPERTY(qreal ultrasonicWaterLevel READ ultrasonicWaterLevel NOTIFY ultrasonicWaterLevelChanged)
    Q_PROPERTY(QString ultrasonicStatus READ ultrasonicStatus NOTIFY ultrasonicStatusChanged)

    // Pressure sensor data (placeholder for MS5837)
    Q_PROPERTY(qreal pressureValue READ pressureValue NOTIFY pressureValueChanged)
    Q_PROPERTY(qreal pressureWaterLevel READ pressureWaterLevel NOTIFY pressureWaterLevelChanged)
    Q_PROPERTY(QString pressureStatus READ pressureStatus NOTIFY pressureStatusChanged)

    // System stats
    Q_PROPERTY(int batteryLevel READ batteryLevel NOTIFY batteryLevelChanged)
    Q_PROPERTY(bool isCharging READ isCharging NOTIFY isChargingChanged)
    Q_PROPERTY(int signalStrength READ signalStrength NOTIFY signalStrengthChanged)
    Q_PROPERTY(int uptime READ uptime NOTIFY uptimeChanged)
    Q_PROPERTY(int cpuTemp READ cpuTemp NOTIFY cpuTempChanged)
    Q_PROPERTY(QString operatingMode READ operatingMode NOTIFY operatingModeChanged)

    // Device info
    Q_PROPERTY(bool isOnline READ isOnline NOTIFY isOnlineChanged)
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)

public:
    explicit Backend(QObject *parent = nullptr);
    ~Backend();

    // Property getters
    qreal waterLevel() const { return m_waterLevel; }
    qreal rateOfChange() const { return m_rateOfChange; }

    qreal mpuAngle() const { return m_mpuAngle; }
    qreal mpuWaterLevel() const { return m_mpuWaterLevel; }
    QString mpuStatus() const { return m_mpuStatus; }

    qreal temperature() const { return m_temperature; }
    qreal humidity() const { return m_humidity; }
    QString dhtStatus() const { return m_dhtStatus; }

    qreal ultrasonicDistance() const { return m_ultrasonicDistance; }
    qreal ultrasonicWaterLevel() const { return m_ultrasonicWaterLevel; }
    QString ultrasonicStatus() const { return m_ultrasonicStatus; }

    qreal pressureValue() const { return m_pressureValue; }
    qreal pressureWaterLevel() const { return m_pressureWaterLevel; }
    QString pressureStatus() const { return m_pressureStatus; }

    int batteryLevel() const { return m_batteryLevel; }
    bool isCharging() const { return m_isCharging; }
    int signalStrength() const { return m_signalStrength; }
    int uptime() const { return m_uptime; }
    int cpuTemp() const { return m_cpuTemp; }
    QString operatingMode() const { return m_operatingMode; }

    bool isOnline() const { return m_isOnline; }
    QString lastError() const { return m_lastError; }

public slots:
    void startMonitoring();
    void stopMonitoring();
    void refreshData();
    void setUpdateInterval(int milliseconds);

signals:
    // Property change signals
    void waterLevelChanged();
    void rateOfChangeChanged();
    void mpuAngleChanged();
    void mpuWaterLevelChanged();
    void mpuStatusChanged();
    void temperatureChanged();
    void humidityChanged();
    void dhtStatusChanged();
    void ultrasonicDistanceChanged();
    void ultrasonicWaterLevelChanged();
    void ultrasonicStatusChanged();
    void pressureValueChanged();
    void pressureWaterLevelChanged();
    void pressureStatusChanged();
    void batteryLevelChanged();
    void isChargingChanged();
    void signalStrengthChanged();
    void uptimeChanged();
    void cpuTempChanged();
    void operatingModeChanged();
    void isOnlineChanged();
    void lastErrorChanged();

    // Event signals
    void dataUpdated();
    void errorOccurred(const QString &error);

private slots:
    void readSensorData();
    void handleProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void handleProcessError(QProcess::ProcessError error);
    void updateSystemStats();

private:
    void parseJsonData(const QByteArray &data);
    void calculateRateOfChange();
    void updateOperatingMode();
    qreal readCpuTemperature();
    int readBatteryLevel();
    void useFallbackData();  // FIX: Added declaration

    // Data members
    qreal m_waterLevel;
    qreal m_rateOfChange;
    qreal m_previousWaterLevel;
    QDateTime m_lastReadingTime;

    qreal m_mpuAngle;
    qreal m_mpuWaterLevel;
    QString m_mpuStatus;

    qreal m_temperature;
    qreal m_humidity;
    QString m_dhtStatus;

    qreal m_ultrasonicDistance;
    qreal m_ultrasonicWaterLevel;
    QString m_ultrasonicStatus;

    qreal m_pressureValue;
    qreal m_pressureWaterLevel;
    QString m_pressureStatus;

    int m_batteryLevel;
    bool m_isCharging;
    int m_signalStrength;
    int m_uptime;
    int m_cpuTemp;
    QString m_operatingMode;

    bool m_isOnline;
    QString m_lastError;

    // Process management
    QProcess *m_sensorProcess;
    QTimer *m_updateTimer;
    QTimer *m_statsTimer;
    QString m_pythonScriptPath;
    int m_updateInterval;
    QDateTime m_startTime;
};

#endif // BACKEND_H

/*
 ═ ═*═════════════════════════════════════════════════════════════
 END OF FILE: src/backend/Backend.h
 ═══════════════════════════════════════════════════════════════
 */
