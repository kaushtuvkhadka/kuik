import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: root
    width: 1280
    height: 720
    minimumWidth: 1024
    minimumHeight: 600
    visibility: Window.Maximized
    visible: true
    title: "KUik"
    color: "#0f0f0f"

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: homePageComponent
    }

    Component {
        id: homePageComponent
        Loader {
            anchors.fill: parent
            source: "qrc:/qt/qml/KUik/qml/pages/HomePage.qml"
            onLoaded: {
                console.log("Loaded:", item)        // ✅ debug
                item.appStack = stackView           // sets appStack on HomePage directly
            }
        }
    }
}