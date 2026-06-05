#Minimum CMake version required to build this project
cmake_minimum_required(VERSION 3.25)

#Projects Name, version and language(CXX = C++)
project(KUik_GUI VERSION 1.0 LANGUAGES CXX)

#Use C++20 standard
set (CMAKE_CXX_STANDARD 20)
#Crash if C++20 is not avilable
set (CMAKE_CXX_STANDARD_REQUIRED ON)
#MOC= Meta Object Compiler, Qt's tool that processes signals/slots automatically
set (CMAKE_AUTOMOC ON)
#automatically processes .qrc resource files (icons, QML files bundled into the app)
set (CMAKE_AUTORCC ON)

# find_package() finds qt6 in yoour systems
# Core (basic Qt (strings, files, etc)) Gui (windows, rendering) Qml (The QML engine) Quick (makes QMl items actually render) Multimedia (video/ audio playback)
find_package(Qt6 6.7 REQUIRED COMPONENTS Core Gui Qml Quick Multimedia)

# SUppress Qt Cmake policy warnings
qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

#creates the executable from main.cpp
qt_add_executable(KUik_GUI
    src/main.cpp
)
#qt_add_qml_module : tells Qt "these files belong to this app"
#URI KUik : Import name. When one QML file imports another file, it uses this name
#QML_FILES : list every .qml file
qt_add_qml_module(KUik_GUI
    URI KUik
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/pages/HomePage.qml
        qml/pages/DetailPage.qml
        qml/pages/PlayerPage.qml
        qml/components/NavBar.qml
        qml/components/MovieCard.qml
        qml/components/SearchBar.qml
        qml/components/VideoControls.qml
        SOURCES src/InternetArchive.cpp
        SOURCES src/InternetArchive.h
)

# find_package : finds Qt modules found earlier
# target_link_libraries : connects all modules to the app
target_link_libraries(KUik_GUI PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Multimedia
)
