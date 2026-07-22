import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"




Rectangle {
    id: detailPage
    color: "#0f0f0f"

    property var    appStack:          null
    property string movie_title:       ""
    property string movie_year:        ""
    property string movie_genre:       ""
    //*+*+*+*+*+ Removed movie_rating property — ratings now come from TMDB **+*+*+*+*
    property string movie_description: ""
    property string poster_url:        ""
    property string video_url:         ""
    property string movie_identifier:  ""

    //*+*+*+*+*+ TMDB metadata properties — populated after searchMovie call **+*+*+*+*
    property bool   tmdbLoading:  false
    property bool   tmdbFound:    false
    property double tmdbRating:   0.0
    property string tmdbOverview: ""
    property string tmdbBackdrop: ""
    property string tmdbPoster:   ""
    property string tmdbReleaseDate: ""
    property int    tmdbVoteCount: 0
    property string tmdbLanguage: ""

    // Similar movies ko lagi
    property var    similar_movies:    []
    property bool   loadingSimilar:    false                //search bhairako bela true hunxa, tala define xa
    property bool   expectingSimilar: false




    function getGenre(movie) {
        return (movie.genre || movie.subject || "").toLowerCase()             //genre find
    }



    Connections {
        target: archiveApi                     //kun signal lai sunne/respond garne herne

        enabled: detailPage.expectingSimilar        //expectingSimilar property true huda matra signal  run hunxa, by default false hunxa


        function onSearchResultsReady(movies) {
            detailPage.expectingSimilar = false
            detailPage.loadingSimilar   = false

            //similar movie fetch basne
            var filtered = []


            //kati ota similar movie haru fetch garne
            for (var i = 0; i < movies.length && filtered.length < 4; i++) {

                //genre same check garne
                if (movies[i].identifier !== detailPage.movie_identifier) {
                            if (getGenre(movies[i]) === movie_genre.toLowerCase()) {
                                console.log("     Movie: ", movies[i].title, "\n\tUrl: ", movies[i].video_url,"\n\tGenre: ", movies[i].genre);
                                filtered.push(movies[i])
                            }
                        }
            }
            detailPage.similar_movies = filtered                //similar movies ma save hunxa filtered movie list
        }
    }

    //*+*+*+*+*+ TMDB connection — listens for tmdbApi.tmdbResultReady signal **+*+*+*+*
    Connections {
        target: tmdbApi

        //*+*+*+*+*+ When TMDB result arrives, update the tmdb properties **+*+*+*+*
        function onTmdbResultReady(result) {
            //*+*+*+*+*+ Only accept if the result matches our current movie title **+*+*+*+*
            if (result.title !== detailPage.movie_title) return

            detailPage.tmdbLoading = false
            if (result.found) {
                detailPage.tmdbFound    = true
                detailPage.tmdbRating   = result.rating
                detailPage.tmdbOverview = result.overview
                detailPage.tmdbBackdrop = result.backdrop_path
                detailPage.tmdbPoster   = result.poster_path
                detailPage.tmdbReleaseDate = result.release_date
                detailPage.tmdbVoteCount = result.vote_count
                detailPage.tmdbLanguage = result.language
            } else {
                detailPage.tmdbFound = false
            }
        }
    }


    //similar movie fetch garne func, initiate garne
    function fetchSimilar() {
        if (movie_genre === "")                         //movie ko genre xaina bhane end garxa process fetching ko
            return

        //genre xa bhane yo hunxa
        expectingSimilar = true
        loadingSimilar   = true
        //genre anushar search
        archiveApi.search(movie_genre)
    }

    function openPlayer() {
        if (!detailPage.appStack || video_url === "") return

        // Record this movie in the logged-in user's watch history
        var currentUser = accountManager.currentUser()
        if (currentUser !== "") {
            watchHistory.addToHistory(currentUser, {
                title:       detailPage.movie_title,
                year:        detailPage.movie_year,
                genre:       detailPage.movie_genre,
                //*+*+*+*+*+ Removed rating from history save — no more fake rating **+*+*+*+*
                poster_url:  detailPage.poster_url,
                video_url:   detailPage.video_url,
                identifier:  detailPage.movie_identifier
            })
        }

        var c = Qt.createComponent("qrc:/qt/qml/KUik/qml/pages/PlayerPage.qml")
        var p = c.createObject(null, {
            video_url:   detailPage.video_url,
            movie_title: detailPage.movie_title,
            appStack:    detailPage.appStack
        })
        detailPage.appStack.push(p)
    }

    function openDetail(movie) {
        if (!detailPage.appStack) return
        var c = Qt.createComponent("qrc:/qt/qml/KUik/qml/pages/DetailPage.qml")
        var p = c.createObject(null, {
            movie_title:       movie.title       || "",
            movie_year:        movie.year        || "",
            movie_genre:       movie.genre       || "",
            //*+*+*+*+*+ Removed movie_rating — ratings now fetched from TMDB on DetailPage **+*+*+*+*
            movie_description: movie.description || "",
            poster_url:        movie.poster_url  || "",
            video_url:         movie.video_url   || "",
            movie_identifier:  movie.identifier  || "",
            appStack:          detailPage.appStack
        })
        detailPage.appStack.push(p)
    }

    Component.onCompleted: {
        fetchSimilar()
        //*+*+*+*+*+ Trigger TMDB search as soon as DetailPage loads — passes title, year, and identifier **+*+*+*+*
        detailPage.tmdbLoading = true
        tmdbApi.searchMovie(detailPage.movie_title, detailPage.movie_year, detailPage.movie_identifier)
    }

    Column {
        anchors.fill: parent
        spacing: 0

        NavBar {
            id: nav_bar
            width: parent.width
            onSearchRequested: function(query) {
                if (!detailPage.appStack) return
                var c = Qt.createComponent("qrc:/qt/qml/KUik/qml/pages/SearchPage.qml")
                var p = c.createObject(null, { appStack: detailPage.appStack, initialQuery: query })
                detailPage.appStack.push(p)
            }
            onHistoryRequested: {
                if (!detailPage.appStack) return
                var c = Qt.createComponent("qrc:/qt/qml/KUik/qml/pages/WatchHistory.qml")
                var p = c.createObject(null, {
                    appStack: detailPage.appStack,
                    username: accountManager.currentUser()
                })
                detailPage.appStack.push(p)
                }
                onLogoutRequested: {
                    accountManager.logout()
                    detailPage.appStack.replace(null, loginPageComponent)
                }
            }

        ScrollView {
            width: parent.width
            height: detailPage.height - nav_bar.height
            contentWidth: availableWidth
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Column {
                width: parent.width
                spacing: 0

                // Hero section
                Rectangle {
                    id: hero_section
                    width: parent.width
                    height: 440
                    color: "#1a1a1a"

                    Image {
                        anchors.fill: parent
                        //*+*+*+*+*+ Use TMDB backdrop if available, fallback to archive poster **+*+*+*+*
                        source: detailPage.tmdbBackdrop !== "" ? detailPage.tmdbBackdrop : detailPage.poster_url
                        fillMode: Image.PreserveAspectCrop
                        opacity: 0.4
                        visible: source !== ""
                    }

                    // Gradient overlay — bottom fade
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 260
                        gradient: Gradient {
                            orientation: Gradient.Vertical
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 1.0; color: "#0f0f0f" }
                        }
                    }

                    // Left gradient for readability
                    Rectangle {
                        anchors.left: parent.left
                        width: parent.width * 0.6
                        height: parent.height
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#99000000" }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }

                    //back button
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.topMargin: 16
                        anchors.leftMargin: 20
                        width: 80; height: 32; radius: 6
                        color: back_area.containsMouse ? "#44ffffff" : "#33000000"
                        border.color: "#44ffffff"; border.width: 1
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Row {
                            anchors.centerIn: parent; spacing: 4
                            Text { text: "◀"; color: "#fff"; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: "Back"; color: "#fff"; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
                        }

                        MouseArea {
                            id: back_area
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { if (detailPage.appStack) detailPage.appStack.pop() }
                        }
                    }

                    // Movie info bottom-left
                    Column {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.margins: 36
                        spacing: 10
                        width: parent.width * 0.6

                        Text {
                            text: detailPage.movie_title
                            color: "#ffffff"
                            font.pixelSize: 38
                            font.bold: true
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        Row {
                            spacing: 10
                            Rectangle {
                                width: yearText.width + 16; height: 22; radius: 4
                                color: "#33ffffff"; border.color: "#55ffffff"; border.width: 1
                                Text {
                                    id: yearText
                                    anchors.centerIn: parent
                                    //*+*+*+*+*+ Prefer TMDB release year, fallback to archive year **+*+*+*+*
                                    text: detailPage.tmdbReleaseDate !== "" ? detailPage.tmdbReleaseDate.substring(0, 4) : (detailPage.movie_year !== "" ? detailPage.movie_year : "Unknown year")
                                    color: "#dddddd"; font.pixelSize: 11
                                }
                            }
                            //*+*+*+*+*+ Language Badge **+*+*+*+*
                            Rectangle {
                                visible: detailPage.tmdbLanguage !== ""
                                width: langText.width + 16; height: 22; radius: 4
                                color: "#33ffffff"; border.color: "#55ffffff"; border.width: 1
                                Text {
                                    id: langText
                                    anchors.centerIn: parent
                                    text: detailPage.tmdbLanguage
                                    color: "#dddddd"; font.pixelSize: 11
                                }
                            }
                            Rectangle {
                                width: genreText.width + 16; height: 22; radius: 4
                                color: "#33e50914"; border.color: "#55e50914"; border.width: 1
                                Text {
                                    id: genreText
                                    anchors.centerIn: parent
                                    text: detailPage.movie_genre !== "" ? detailPage.movie_genre : "Film"
                                    color: "#ffaaaa"; font.pixelSize: 11
                                }
                            }
                            //*+*+*+*+*+ Removed old fake rating badge — ratings now in TMDB mini-tab below **+*+*+*+*
                        }
                    }

                    // Watch now ra no video warning
                    Column {
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.margins: 36
                        spacing: 8

                        Rectangle {
                            width: 150; height: 46; radius: 8
                            color: detailPage.video_url !== ""
                                   ? (watch_btn.containsMouse ? "#ff0a16" : "#e50914")
                                   : "#444"
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                text: detailPage.video_url !== "" ? "▶  Watch Now" : "⏳ Loading..."
                                color: "#ffffff"
                                font.pixelSize: 15
                                font.bold: true
                            }

                            MouseArea {
                                id: watch_btn
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: detailPage.video_url !== "" ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: {
                                    if (detailPage.video_url !== "")
                                        detailPage.openPlayer()
                                }
                            }
                        }
                    }
                }

                //Description
                Column {
                    width: parent.width
                    spacing: 12
                    topPadding: 28
                    bottomPadding: 24
                    leftPadding: 36
                    rightPadding: 36

                    Text {
                        text: "About"
                        color: "#ffffff"
                        font.pixelSize: 20
                        font.bold: true
                    }

                    Text {
                        text: detailPage.movie_description !== ""
                              ? detailPage.movie_description
                              : "No description available for this title."
                        color: "#cccccc"
                        font.pixelSize: 15
                        wrapMode: Text.WordWrap
                        width: detailPage.width - 72
                        lineHeight: 1.6
                    }
                }

                //*+*+*+*+*+ TMDB mini-tab section — redesigned to look sleek and native **+*+*+*+*
                Rectangle {
                    width: parent.width - 72
                    x: 36
                    radius: 12
                    color: "#1a1a1a"
                    height: tmdbContent.height + 40

                    Column {
                        id: tmdbContent
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 20
                        spacing: 16

                        //*+*+*+*+*+ Loading state **+*+*+*+*
                        Row {
                            spacing: 8
                            visible: detailPage.tmdbLoading
                            Text {
                                text: "Loading TMDB data..."
                                color: "#777777"
                                font.pixelSize: 13
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Repeater {
                                model: 3
                                Rectangle {
                                    width: 6; height: 6; radius: 3
                                    color: "#777777"
                                    anchors.verticalCenter: parent.verticalCenter
                                    SequentialAnimation on opacity {
                                        loops: Animation.Infinite
                                        running: detailPage.tmdbLoading
                                        PauseAnimation { duration: index * 150 }
                                        NumberAnimation { to: 1; duration: 200 }
                                        NumberAnimation { to: 0.3; duration: 200 }
                                    }
                                }
                            }
                        }

                        //*+*+*+*+*+ Found state — shows TMDB rating and overview **+*+*+*+*
                        Column {
                            visible: !detailPage.tmdbLoading && detailPage.tmdbFound
                            spacing: 12
                            width: parent.width

                            Row {
                                spacing: 12

                                //*+*+*+*+*+ TMDB Logo/Text **+*+*+*+*
                                Text {
                                    text: "TMDB"
                                    color: "#90cea1"
                                    font.pixelSize: 15
                                    font.bold: true
                                    font.letterSpacing: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                //*+*+*+*+*+ Rating with vote count **+*+*+*+*
                                Text {
                                    text: "★ " + detailPage.tmdbRating.toFixed(1) + " / 10"
                                    color: "#ffffff"
                                    font.pixelSize: 15
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: "(" + detailPage.tmdbVoteCount + " votes)"
                                    color: "#888888"
                                    font.pixelSize: 13
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            //*+*+*+*+*+ TMDB overview/plot summary **+*+*+*+*
                            Text {
                                visible: detailPage.tmdbOverview !== ""
                                text: detailPage.tmdbOverview
                                color: "#bbbbbb"
                                font.pixelSize: 14
                                wrapMode: Text.WordWrap
                                width: parent.width
                                lineHeight: 1.6
                            }
                        }
                    }
                }

                //*+*+*+*+*+ Spacer between TMDB section and Similar Movies **+*+*+*+*
                Item { width: 1; height: 20 }

                //Similar movies ko lagi ui
                Column {
                    width: parent.width
                    spacing: 16
                    topPadding: 8
                    bottomPadding: 36
                    leftPadding: 36

                    Text {
                        text: "Similar Movies"
                        color: "#ffffff"
                        font.pixelSize: 18
                        font.bold: true
                        visible: loadingSimilar || similar_movies.length > 0
                    }

                    //Fetch hunu aaghi load sign,
                    Row {
                        spacing: 8
                        visible: loadingSimilar
                        Repeater {
                            model: 3
                            Rectangle {
                                width: 8; height: 8; radius: 4; color: "#555"
                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite; running: loadingSimilar
                                    PauseAnimation { duration: index * 180 }
                                    NumberAnimation { to: 1; duration: 250 }
                                    NumberAnimation { to: 0.2; duration: 250 }
                                }
                            }
                        }
                    }
                                //slider design change scroll view bata
                    ScrollView {
                        width: parent.width - 36
                        height: 250
                        visible: similar_movies.length > 0          //similar movie xaina bhane trigger nei hunna
                        ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                        clip: true

                        Row {
                            spacing: 16
                            Repeater {
                                model: similar_movies
                                MovieCard {
                                    movie_title:  modelData.title   || ""
                                    movie_year:   modelData.year    || ""
                                    movie_genre:  modelData.genre   || ""
                                    //*+*+*+*+*+ Removed movie_rating — no longer passed to MovieCard **+*+*+*+*
                                    poster_url:   modelData.poster_url || ""
                                    onCardClicked: detailPage.openDetail(modelData)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
