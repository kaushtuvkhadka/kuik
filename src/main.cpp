#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtCore/QUrl>
#include "archiveapi.h"
#include "accountmanager.h"
#include "watchhistorymanager.h"
//*+*+*+*+*+ Include TMDB API backend for real movie metadata **+*+*+*+*
#include "tmdbapi.h"




// void qtErrorRemove(QtMsgType type, const QMessageLogContext &context, const QString &msg) {
//     //http2 error lai remove ani tesko satta print
//     if (context.category && qstrcmp(context.category, "qt.network.http2") == 0)
//         return;

//     switch (type) {
//     case QtDebugMsg:
//         fprintf(stdout, "[INFO]  %s\n", qPrintable(msg));
//         break;
//     case QtInfoMsg:
//         fprintf(stdout, "[INFO]  %s\n", qPrintable(msg));
//         break;
//     case QtWarningMsg:
//         fprintf(stdout, "[WARN]  %s\n", qPrintable(msg));
//         break;
//     case QtCriticalMsg:
//         fprintf(stdout, "[ERROR] %s\n", qPrintable(msg));
//         break;
//     case QtFatalMsg:
//         fprintf(stdout, "[FATAL] %s\n", qPrintable(msg));
//         abort();
//     }
// }




int main(int argc, char *argv[])
{
    //qInstallMessageHandler(qtErrorRemove);    //default error remove lai call garya, mathi declare

    //qputenv("QT_NETWORK_HTTP2_DISABLE", "1"); // poster fetch ko limit remove, 2 thiyo paila



    QGuiApplication app(argc, argv);
    app.setApplicationName("KUik");
    app.setApplicationVersion("1.0");

    // Create the Internet Archive API backend
    // This single instance is shared across all QML pages
    ArchiveAPI api;

    // Create the account manager backend for signup/login
    // This single instance is shared across Signup.qml and Login.qml
    AccountManager accountManager;

    // Create the watch history backend, shared across HomePage/DetailPage/WatchHistory pages
    WatchHistoryManager watchHistory;

    //*+*+*+*+*+ Create TMDB API backend for fetching real ratings & overviews **+*+*+*+*
    TmdbAPI tmdbApi;

    QQmlApplicationEngine engine;

    // Register as a context property so QML can access it as "archiveApi"
    // Any QML file can call:  archiveApi.fetchCurated()  etc.
    engine.rootContext()->setContextProperty("archiveApi", &api);

    // Register as "accountManager" so QML can call:
    // accountManager.signup(username, password), accountManager.login(...), etc.
    engine.rootContext()->setContextProperty("accountManager", &accountManager);

    // Register as "watchHistory" so QML can call:
    // watchHistory.addToHistory(username, movie), watchHistory.getHistory(username)
    engine.rootContext()->setContextProperty("watchHistory", &watchHistory);

    //*+*+*+*+*+ Register as "tmdbApi" so QML can call tmdbApi.searchMovie(title, year) **+*+*+*+*
    engine.rootContext()->setContextProperty("tmdbApi", &tmdbApi);

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
