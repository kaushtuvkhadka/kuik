#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtCore/QUrl>
#include "archiveapi.h"
#include "accountmanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("KUik");
    app.setApplicationVersion("1.0");

    // Create the Internet Archive API backend
    // This single instance is shared across all QML pages
    ArchiveAPI api;

    // Create the account manager backend for signup/login
    // This single instance is shared across Signup.qml and Login.qml
    AccountManager accountManager;

    QQmlApplicationEngine engine;

    // Register as a context property so QML can access it as "archiveApi"
    // Any QML file can call:  archiveApi.fetchCurated()  etc.
    engine.rootContext()->setContextProperty("archiveApi", &api);

    // Register as "accountManager" so QML can call:
    // accountManager.signup(username, password), accountManager.login(...), etc.
    engine.rootContext()->setContextProperty("accountManager", &accountManager);

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
