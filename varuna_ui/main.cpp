/*
 ═ ═*═════════════════════════════════════════════════════════════
 FILE: main.cpp
 PHASE: Phase 7 - Communication and Control Features
 LOCATION: varuna_ui/main.cpp
 ═══════════════════════════════════════════════════════════════
 */

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QDebug>
#include "Backend.h"
#include "CommandHandler.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Set application metadata
    app.setOrganizationName("CWC");
    app.setOrganizationDomain("cwc.gov.in");
    app.setApplicationName("Varuna UI");
    app.setApplicationVersion("1.0.0");

    // Create backend instances
    Backend backend;
    CommandHandler commandHandler;

    QQmlApplicationEngine engine;

    // Expose backend and command handler to QML
    engine.rootContext()->setContextProperty("backend", &backend);
    engine.rootContext()->setContextProperty("commandHandler", &commandHandler);

    // Set base URL for QML imports
    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));

    // Load main QML file
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl) {
                qCritical() << "Failed to load main.qml";
                QCoreApplication::exit(-1);
            }
        },
        Qt::QueuedConnection
    );

    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "No root objects found in QML engine";
        return -1;
    }

    qInfo() << "Varuna UI started successfully";

    // Start backend monitoring
    backend.startMonitoring();

    return app.exec();
}

/*
 ═ ═*═════════════════════════════════════════════════════════════
 END OF FILE: main.cpp
 ═══════════════════════════════════════════════════════════════
 */
