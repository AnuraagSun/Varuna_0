/*
 ═ ═*═════════════════════════════════════════════════════════════
 FILE: src/backend/CommandHandler.cpp (FIX)
 PHASE: Phase 7 - Communication and Control Features
 LOCATION: varuna_ui/src/backend/CommandHandler.cpp
 ═══════════════════════════════════════════════════════════════
 */

#include "CommandHandler.h"
#include <QDebug>
#include <QCoreApplication>
#include <QDir>
#include <QTimer>  // FIX: Added missing include

CommandHandler::CommandHandler(QObject *parent)
: QObject(parent)
, m_isBusy(false)
{
    qDebug() << "CommandHandler: Initializing...";

    // Initialize process
    m_commandProcess = new QProcess(this);
    connect(m_commandProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &CommandHandler::handleProcessFinished);
    connect(m_commandProcess, &QProcess::errorOccurred,
            this, &CommandHandler::handleProcessError);

    // Set Python script path
    QString appPath = QCoreApplication::applicationDirPath();
    m_pythonScriptPath = QDir(appPath).filePath("../python/scripts/send_sms_command.py");

    qDebug() << "CommandHandler: SMS script path:" << m_pythonScriptPath;
    qDebug() << "CommandHandler: Initialized successfully";
}

CommandHandler::~CommandHandler()
{
    if (m_commandProcess) {
        m_commandProcess->kill();
        m_commandProcess->waitForFinished(1000);
    }
}

void CommandHandler::sendSMS(const QString &phoneNumber, const QString &message)
{
    if (m_isBusy) {
        qWarning() << "CommandHandler: Busy, cannot send SMS";
        emit smsSent(phoneNumber, false);
        return;
    }

    qDebug() << "CommandHandler: Sending SMS to" << phoneNumber;
    qDebug() << "CommandHandler: Message:" << message;

    m_isBusy = true;
    emit isBusyChanged();

    m_lastCommand = QString("SMS to %1: %2").arg(phoneNumber, message);
    emit lastCommandChanged();

    m_currentPhoneNumber = phoneNumber;

    // Execute Python script
    QStringList arguments;
    arguments << m_pythonScriptPath << phoneNumber << message;

    m_commandProcess->start("python3", arguments);
}

void CommandHandler::executeCommand(const QString &command)
{
    if (m_isBusy) {
        qWarning() << "CommandHandler: Busy, cannot execute command";
        emit commandExecuted(command, false);
        return;
    }

    qDebug() << "CommandHandler: Executing command:" << command;

    m_isBusy = true;
    emit isBusyChanged();

    m_lastCommand = command;
    emit lastCommandChanged();

    // For now, just log the command
    // In production, this would trigger specific actions based on command type
    m_lastResponse = QString("Command '%1' queued for execution").arg(command);
    emit lastResponseChanged();

    // Simulate execution
    QTimer::singleShot(1000, this, [this, command]() {
        m_isBusy = false;
        emit isBusyChanged();
        emit commandExecuted(command, true);
    });
}

void CommandHandler::handleProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    m_isBusy = false;
    emit isBusyChanged();

    if (exitStatus == QProcess::NormalExit && exitCode == 0) {
        QString output = m_commandProcess->readAllStandardOutput();
        QString error = m_commandProcess->readAllStandardError();

        qDebug() << "CommandHandler: SMS sent successfully";
        qDebug() << "CommandHandler: Output:" << output;
        qDebug() << "CommandHandler: Error:" << error;

        m_lastResponse = "SMS sent successfully";
        emit lastResponseChanged();
        emit smsSent(m_currentPhoneNumber, true);
    } else {
        QString error = m_commandProcess->readAllStandardError();
        qWarning() << "CommandHandler: SMS failed with exit code" << exitCode;
        qWarning() << "CommandHandler: Error:" << error;

        m_lastResponse = QString("SMS failed: %1").arg(error);
        emit lastResponseChanged();
        emit smsSent(m_currentPhoneNumber, false);
    }
}

void CommandHandler::handleProcessError(QProcess::ProcessError error)
{
    m_isBusy = false;
    emit isBusyChanged();

    QString errorString = m_commandProcess->errorString();
    qWarning() << "CommandHandler: Process error:" << errorString;

    m_lastResponse = QString("Error: %1").arg(errorString);
    emit lastResponseChanged();
    emit smsSent(m_currentPhoneNumber, false);
}

/*
 ═ ═*═════════════════════════════════════════════════════════════
 END OF FILE: src/backend/CommandHandler.cpp
 ═══════════════════════════════════════════════════════════════
 */
