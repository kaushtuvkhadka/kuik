import QtQuick              //for visual elements
import QtQuick.Controls     //gives us scroll view
import QtQuick.Layouts      //gives us column layout
import "../components"      //tells QML to look in the components folder

Rectangle {
    id: homePage
    anchors.fill: parent
    color: "#0f0f0f"        //dark background


    // StackView reference - parent Loader's parent gives us access to root stackView
    property var appStack: null

    // Movie-Data
    // TODO: Backend team fills these from API
    // Expected object format: { title: string, year: string, genre: string, rating: real, poster_url: string }

    property var recommendations: [
        { title: "The Kid", year: "1921", genre: "Comedy", rating: 8.3, poster_url: "", description: "A tramp raises an abandoned child.", video_url: "" }
    ]

    property var top_picks: []

    // Main layout

    // Column stacks childrens vertically: NavBar on top, contents below

    Column {
        anchors.fill: parent
        spacing: 0

        NavBar {    //NavBar Component
            id: nav_bar
            width: parent.width

            // onSearchRequested runs when user hits enter or clicks search WindowContainer
            // query is the text user typed
            onSearchRequested: function(query) {
                console.log("Search:", query)   //TODO: push Searchpage later
            }
            onMenuClicked: {
                console.log("Menu Clicked")     //TODO: settings panel later
            }
        }

        // Scrollable Content
        ScrollView {        // Makes content scrollable when it overflows
            width: parent.width
            height: homePage.height - nav_bar.height
            contentWidth: availableWidth    //Prevents horizontal scroll
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Column {        // Holds all section of page
                width: parent.width
                spacing: 32         // Gaps bewtween recommendation and top picks section
                topPadding: 32      // space at top between first section
                bottomPadding: 32   // space at bottom after last section


                // Recommendation Section
                Column {
                    width: parent.width
                    spacing: 16         // gap between title text and card Row
                    leftPadding: 32     // space from left edge

                    Text {      // Recommensations title
                        text: "Recommenations"
                        color: "#ffffff"
                        font.pixelSize: 18
                        font.bold: true
                    }

                    Row{        // Row arranges Movie cards Horizontally
                        spacing: 16     // gap between each cards

                        //Repeater loops through recommendation list creating one movie card for each item
                        Repeater {
                            model: recommendations      //model data = current data in loop

                            //Pass data from modelData into card properties
                            MovieCard {
                                movie_title: modelData.title
                                movie_year: modelData.year
                                movie_genre: modelData.genre
                                movie_rating: modelData.rating

                                //when card is clicked, open details Page
                                // TODO: push DetailPage with this movie later
                                /*onCardClicked: {
                                    if (homePage.appStack) {
                                        homePage.appStack.push(
                                            "qrc:/qt/qml/KUik/qml/pages/DetailPage.qml",    //open details page if poster clicked
                                            {
                                                movie_title: modelData.title,
                                                movie_year: modelData.year,
                                                movie_genre: modelData.genre,
                                                movie_rating: modelData.rating,
                                                appStack: homePage.appStack
                                            }
                                        )
                                    }
                                }*/
                                onCardClicked: {
                                    console.log("card clicked, appStack:", homePage.appStack)
                                    if (homePage.appStack) {
                                        homePage.appStack.push(
                                            "qrc:/qt/qml/KUik/qml/pages/DetailPage.qml",
                                            {
                                                movie_title:       modelData.title,
                                                movie_year:        modelData.year,
                                                movie_genre:       modelData.genre,
                                                movie_rating:      modelData.rating,
                                                movie_description: modelData.description,
                                                poster_url:        modelData.poster_url,
                                                video_url:         modelData.video_url,
                                                appStack:          homePage.appStack
                                            }
                                        )
                                    }
                                }
                            }
                        }
                    }
                }

                // Top Picks Section
                // Same structure as Recommendation but different data
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

                    Row {
                        spacing: 16

                        Repeater {
                            model: top_picks

                            MovieCard {
                                movie_title: modelData.title
                                movie_year: modelData.year
                                movie_genre: modelData.genre
                                movie_rating: modelData.rating

                                /*onCardClicked: {
                                    if (homePage.appStack) {
                                        homePage.appStack.push(
                                            "qrc:/qt/qml/KUik/qml/pages/DetailPage.qml",    //open details page if poster clicked
                                            {
                                                movie_title: modelData.title,
                                                movie_year: modelData.year,
                                                movie_genre: modelData.genre,
                                                movie_rating: modelData.rating,
                                                appStack: homePage.appStack
                                            }
                                        )
                                    }
                                }*/
                                onCardClicked: {
                                    if (homePage.appStack) {
                                        var component = Qt.appStack.push(
                                            "qrc:/qt/qml/KUik/qml/pages/DetailPage.qml")
                                        var page = component.createObject(null, {
                                            movie_title: modelData.title,
                                            movie_year: modelData.year,
                                            movie_genre: modelData.genre,
                                            movie_rating: modelData.rating,
                                            movie_description: modelData.description,
                                            poster_url: modelData.poster_url,
                                            video_url: modelData.video_url,
                                            appStack: homePage.appStack
                                        })
                                        homePage.appStack.push(page)
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
