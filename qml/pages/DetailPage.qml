import QtQuick                  // base QML elements - Rectangle, Text, etc
import QtQuick.Controls         // control functions like ScrollView, Button
import QtQuick.Layouts          // ColumnLayout, RowLayout
import "../components"          // Custom components like NavBar, Moviecard, etc

Rectangle {
    id: detailPage
    anchors.fill: parent
    color: "#0f0f0f"        //base background color

    // Properties of the movie
    // TODO: Backend calls api and provides required property
    property var appStack: null             // StackView reference for navigation
    property string movie_title: ""         // movie name
    property string movie_year: ""          // release year
    property string movie_genre: ""         // genre
    property string movie_rating: ""        // rating
    property string movie_description: ""   // full description text
    property string poster_url: ""          // poster image URL
    property string video_url: ""           // video URL of the movie
    property var similar_movies: []         // Array becasue there will be many similar movies and only one movie in detail

    // Lay out of details Page
    // Column stacks every component vertically top to bottom
    Column {
        anchors.fill: parent
        spacing: 0

        // Navbar Component
        NavBar {
            id: nav_bar
            width: parent.width
            onSearchRequested: function(query) {    // if search button is clicked
                console.log("Search:", query)   // TODO: push SearchPage later
            }
            onMenuClicked: {
                console.log("Menu clicked")     // TODO: settings panel later
            }
        }

        // ScrollVIew for making page scrollable to access similar movies
        ScrollView {
            width: parent.width
            height: detailPage.height - nav_bar.height      // height of details page = total - navbar
            contentWidth: availableWidth                    // provided from api
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff    // Prevent horizontal Scrolling

            Column {
                width: parent.width
                spacing: 0

                // Big poster Section - Hero Section
                Rectangle {
                    id: hero_section
                    width: parent.width
                    height: 420                 // Posters Height
                    color: "#1a1a1a"            // dark if no poster

                    // Poster Image
                    Image {
                        anchors.fill: parent
                        source: detailPage.poster_url       // From api
                        fillMode: Image.PreserveAspectCrop  // Prevents stretching of image
                        visible: detailPage.poster_url !== ""   // shows poster if poster is available
                    }

                    // Dark overlay at bottom of posert so text on top of poster is readable
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 220

                        // Transparent at top and dark at bottom
                        gradient: Gradient {
                            orientation: Gradient.Vertical
                            GradientStop { position: 0.0; color: "transparent" }    //top - transparent
                            GradientStop { position: 1.0; color: "#0f0f0f" }        //bottom - dark
                        }
                    }

                    // Movie infromation is at bottom left of poster
                    Column {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.margins: 32
                        spacing: 8

                        // Movie Title a bit large and bold to be appealing
                        Text {
                            text: detailPage.movie_title
                            color: "#ffffff"
                            font.pixelSize: 36
                            font.bold: true
                        }

                        // Year, genre and rating in one line sepaerated by dots
                        Text {
                            text: detailPage.movie_year + "  ·  " +     //movie_year
                                  detailPage.movie_genre + "  ·  " +    //movie_genre
                                  detailPage.movie_rating + "/10"       //movie_rating
                            color: "#aaaaaa"                            // lighter gray, less important than title
                            font.pixelSize: 16
                        }
                    }

                    // Watch now botton ar bottom rigth
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.margins: 32
                        width: 140
                        height: 44
                        radius: 6           //smooth edges
                        color: watch_button_area.containsMouse ? "#ff0a16" : "#e50914" //color changes when hovering

                        Behavior on color {     //SmoothedAnimation
                            ColorAnimation { duration: 150 }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "▶  Watch Now"
                            color: "#ffffff"
                            font.pixelSize: 15
                            font.bold: true         //In bold letters
                        }

                        MouseArea {         // where we can click
                            id: watch_button_area      //watch_button_area
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (detailPage.appStack) {
                                    detailPage.appStack.push(
                                        "qrc:/qt/qml/KUik/qml/pages/PlayerPage.qml",
                                        {
                                            video_url: detailPage.video_url,
                                            appStack:  detailPage.appStack
                                        }
                                    )
                                    console.log("clicked watch button")
                                    InternetArchive.fetch(detailPage.movie_title)

                                }
                            }
                        }
                    }
                }

                //Description Section
                Column {        // to be arranged top to bottom
                    width: parent.width
                    spacing: 12
                    topPadding: 24      //padding in four sides top, bottom, left and right
                    bottomPadding: 24
                    leftPadding: 32
                    rightPadding: 32

                    Text {              // About text
                        text: "About"
                        color: "#ffffff"
                        font.pixelSize: 20
                        font.bold: true
                    }

                    Text {              //Description text of the movie
                        text: detailPage.movie_description
                        color: "#cccccc"            // text in very light gray
                        font.pixelSize: 15
                        wrapMode: Text.WordWrap      // wraps at word boundaries
                        width: detailPage.width - 64 // full width minus left (32)+right (32) padding
                        lineHeight: 1.5              // 1.5x line spacing between lines
                    }
                }

                // Similar movie Section
                // TODO: Backend fills similar_movie list from api calls
                // Same structure as home page recommendation

                Column {
                    width: parent.width
                    spacing: 16
                    topPadding: 16
                    bottomPadding: 32
                    leftPadding: 32
                    visible: detailPage.similar_movies.length > 0  // Only shows similar section if there are similar similar movies

                    Text {                  //Title - Similar Movies
                        text: "Similar Movies"
                        color: "#ffffff"
                        font.pixelSize: 20
                        font.bold: true
                    }

                    Row {
                        spacing: 16

                        Repeater {
                            model: detailPage.similar_movies

                            MovieCard {
                                movie_title:  modelData.title
                                movie_year:   modelData.year
                                movie_genre:  modelData.genre
                                movie_rating: modelData.rating
                                poster_url:   modelData.poster_url

                                onCardClicked: {        // Clickign in poster opens detailspage
                                    if (detailPage.appStack) {
                                        detailPage.appStack.push(
                                            "qrc:/qt/qml/KUik/qml/pages/PlayerPage.qml",
                                            {
                                                video_url: detailPage.video_url,
                                                appStack: detailPage.appStack
                                            }
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

