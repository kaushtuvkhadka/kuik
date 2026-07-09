import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: navBar
    objectName: "navBar"
    height: 56
    color: "#1a1a1a"

    signal searchRequested(string query)
    signal menuClicked()

    // Allow parent to clear the search input (e.g. when navigating back)
    function clearSearch() {
        search_input.text = ""
    }

    function searchQuerySent(){
        if (search_input.text.trim().length > 0){
            if(appStack.currentItem.pageName == "searchPage"){
                appStack.push("../pages/SearchPage.qml", {
                            appStack: appStack,
                            initialQuery: search_input.text.trim()
                        })
            }
        }


        console.log("Current page:", appStack.currentItem.objectName)

        console.log(appStack.currentItem.pageName)

        navBar.searchRequested(search_input.text.trim())
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        spacing: 16

        Text {
            text: "KUik"
            color: "#e50914"
            font.pixelSize: 24
            font.bold: true
            font.letterSpacing: 1.5
        }

        Rectangle {
            Layout.fillWidth: true
            height: 34
            radius: 6
            color: "#2a2a2a"
            border.color: search_input.activeFocus ? "#e50914" : "#3a3a3a"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 6

                TextInput {
                    id: search_input
                    Layout.fillWidth: true
                    color: "#ffffff"
                    font.pixelSize: 14
                    clip: true
                    verticalAlignment: Text.AlignVCenter

                    Text {
                        anchors.fill: parent
                        text: "Search movies..."
                        color: "#666666"
                        font.pixelSize: 14
                        verticalAlignment: Text.AlignVCenter
                        visible: !search_input.text && !search_input.activeFocus
                    }

                    Keys.onReturnPressed: {

                        searchQuerySent()

                    }
                }

                Text {
                    text: "⌕"
                    color: "#888888"
                    font.pixelSize: 16

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {

                            searchQuerySent()




                        }
                    }
                }
            }
        }

        Rectangle {
            width: 34
            height: 34
            radius: 6
            color: menu_area.containsMouse ? "#2a2a2a" : "transparent"

            Column {
                anchors.centerIn: parent
                spacing: 5
                Repeater {
                    model: 3
                    Rectangle { width: 18; height: 2; radius: 1; color: "#ffffff" }
                }
            }

            MouseArea {
                id: menu_area
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: navBar.menuClicked()
            }
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: "#2a2a2a"
    }
}
