import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: navBar
    objectName: "navBar"
    height: 56
    color: "#1a1a1a"

    signal searchRequested(string query)
    signal historyRequested()
    signal logoutRequested()
    signal menuClicked()

    // Allow parent to clear the search input (e.g. when navigating back)
    function clearSearch() {
        search_input.text = ""
    }

    function searchQuerySent() {
        if (search_input.text.trim().length > 0) {
            if (appStack.currentItem.pageName === "searchPage") {
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

        // ── Settings menu button (3 bars) + dropdown ──────────────────
        Rectangle {
            id: menuButton
            width: 34
            height: 34
            radius: 6
            color: menu_area.containsMouse || menuPanel.visible ? "#2a2a2a" : "transparent"

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
                // Toggle the dropdown open/closed
                onClicked: menuPanel.visible = !menuPanel.visible
            }
        }

        // ── Dropdown panel itself ──────────────────────────────────────
        // Positioned relative to navBar (not menuButton) so it doesn't get
        // clipped by RowLayout, and floats above everything else (z: 100)
        Rectangle {
            id: menuPanel
            visible: false
            // Reparent to the app's top overlay layer so it renders above
            // EVERYTHING (hero images, ScrollViews, other pages) — not just
            // above its siblings inside NavBar.
            parent: Overlay.overlay
            z: 1000
            width: 180
            height: menuColumn.implicitHeight + 16
            radius: 8
            color: "#1a1a1a"
            border.color: "#3a3a3a"
            border.width: 1

            // Since we reparented, position must be converted from NavBar's
            // local coordinates into the overlay's coordinate space using mapToItem.
            x: navBar.mapToItem(Overlay.overlay, navBar.width - width - 24, 0).x
            y: navBar.mapToItem(Overlay.overlay, 0, navBar.height + 6).y

            Column {
                id: menuColumn
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                // ── Watch History option ────────────────────────────
                Rectangle {
                    width: parent.width
                    height: 36
                    radius: 6
                    color: historyArea.containsMouse ? "#2a2a2a" : "transparent"

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Watch History"
                        color: "#ffffff"
                        font.pixelSize: 13
                    }

                    MouseArea {
                        id: historyArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            menuPanel.visible = false
                            navBar.historyRequested()
                        }
                    }
                }

                // ── Log Out option ──────────────────────────────────
                Rectangle {
                    width: parent.width
                    height: 36
                    radius: 6
                    color: logoutArea.containsMouse ? "#2a2a2a" : "transparent"

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Log Out"
                        color: "#e50914"
                        font.pixelSize: 13
                    }

                    MouseArea {
                        id: logoutArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            menuPanel.visible = false
                            navBar.logoutRequested()
                        }
                    }
                }
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