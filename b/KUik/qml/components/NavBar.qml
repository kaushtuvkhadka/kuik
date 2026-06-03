import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {     //NavBar itself. Everything sits inside it
    id: navBar
    height: 56
    color: "#1a1a1a"    //navbar background : very dark gray

    signal searchRequested(string query)    // notification system. When search is typed, NavBar calls searchRequested() and who is listening (HomePage) reacts
    signal menuClicked()

    RowLayout {     //aranges child functions : KUik text, search bar, hamburger button.
        anchors.fill: parent    //parent means fill entire block
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        spacing: 16     // puts space of 16x between each children

        Text{   //KUik logo : just display text not interactive
            text: "KUik"
            color: "e50914"     //KUik logo : dark red
            font.pixelSize: 24
            font.bold: true
            font.letterSpacing: 1.5     //spreads characters apart for logo feel
        }

        Rectangle {     //Search bar - outer box
            Layout.fillWidth: true      //stretches to fill all space between logo and hamburger
            height: 34
            radius: 6       // rounded smooth cornors
            color: "#2a2a2a"       //Search bar background : slightly brighter than navbar
            border.color: search_input.activeFocus ? "#e50914" : "#3a3a3a"  // changes search bar border color which is normally dark to red : true when user clicked inside the element ((false)#3a3a3a ->(false)#e50914)
            border.width: 1

            RowLayout {     //Search bar - inner layout
                anchors.fill: parent
                anchors.leftMargin: 10      // arranges the text input and search icon side by side with padding
                anchors.rightMargin: 10     // paddings : 10
                spacing: 6

                TextInput {     //Text Input - where we can type
                    id: search_input
                    Layout.fillWidth: true
                    color: "#ffffff"    // color of text you type in search (white)
                    font.pixelSize: 14
                    clip: true      //responsible for text not overflowing out of the box
                    verticalAlignment: Text.AlignVCenter

                    Text {      //Place holder text : disappears when user initereact
                        anchors.fill: parent
                        text: "Search Movie"
                        color: "#666666"    //search movie placeholder text (medium gray)
                        font.pixelSize: 14
                        verticalAlignment: Text.AlignVCenter
                        visible: !search_input.text && !search_input.activeFocus
                    }

                    Keys.onReturnPressed: navBar.searchRequested(text)
                }

                Text {      // search icon
                    text: "⌕"
                    color: "#888888"    //search icon light gray
                    font.pixelSize: 10

                    MouseArea {     //mouse area where user can click search
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor      //changes mouse cursor to hand pointer on hovering
                        onClicked: navBar.searchRequested(search_input.text)
                    }
                }
            }
        }
        //hamburger button - setting button
        Rectangle {     //Buttons background
            width: 34
            height: 34
            radius: 6
            color: menu_area.containsMouse ? "#2a2a2a" : "transparent"      //normally transparent, dark on hover

            Column {    //arranges three lines vertically
                anchors.centerIn: parent
                spacing: 5  //space between vertical lines

                Repeater {      //loops three times creating 3 rectangles
                    model: 3

                    Rectangle {     //each inner line of hamburger icon
                        width: 18
                        height: 2
                        radius: 1
                        color: "#ffffff"
                    }
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

    Rectangle {     // one pixel tall line, visual divider between NavBar and page content
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: "#2a2a2a"
    }
}
