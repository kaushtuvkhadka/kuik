import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Rectangle {
    id: homePage
    color: "#0f0f0f"

    property var appStack: null

    // ── Movie data — populated by archiveApi signals ───────────────────
    property var recommendations: []
    property var topPicks:        []
    property bool isLoading:      true
    property string errorMsg:     ""

    // ── Connect to C++ backend ─────────────────────────────────────────
    // These Connections blocks wire ArchiveAPI signals to QML handlers.
    // archiveApi is registered as a context property in main.cpp.

    Connections {
        target: archiveApi

        // curatedReady fires with the full list of resolved movies.
        // We split them: first half → recommendations, second half → top picks.
        function onCuratedReady(movies) {
            isLoading = false
            errorMsg  = ""
            var half = Math.ceil(movies.length / 2)
            recommendations = movies.slice(0, half)
            topPicks        = movies.slice(half)
        }

        function onErrorOccurred(message) {
            isLoading = false
            errorMsg  = message
        }

        function onLoadingChanged(loading) {
            isLoading = loading
        }
    }

        // Called by Main.qml if movie data was already fetched in advance
        // (while the user was busy on Signup/Login). Skips a second fetch.
        function setPreloadedMovies(movies) {
            isLoading = false
            errorMsg  = ""
            var half = Math.ceil(movies.length / 2)
            recommendations = movies.slice(0, half)
            topPicks        = movies.slice(half)
        }

        // Called by Main.qml only if NO data was preloaded yet —
        // i.e. this is a normal fresh fetch, same as before.
        function startFetch() {
            archiveApi.fetchCurated()
        }
        // NOTE: we removed the old Component.onCompleted fetch here.
        // Main.qml now decides whether to call setPreloadedMovies() or
        // startFetch() — see the Loader.onLoaded block in Main.qml

    // ── Navigation helper ──────────────────────────────────────────────
    function openDetail(movie) {
        if (!homePage.appStack) return
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
            appStack:          homePage.appStack
        })
        homePage.appStack.push(p)
    }

    // ── Layout ─────────────────────────────────────────────────────────
    Column {
        anchors.fill: parent
        spacing: 0

        NavBar {
            id: nav_bar
            width: parent.width
            onSearchRequested: function(query) {
                if (!homePage.appStack) return
                var c = Qt.createComponent("qrc:/qt/qml/KUik/qml/pages/SearchPage.qml")
                var p = c.createObject(null, { appStack: homePage.appStack, initialQuery: query })
                homePage.appStack.push(p)
            }

        }

        // ── Loading state ──────────────────────────────────────────────
        Item {
            width: parent.width
            height: homePage.height - nav_bar.height
            visible: isLoading

            Column {
                anchors.centerIn: parent
                spacing: 16

                // Simple animated dots as spinner
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8
                    Repeater {
                        model: 3
                        Rectangle {
                            width: 10; height: 10; radius: 5
                            color: "#e50914"
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                running: isLoading
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
                    text: "Loading movies from Internet Archive..."
                    color: "#666666"
                    font.pixelSize: 14
                }
            }
        }

        // ── Error state ────────────────────────────────────────────────
        Item {
            width: parent.width
            height: homePage.height - nav_bar.height
            visible: !isLoading && errorMsg !== ""

            Column {
                anchors.centerIn: parent
                spacing: 16

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "⚠"
                    font.pixelSize: 48
                    color: "#e50914"
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: errorMsg
                    color: "#cccccc"
                    font.pixelSize: 14
                    wrapMode: Text.WordWrap
                    width: 400
                    horizontalAlignment: Text.AlignHCenter
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 120; height: 38; radius: 6
                    color: retry_area.containsMouse ? "#ff0a16" : "#e50914"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Text {
                        anchors.centerIn: parent
                        text: "Retry"
                        color: "#ffffff"
                        font.pixelSize: 14
                        font.bold: true
                    }
                    MouseArea {
                        id: retry_area
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            errorMsg = ""
                            isLoading = true
                            archiveApi.fetchCurated()
                        }
                    }
                }
            }
        }

        // ── Main content ───────────────────────────────────────────────
        ScrollView {
            width: parent.width
            height: homePage.height - nav_bar.height
            visible: !isLoading && errorMsg === ""
            contentWidth: availableWidth
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Column {
                width: parent.width
                spacing: 40
                topPadding: 36
                bottomPadding: 36

                // ── Featured hero banner (first recommendation) ────────
                Rectangle {
                    width: parent.width - 64
                    height: 280
                    x: 32
                    radius: 12
                    color: "#1a1a1a"
                    clip: true
                    visible: recommendations.length > 0

                    Image {
                        anchors.fill: parent
                        source: recommendations.length > 0 ? recommendations[0].poster_url : ""
                        fillMode: Image.PreserveAspectCrop
                        opacity: 0.4
                    }

                    // Gradient overlay
                    Rectangle {
                        anchors.fill: parent
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#e0000000" }
                            GradientStop { position: 0.6; color: "#40000000" }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }

                    Column {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 40
                        spacing: 10
                        width: parent.width * 0.55

                        Rectangle {
                            width: 80; height: 22; radius: 4
                            color: "#e50914"
                            Text {
                                anchors.centerIn: parent
                                text: "FEATURED"
                                color: "#ffffff"
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 2
                            }
                        }

                        Text {
                            text: recommendations.length > 0 ? recommendations[0].title : ""
                            color: "#ffffff"
                            font.pixelSize: 32
                            font.bold: true
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        Text {
                            text: recommendations.length > 0
                                  ? (recommendations[0].year + "  ·  " +
                                     recommendations[0].genre + "  ·  ★ " +
                                     recommendations[0].rating)
                                  : ""
                            color: "#aaaaaa"
                            font.pixelSize: 14
                        }

                        Row {
                            spacing: 12
                            Rectangle {
                                width: 130; height: 40; radius: 6
                                color: watch_hero_area.containsMouse ? "#ff0a16" : "#e50914"
                                Behavior on color { ColorAnimation { duration: 150 } }
                                Text {
                                    anchors.centerIn: parent
                                    text: "▶  Watch Now"
                                    color: "#ffffff"
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                                MouseArea {
                                    id: watch_hero_area
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (recommendations.length > 0)
                                            homePage.openDetail(recommendations[0])
                                    }
                                }
                            }
                            Rectangle {
                                width: 110; height: 40; radius: 6
                                color: info_area.containsMouse ? "#333" : "#222"
                                border.color: "#444"; border.width: 1
                                Behavior on color { ColorAnimation { duration: 150 } }
                                Text {
                                    anchors.centerIn: parent
                                    text: "ℹ  More Info"
                                    color: "#cccccc"
                                    font.pixelSize: 14
                                }
                                MouseArea {
                                    id: info_area
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (recommendations.length > 0)
                                            homePage.openDetail(recommendations[0])
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Recommendations row ────────────────────────────────
                Column {
                    width: parent.width
                    spacing: 16
                    leftPadding: 32

                    Text {
                        text: "Popular Classics"
                        color: "#ffffff"
                        font.pixelSize: 18
                        font.bold: true
                    }

                    ScrollView {
                        width: parent.width - 32
                        height: 250
                        ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                        clip: true

                        Row {
                            spacing: 16
                            Repeater {
                                model: recommendations
                                MovieCard {
                                    movie_title:  modelData.title   || ""
                                    movie_year:   modelData.year    || ""
                                    movie_genre:  modelData.genre   || ""
                                    movie_rating: parseFloat(modelData.rating) || 0
                                    poster_url:   modelData.poster_url || ""
                                    onCardClicked: homePage.openDetail(modelData)
                                }
                            }
                        }
                    }
                }

                // ── Top Picks row ──────────────────────────────────────
                Column {
                    width: parent.width
                    spacing: 16
                    leftPadding: 32

                    Text {
                        text: "Top Picks"
                        color: "#ffffff"
                        font.pixelSize: 18
                        font.bold: true
                    }

                    ScrollView {
                        width: parent.width - 32
                        height: 250
                        ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                        clip: true

                        Row {
                            spacing: 16
                            Repeater {
                                model: topPicks
                                MovieCard {
                                    movie_title:  modelData.title   || ""
                                    movie_year:   modelData.year    || ""
                                    movie_genre:  modelData.genre   || ""
                                    movie_rating: parseFloat(modelData.rating) || 0
                                    poster_url:   modelData.poster_url || ""
                                    onCardClicked: homePage.openDetail(modelData)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
