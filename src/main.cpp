#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtCore/QUrl>
#include <QQmlContext>          // ✅ add this
#include "InternetArchive.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("KUik");
    app.setApplicationVersion("1.0");

    QQmlApplicationEngine engine;

    InternetArchive api;        // ✅ create the object
    engine.rootContext()->setContextProperty("InternetArchive", &api);  // ✅ expose to QML

    const QUrl url(QStringLiteral("qrc:/qt/qml/KUik/qml/Main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection
        );
    engine.load(url);
    return app.exec();
}