/*
 ═ ═*═════════════════════════════════════════════════════════════
 FILE: src/backend/CommandHandler.h (FIX)
 PHASE: Phase 7 - Communication and Control Features
 LOCATION: varuna_ui/src/backend/CommandHandler.h
 ═══════════════════════════════════════════════════════════════
 */

#ifndef COMMANDHANDLER_H
#define COMMANDHANDLER_H

#include <QObject>
#include <QString>
#include <QProcess>
#include <QDateTime>

class CommandHandler : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString lastCommand READ lastCommand NOTIFY lastCommandChanged)
    Q_PROPERTY(QString lastResponse READ lastResponse NOTIFY lastResponseChanged)
    Q_PROPERTY(bool isBusy READ isBusy NOTIFY isBusyChanged)

public:
    explicit CommandHandler(QObject *parent = nullptr);
    ~CommandHandler();

    QString lastCommand() const { return m_lastCommand; }
    QString lastResponse() const { return m_lastResponse; }
    bool isBusy() const { return m_isBusy; }

public slots:
    void sendSMS(const QString &phoneNumber, const QString &message);
    void executeCommand(const QString &command);

signals:
    void lastCommandChanged();
    void lastResponseChanged();
    void isBusyChanged();
    void commandExecuted(const QString &command, bool success);
    void smsSent(const QString &phoneNumber, bool success);  // FIX: Changed from smsent to smsSent

private slots:
    void handleProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void handleProcessError(QProcess::ProcessError error);

private:
    QString m_lastCommand;
    QString m_lastResponse;
    bool m_isBusy;

    QProcess *m_commandProcess;
    QString m_pythonScriptPath;
    QString m_currentPhoneNumber;
};

#endif // COMMANDHANDLER_H

/*
 ═ ═*═════════════════════════════════════════════════════════════
 END OF FILE: src/backend/CommandHandler.h
 ═══════════════════════════════════════════════════════════════
 */
