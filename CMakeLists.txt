cmake_minimum_required(VERSION 3.25)
project(KUik VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# Added Network for HTTP requests to Internet Archive API
find_package(Qt6 6.7 REQUIRED COMPONENTS Core Gui Qml Quick Multimedia Network)

qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

qt_add_executable(KUik
    src/main.cpp
    src/archiveapi.h
    src/archiveapi.cpp
    src/accountmanager.h
    src/accountmanager.cpp
)

qt_add_qml_module(KUik
    URI KUik
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/pages/HomePage.qml
        qml/pages/DetailPage.qml
        qml/pages/PlayerPage.qml
        qml/pages/SearchPage.qml
        qml/pages/Signup.qml
        qml/pages/Login.qml
        qml/components/NavBar.qml
        qml/components/MovieCard.qml
        qml/components/SearchBar.qml
        qml/components/VideoControls.qml
        qml/components/LoadingSpinner.qml
)

target_link_libraries(KUik PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Multimedia
    Qt6::Network
)
