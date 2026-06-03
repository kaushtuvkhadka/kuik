#include <QGuiApplication> // Handles event loops - keeps app running and listening for windows even, mouse clicks, etc
#include <QQmlApplicationEngine> // Bridge between c++ code and QML files
#include <QtCore/QUrl>
int main(int argc, char *argv[])  // argc and argv are command line arguments qt needs them passed in
{
    QGuiApplication app(argc, argv); // creates application object. Passes commmand line args to Qt so it handle things like --playform flags.

    app.setApplicationName("KUik"); // Sets app name
    app.setApplicationVersion("1.0");  // Sets version name

    QQmlApplicationEngine engine;   // Creates QML engine that will load and run your Main.qml file

    const QUrl url(QStringLiteral("qrc:/qt/qml/KUik/qml/Main.qml"));   // URL pointsing to Main.qml. qrc: means "look inside the bundled resources not the whole disk"
    // QStringLiteral(u"...") is way to create Qt string. u (UTF-16), QStringLiteral(converts the url to QString)

    QObject::connect (      // Qt's signal system. Error handeler which says if QML engine fails to create the windows, call this function and exit with code -1
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },   // [](){...} :  An anonymous function defined right here (inline)
        Qt::QueuedConnection
    );

    engine.load(url); // Actually loads and runs Main.qml. This is the moment your windows appears
    return app.exec(); // Starts the event loop. The app now stays here, waiting for users input. When they close it, exec() returns and program exits cleanly
}

//cmake -S /home/aryan/KUik_GUI -B /home/aryan/KUik_GUI/build/Desktop-Debug : for building in terminal
