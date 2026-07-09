import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"




Rectangle {
    id: searchPage
    objectName: "searchPage"
    color: "#0f0f0f"

    property var    appStack:     null
    property string initialQuery: ""

    property var    results:   []
    property bool   isLoading: false
    property string errorMsg:  ""
    property string lastQuery: ""

    // ── Wire to backend ────────────────────────────────────────────────
    Connections {
        target: archiveApi

        function onSearchResultsReady(movies) {
            isLoading = false
            errorMsg  = ""
            results   = movies
        }

        function onErrorOccurred(message) {
            isLoading = false
            errorMsg  = message
        }

        function onLoadingChanged(loading) {
            // Only track loading if we initiated it
            if (loading && lastQuery !== "") isLoading = true
        }
    }

    function doSearch(query) {
        if (query.trim() === "") return
        lastQuery = query
        results   = []
        isLoading = true
        errorMsg  = ""
        archiveApi.search(query)
    }

    function openDetail(movie) {
        if (!searchPage.appStack) return
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
            appStack:          searchPage.appStack
        })
        searchPage.appStack.push(p)
    }

    Component.onCompleted: {
        if (initialQuery !== "") doSearch(initialQuery)
    }

    Column {
        anchors.fill: parent
        spacing: 0

        NavBar {
            id: nav_bar
            // StackView: searchPage.appStack

            width: parent.width
            onSearchRequested: function(query) {
                if (searchPage.appStack){

                    console.log("search request pathayo")
                    console.log(query)
                    searchPage.doSearch(query)
                }else{
                    throw "appstack null or sth"
                }
            }
            onMenuClicked: { }
        }

        // Back bar
        Rectangle {
            width: parent.width
            height: 44
            color: "#141414"
            border.color: "#2a2a2a"
            border.width: 1

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 20
                spacing: 12

                Rectangle {
                    width: 70; height: 28; radius: 5
                    color: back_area.containsMouse ? "#2a2a2a" : "transparent"
                    border.color: "#3a3a3a"; border.width: 1
                    Row {
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: "◀"; color: "#aaa"; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "Back"; color: "#aaa"; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
                    }
                    MouseArea {
                        id: back_area
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { if (searchPage.appStack) searchPage.appStack.pop() }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: lastQuery !== ""
                          ? ("Results for \"" + lastQuery + "\"" +
                             (!isLoading && results.length > 0 ? "  —  " + results.length + " found" : ""))
                          : ""
                    color: "#888888"
                    font.pixelSize: 13
                }
            }
        }

        // Loading state
        Item {
            width: parent.width
            height: searchPage.height - nav_bar.height - 44
            visible: isLoading

            Column {
                anchors.centerIn: parent
                spacing: 16
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8
                    Repeater {
                        model: 3
                        Rectangle {
                            width: 10; height: 10; radius: 5; color: "#e50914"
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite; running: isLoading
                                PauseAnimation { duration: index * 200 }
                                NumberAnimation { to: 1; duration: 300 }
                                NumberAnimation { to: 0.2; duration: 300 }
                                PauseAnimation { duration: (3 - index) * 200 }
                            }
                        }
                    }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Searching Internet Archive..."
                    color: "#666666"; font.pixelSize: 14
                }
            }
        }

        // No results
        Item {
            width: parent.width
            height: searchPage.height - nav_bar.height - 44
            visible: !isLoading && results.length === 0 && errorMsg === "" && lastQuery !== ""
            Column {
                anchors.centerIn: parent; spacing: 12
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "🎬"; font.pixelSize: 48 }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "No public-domain movies found for \"" + lastQuery + "\""
                    color: "#888888"; font.pixelSize: 14
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Try a different title or keyword"
                    color: "#555555"; font.pixelSize: 12
                }
            }
        }

        // Error
        Item {
            width: parent.width
            height: searchPage.height - nav_bar.height - 44
            visible: !isLoading && errorMsg !== ""
            Column {
                anchors.centerIn: parent; spacing: 12
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "⚠"; font.pixelSize: 40; color: "#e50914" }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: errorMsg; color: "#cccccc"; font.pixelSize: 13 }
            }
        }

        // Results grid
        ScrollView {
            width: parent.width
            height: searchPage.height - nav_bar.height - 44
            visible: !isLoading && results.length > 0
            contentWidth: availableWidth
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            // Flow layout wraps cards into rows automatically
            Flow {
                width: parent.width
                spacing: 20
                topPadding: 28
                bottomPadding: 28
                leftPadding: 32
                rightPadding: 32

                Repeater {
                    model: results
                    MovieCard {
                        movie_title:  modelData.title   || ""
                        movie_year:   modelData.year    || ""
                        movie_genre:  modelData.genre   || ""
                        movie_rating: parseFloat(modelData.rating) || 0
                        poster_url:   modelData.poster_url || ""
                        onCardClicked: searchPage.openDetail(modelData)
                    }
                }
            }
        }
    }
}


