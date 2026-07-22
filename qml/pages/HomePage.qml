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

    //********* property = qml keyword for declaring variableess
    //***********storing the 10(currently) movies in array
    property var genreMovies:     []

    //**********genre section ma bydefault chai comedy genre select 
    //huncha initially
    property string activeGenre:  "comedy"

    //**************yeslai chai loading spinner sanga link gareko, 
    //if its true the spinner loads, if false the movies appear
    property bool isGenreLoading: false

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
        //*************************backend le movie archive bata paisake pachi 
        //genreloading false(meaning loading huna chodcha) and genremovie vanne 
        //list ma add garcha
        function onGenreResultsReady(movies) {
            isGenreLoading = false
            genreMovies = movies
        }

        function onErrorOccurred(message) {
            if (isGenreLoading) {
                isGenreLoading = false
            } else {
                isLoading = false
                errorMsg  = message
            }
        }

        function onLoadingChanged(loading) {
            if (isGenreLoading) {
                // Ignore fullscreen loader during genre switching
                return
            }
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

    // Kick off the curated fetch as soon as the page is ready
    //********jaba page fully load huncha tetikhera trigger huncha
    Component.onCompleted: {
        //archiveApi.fetchCurated()-removed
        //*******genre state lai loading rakcha ani comedy movie 
        //fetch garna vanera call garcha
        isGenreLoading = true
        archiveApi.fetchGenre("comedy")
    }

    // ── Navigation helper ──────────────────────────────────────────────
    function openDetail(movie) {
        if (!homePage.appStack) return
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
            onHistoryRequested: {
                if (!homePage.appStack) return
                var c = Qt.createComponent("qrc:/qt/qml/KUik/qml/pages/WatchHistory.qml")
                var p = c.createObject(null, {
                    appStack: homePage.appStack,
                    username: accountManager.currentUser()
                })
                homePage.appStack.push(p)
            }
            onLogoutRequested: {
                accountManager.logout()
                // Send back to Login — reuses the shared component from Main.qml
                // so appStack gets set correctly on the fresh Login page
                homePage.appStack.replace(null, loginPageComponent)
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
                            //*+*+*+*+*+ Removed rating from hero banner — no more fake ★ rating display **+*+*+*+*
                            text: recommendations.length > 0
                                  ? (recommendations[0].year + "  ·  " +
                                     recommendations[0].genre)
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

                    /*============left/right arrow buttons le horizontal scroll bar lai replace gareko
                      for better ui and ux
                    */
                    Item {
                        id: recRow
                        width: parent.width - 32 //since 32 leftpadding diyeko cha
                        height: 250
                        //========clip gareko thiyena bhane ekkai choti ma sabbai movies lai draw garera rakhthyo, 
                        //clip gareko vayera limited lai matra draw garcha
                        clip: true 

                        ListView {
                            id: recList
                            anchors.fill: parent
                            orientation: ListView.Horizontal
                            spacing: 16 //=======movie cards bich ko spacing
                            interactive: true //======mouse le drag garera pani move garna milcha
                            clip: true
                            model: recommendations
                            //=====delegate le each component of the list kasto huncha bhanera moviecards define garcha
                            delegate: MovieCard { 
                                movie_title:  modelData.title   || "" //===== if title else null 
                                movie_year:   modelData.year    || ""
                                movie_genre:  modelData.genre   || ""
                                //*+*+*+*+*+ Removed movie_rating — no longer passed to MovieCard **+*+*+*+*
                                poster_url:   modelData.poster_url || ""
                                onCardClicked: homePage.openDetail(modelData)
                            }
                            //contentX (horizontal scroll x coords) lai instantly hoina 
                            //instead animated transition banayera value change garcha
                            Behavior on contentX { 
                                //===== 300ms time laune, start slow and accelerate in the middle
                                NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } 
                            }
                        }

                        Rectangle {
                            width: 36; height: parent.height
                            anchors.left: parent.left
                            //====== when we are at the first movie or when horizontal scroll is 0 tetikhera < lai hide garne
                            visible: recList.contentX > 0 
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "#cc0f0f0f" }
                                GradientStop { position: 1.0; color: "transparent" }
                            }
                            Text {
                                anchors.centerIn: parent
                                text: "❮"
                                color: recLeftMouse.containsMouse ? "#ffffff" : "#aaaaaa" //====== mouse hover garda white else grey
                                font.pixelSize: 20; font.bold: true
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                            MouseArea {
                                id: recLeftMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                //===== 1 movie card = 160px, spacing = 16 px total 176 pixel, so 176 pixel left move garcha 
                                //meaning euta bata arko moviecard ma jancha, and if value -ve aayo bhane instead 0 set garcha
                                onClicked: recList.contentX = Math.max(0, recList.contentX - 176) 
                            }
                        }

                        Rectangle {
                            width: 36; height: parent.height
                            anchors.right: parent.right
                            //====list ko end ma gayepachi > lai hide garcha (contentwidth = width of all item in list, 
                            //width = width of content visible in screen
                            visible: recList.contentX < recList.contentWidth - recList.width 
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "transparent" }
                                GradientStop { position: 1.0; color: "#cc0f0f0f" }
                            }
                            Text {
                                anchors.centerIn: parent
                                text: "❯"
                                color: recRightMouse.containsMouse ? "#ffffff" : "#aaaaaa"
                                font.pixelSize: 20; font.bold: true
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                            MouseArea {
                                id: recRightMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                //===== if content last element ma cha bhane contentwidth - width = 0 , and contentX + 176 = greater so, 
                                //min = 0 hence move gardaina, aru case ma contenX + 176 < contentwidth - width so 176 right move garcha
                                onClicked: recList.contentX = Math.min(recList.contentWidth - recList.width, recList.contentX + 176)
                            }
                        }
                    }
                }

                //********genre section ko visual ui
                Column {
                    width: parent.width
                    spacing: 16
                    leftPadding: 32

                    RowLayout {
                        width: parent.width - 64
                        spacing: 24

                        Text {
                            text: "Explore Genres"
                            color: "#ffffff"
                            font.pixelSize: 18
                            font.bold: true
                            Layout.alignment: Qt.AlignVCenter
                        }

                        //******* genre suboptions (comedy, actiom, drama, horror) vayeko tabs
                        Row {
                            spacing: 12
                            Layout.alignment: Qt.AlignVCenter

                            Repeater { //********loop jasto kaam garcha, tala vayeko sabbai features lai each genre: comedy, action, drama ra horror ma apply garidincha
                                model: ["Comedy", "Action", "Drama", "Horror"]

                                Rectangle {
                                    id: genreTab
                                    width: genreTabText.width + 24 //*******genre word ko length anusar automatically width adjust garcha
                                    height: 32
                                    radius: 16
                                    color: activeGenre === modelData.toLowerCase() //***** if tyo genre tab ko text matches activeGenre string ko text, then colors it to reddish color (highlighted/select) vayeko dekhaucha
                                           ? "#e50914"
                                           : (tabMouseArea.containsMouse ? "#2a2a2a" : "#141414")//*******else highlights greyish on hover and black when not hovered
                                    border.color: activeGenre === modelData.toLowerCase() ? "transparent" : "#333333"
                                    border.width: 1

                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Text {
                                        id: genreTabText
                                        anchors.centerIn: parent
                                        text: modelData
                                        color: activeGenre === modelData.toLowerCase() ? "#ffffff" : "#aaaaaa"
                                        font.pixelSize: 13
                                        font.bold: activeGenre === modelData.toLowerCase()
                                    }

                                    MouseArea {
                                        id: tabMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (activeGenre !== modelData.toLowerCase()) {
                                                activeGenre = modelData.toLowerCase()
                                                genreMovies = []
                                                isGenreLoading = true
                                                archiveApi.fetchGenre(modelData.toLowerCase())
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Horizontal list / scroll view
                    Item {
                        width: parent.width - 32
                        height: 250

                        // Loading spinner for Genre row
                        Column {
                            anchors.centerIn: parent
                            spacing: 10
                            visible: isGenreLoading

                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 6
                                Repeater {
                                    model: 3
                                    Rectangle {
                                        width: 8; height: 8; radius: 4
                                        color: "#e50914"
                                        SequentialAnimation on opacity {
                                            loops: Animation.Infinite
                                            running: isGenreLoading
                                            PauseAnimation { duration: index * 150 }
                                            NumberAnimation { to: 1; duration: 250 }
                                            NumberAnimation { to: 0.2; duration: 250 }
                                            PauseAnimation { duration: (3 - index) * 150 }
                                        }
                                    }
                                }
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Loading movies..."
                                color: "#666666"
                                font.pixelSize: 12
                            }
                        }

                        // Empty / No results message
                        Text {
                            anchors.centerIn: parent
                            text: "No movies found in this genre."
                            color: "#666666"
                            font.pixelSize: 14
                            visible: !isGenreLoading && genreMovies.length === 0
                        }

                        /*============left/right arrow buttons le horizontal scroll bar lai replace gareko
                          for better ui and ux
                        */
                        Item {
                            id: genreRow
                            anchors.fill: parent
                            visible: !isGenreLoading && genreMovies.length > 0
                            //========clip gareko thiyena bhane ekkai choti ma sabbai movies lai draw garera rakhthyo, 
                            //clip gareko vayera limited lai matra draw garcha
                            clip: true 

                            ListView {
                                id: genreList
                                anchors.fill: parent
                                orientation: ListView.Horizontal
                                spacing: 16 //=======movie cards bich ko spacing
                                interactive: true //======mouse le drag garera pani move garna milcha
                                clip: true
                                model: genreMovies
                                //=====delegate le each component of the list kasto huncha bhanera moviecards define garcha
                                delegate: MovieCard { 
                                    movie_title:  modelData.title   || "" //===== if title else null 
                                    movie_year:   modelData.year    || ""
                                    movie_genre:  modelData.genre   || ""
                                    //*+*+*+*+*+ Removed movie_rating — no longer passed to MovieCard **+*+*+*+*
                                    poster_url:   modelData.poster_url || ""
                                    onCardClicked: homePage.openDetail(modelData)
                                }
                                //contentX (horizontal scroll x coords) lai instantly hoina 
                                //instead animated transition banayera value change garcha
                                Behavior on contentX { 
                                    //===== 300ms time laune, start slow and accelerate in the middle
                                    NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } 
                                }
                            }

                            Rectangle {
                                width: 36; height: parent.height
                                anchors.left: parent.left
                                //====== when we are at the first movie or when horizontal scroll is 0 tetikhera < lai hide garne
                                visible: genreList.contentX > 0 
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: "#cc0f0f0f" }
                                    GradientStop { position: 1.0; color: "transparent" }
                                }
                                Text {
                                    anchors.centerIn: parent
                                    text: "❮"
                                    color: genreLeftMouse.containsMouse ? "#ffffff" : "#aaaaaa" //====== mouse hover garda white else grey
                                    font.pixelSize: 20; font.bold: true
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                                MouseArea {
                                    id: genreLeftMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    //===== 1 movie card = 160px, spacing = 16 px total 176 pixel, so 176 pixel left move garcha 
                                    //meaning euta bata arko moviecard ma jancha, and if value -ve aayo bhane instead 0 set garcha
                                    onClicked: genreList.contentX = Math.max(0, genreList.contentX - 176) 
                                }
                            }

                            Rectangle {
                                width: 36; height: parent.height
                                anchors.right: parent.right
                                //====list ko end ma gayepachi > lai hide garcha (contentwidth = width of all item in list, 
                                //width = width of content visible in screen
                                visible: genreList.contentX < genreList.contentWidth - genreList.width 
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: "transparent" }
                                    GradientStop { position: 1.0; color: "#cc0f0f0f" }
                                }
                                Text {
                                    anchors.centerIn: parent
                                    text: "❯"
                                    color: genreRightMouse.containsMouse ? "#ffffff" : "#aaaaaa"
                                    font.pixelSize: 20; font.bold: true
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                                MouseArea {
                                    id: genreRightMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    //===== if content last element ma cha bhane contentwidth - width = 0 , and contentX + 176 = greater so, 
                                    //min = 0 hence move gardaina, aru case ma contenX + 176 < contentwidth - width so 176 right move garcha
                                    onClicked: genreList.contentX = Math.min(genreList.contentWidth - genreList.width, genreList.contentX + 176)
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

                    /*============left/right arrow buttons le horizontal scroll bar lai replace gareko
                      for better ui and ux
                    */
                    Item {
                        id: topPicksRow
                        width: parent.width - 32
                        height: 250
                        //========clip gareko thiyena bhane ekkai choti ma sabbai movies lai draw garera rakhthyo, 
                        //clip gareko vayera limited lai matra draw garcha
                        clip: true 

                        ListView {
                            id: topPicksList
                            anchors.fill: parent
                            orientation: ListView.Horizontal
                            spacing: 16 //=======movie cards bich ko spacing
                            interactive: true //======mouse le drag garera pani move garna milcha
                            clip: true
                            model: topPicks
                            //=====delegate le each component of the list kasto huncha bhanera moviecards define garcha
                            delegate: MovieCard { 
                                movie_title:  modelData.title   || "" //===== if title else null 
                                movie_year:   modelData.year    || ""
                                movie_genre:  modelData.genre   || ""
                                //*+*+*+*+*+ Removed movie_rating — no longer passed to MovieCard **+*+*+*+*
                                poster_url:   modelData.poster_url || ""
                                onCardClicked: homePage.openDetail(modelData)
                            }
                            //contentX (horizontal scroll x coords) lai instantly hoina 
                            //instead animated transition banayera value change garcha
                            Behavior on contentX { 
                                //===== 300ms time laune, start slow and accelerate in the middle
                                NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } 
                            }
                        }

                        Rectangle {
                            width: 36; height: parent.height
                            anchors.left: parent.left
                            //====== when we are at the first movie or when horizontal scroll is 0 tetikhera < lai hide garne
                            visible: topPicksList.contentX > 0 
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "#cc0f0f0f" }
                                GradientStop { position: 1.0; color: "transparent" }
                            }
                            Text {
                                anchors.centerIn: parent
                                text: "❮"
                                color: topLeftMouse.containsMouse ? "#ffffff" : "#aaaaaa" //====== mouse hover garda white else grey
                                font.pixelSize: 20; font.bold: true
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                            MouseArea {
                                id: topLeftMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                //===== 1 movie card = 160px, spacing = 16 px total 176 pixel, so 176 pixel left move garcha 
                                //meaning euta bata arko moviecard ma jancha, and if value -ve aayo bhane instead 0 set garcha
                                onClicked: topPicksList.contentX = Math.max(0, topPicksList.contentX - 176) 
                            }
                        }

                        Rectangle {
                            width: 36; height: parent.height
                            anchors.right: parent.right
                            //====list ko end ma gayepachi > lai hide garcha (contentwidth = width of all item in list, 
                            //width = width of content visible in screen
                            visible: topPicksList.contentX < topPicksList.contentWidth - topPicksList.width 
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "transparent" }
                                GradientStop { position: 1.0; color: "#cc0f0f0f" }
                            }
                            Text {
                                anchors.centerIn: parent
                                text: "❯"
                                color: topRightMouse.containsMouse ? "#ffffff" : "#aaaaaa"
                                font.pixelSize: 20; font.bold: true
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                            MouseArea {
                                id: topRightMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                //===== if content last element ma cha bhane contentwidth - width = 0 , and contentX + 176 = greater so, 
                                //min = 0 hence move gardaina, aru case ma contenX + 176 < contentwidth - width so 176 right move garcha
                                onClicked: topPicksList.contentX = Math.min(topPicksList.contentWidth - topPicksList.width, topPicksList.contentX + 176)
                            }
                        }
                    }
                }
            }
        }
    }
}