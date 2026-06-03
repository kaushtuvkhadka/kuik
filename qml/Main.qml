import QtQuick
import QtQuick.Controls

ApplicationWindow {     // proper app window with menu bar, status bar support
    id: root    // gives this element a same so other element can refer to it
    width: 1280
    height: 720
    minimumWidth: 1024  // prevents user resizing window too small
    minimumHeight: 600
    visibility: Window.Maximized  // opens maximized on any screen size
    visible: true
    title: "KUik"
    color: "#0f0f0f"    //dark background

    StackView {     // navigation stack. This is how we navigate between HomePage, DetailPage and PlayerPage
        id: stackView
        anchors.fill: parent    // fills the entire windows
        initialItem: homePageComponent  // first page to show, for us it is HomePage
    }

    Component {
            id: homePageComponent
            Loader {
                anchors.fill: parent
                source: "qrc:/qt/qml/KUik/qml/pages/HomePage.qml"
                onLoaded: item.appStack = stackView     // to pass stack view into Homepage
            }
    }
}


