import QtQuick
import QtQuick.Controls
import "../components"

// ── Watch History Page ───────────────────────────────────────
// Shows everything the current user has watched, most recent first.
// Opened from the settings dropdown in NavBar.
Rectangle {
    id: historyPage
    color: "#0f0f0f"

    property var appStack: null
    property string username: ""

    // Filled in from watchHistory.getHistory() when the page loads
    property var historyList: []

    Component.onCompleted: {
        historyList = watchHistory.getHistory(username)
    }

    // Reuses the same navigation pattern as DetailPage's openDetail()
    function openDetail(movie) {
        if (!historyPage.appStack) return
        var c = Qt.createComponent("qrc:/qt/qml/KUik/qml/pages/DetailPage.qml")
        var p = c.createObject(null, {
            movie_title:       movie.title       || "",
            movie_year:        movie.year        || "",
            movie_genre:       movie.genre       || "",
            movie_rating:      movie.rating      || "0",
            movie_description: movie.description || "",
            poster_url:        movie.poster_url  || "",
            video_url:         movie.video_url   || "",
            movie_identifier:  movie.identifier  || "",
            appStack:          historyPage.appStack
        })
        historyPage.appStack.push(p)
    }

    Column {
        anchors.fill: parent
        spacing: 0

        // ── Simple top bar with back button + title ────────────────
        Rectangle {
            width: parent.width
            height: 56
            color: "#1a1a1a"

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 24
                spacing: 16

                Rectangle {
                    width: 80; height: 32; radius: 6
                    color: back_area.containsMouse ? "#2a2a2a" : "transparent"
                    border.color: "#3a3a3a"; border.width: 1
                    anchors.verticalCenter: parent.verticalCenter

                    Row {
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: "◀"; color: "#fff"; font.pixelSize: 11 }
                        Text { text: "Back"; color: "#fff"; font.pixelSize: 12 }
                    }

                    MouseArea {
                        id: back_area
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { if (historyPage.appStack) historyPage.appStack.pop() }
                    }
                }

                Text {
                    text: "Watch History"
                    color: "#ffffff"
                    font.pixelSize: 18
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: "#2a2a2a"
            }
        }

        // ── Empty state ─────────────────────────────────────────────
        Item {
            width: parent.width
            height: historyPage.height - 56
            visible: historyList.length === 0

            Column {
                anchors.centerIn: parent
                spacing: 10
                Text {
                    text: "No watch history yet"
                    color: "#666666"
                    font.pixelSize: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: "Movies you watch will show up here"
                    color: "#444444"
                    font.pixelSize: 13
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        // ── History grid ────────────────────────────────────────────
        ScrollView {
            width: parent.width
            height: historyPage.height - 56
            visible: historyList.length > 0
            contentWidth: availableWidth
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Flow {
                width: parent.width
                spacing: 16
                topPadding: 24
                bottomPadding: 24
                leftPadding: 32
                rightPadding: 32

                Repeater {
                    model: historyList
                    MovieCard {
                        movie_title:  modelData.title   || ""
                        movie_year:   modelData.year    || ""
                        movie_genre:  modelData.genre   || ""
                        movie_rating: parseFloat(modelData.rating) || 0
                        poster_url:   modelData.poster_url || ""
                        onCardClicked: historyPage.openDetail(modelData)
                    }
                }
            }
        }
    }
}
