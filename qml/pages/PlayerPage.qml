import QtQuick                      // base QML elements
import QtQuick.Controls             // Slider, Button
import QtQuick.Layouts              // RowLayout for controls
import QtMultimedia                 // MediaPlayer, VideoOutput - plays actual video

Rectangle {
    id: playerPage
    anchors.fill: parent
    color: "#000000"        //pure black background

    //Properties
    property var appStack: null     // StackView reference for back navigation
    property string video_url: ""   // video URL from DetailsPage

    //Media player - It doesnot display anything itself, VideoOutput does
    MediaPlayer {
        id: media_player
        source: playerPage.video_url    // the video URL from internet archieve
        videoOutput: video_output       // connects player to the display
        audioOutput: AudioOutput {}     // handles audio, required separately in Qt6

        // fires when playback position changes, updates our seek bar
        onPositionChanged: {
            if (!seek_bar.pressed) {    // dont update bar while user is dragging it
                seek_bar.value = media_player.position
            }
        }
        // fires when video is fully loaded and duration is known
        onDurationChanged: {
            seek_bar.to = media_player.duration    // set seekbar max to video length
        }
    }

    // Video Output
    // VideoOutput is the visual element which render video frames and fills the whole screen
    VideoOutput {
        id: video_output
        anchors.fill: parent        //fill full Screen
    }

    // Control Visibility timer
    Timer {                     //hides button when inactive for 3 seconds
        id: hide_timer
        interval: 3000          // 3000ms = 3 seconds
        running: true           // starts immediately when page loads
        repeat: false           // only fires once per trigger
        onTriggered: {
            controls_overlay.opacity = 0    // fade out controls
        }
    }

    //Mouse tracker - invisible layer covering whole screen for mouse movement to show controls again
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton    // not to block clicks on controls below

        onPositionChanged: {
            controls_overlay.opacity = 1    // show controls on mouse move
            hide_timer.restart()            // reset 3 second countdown
        }

        onClicked: {
            controls_overlay.opacity = 1    // show controls when mouse clicked
            hide_timer.restart()            // reset 3 second countdown
        }
    }

    // Controls - contains all UI controls that fades in and out
    Item {
        id: controls_overlay
        anchors.fill: parent
        opacity: 1              // visible at start

        Behavior on opacity {
            NumberAnimation {
                duration: 300   // smooth fase animation : 300ms
            }
        }

        // Top Bar - gradient from black at top to transparent going down so back buttons is readable in each content
        Rectangle {
            id: top_bar
            anchors.top: parent.top
            width: parent.width
            height: 100

            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "#cc000000" }      // dark at top
                GradientStop { position: 1.0; color: "transparent" }
            }

            // Back button at top left
            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.leftMargin: 20
                anchors.topMargin: 14
                width: 90
                height: 36
                radius: 6
                color: back_button_area.containsMouse ? "#44ffffff" : "transparent"     //changes color when mouse is hovering on it

                Behavior on color {
                    ColorAnimation {
                        duration: 150       // Animation
                    }
                }

                Row {
                    anchors.centerIn: parent        //centre of its block
                    spacing: 6

                    Text {
                        text: "◀"
                        color: "#ffffff"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Back"
                        color: "#ffffff"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: back_button_area
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        media_player.stop()
                        if (playerPage.appStack) {
                            playerPage.appStack.pop()       // if clicked - return to Details Page
                        }
                    }
                }
            }
        }

        // bottom bar - gradient from transparent at top to black at bottom
        Rectangle {
            id: bottom_bar
            anchors.bottom: parent.bottom
            width: parent.width
            height: 120

            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: "#cc000000" }      // dark at bottom
            }

            Column {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 24
                anchors.rightMargin: 24
                anchors.bottomMargin: 16
                spacing: 8

                // Seek bar - video play row
                RowLayout {
                    width: parent.width
                    spacing: 12

                    Text {                             //surrent playback time
                        text: formatTime(media_player.position)
                        color: "#ffffff"
                        font.pixelSize: 13
                        Layout.preferredWidth: 45
                    }

                    // red seek bar
                    Slider {
                        id: seek_bar
                        Layout.fillWidth: true
                        from: 0
                        to: 1
                        value: 0

                        onPressedChanged: {
                            if (!pressed) {
                                media_player.position = value
                            }
                        }

                        // full track - grey and progress track - red
                        background: Rectangle {
                            x: seek_bar.leftPadding
                            y: seek_bar.topPadding + seek_bar.availableHeight / 2 - height / 2
                            width: seek_bar.availableWidth
                            height: 4
                            radius: 2
                            color: "#3a3a3a"

                            Rectangle {
                                width: seek_bar.visualPosition * parent.width
                                height: parent.height
                                radius: 2
                                color: "#e50914"    // red progress bar
                            }
                        }

                        // white circle handle
                        handle: Rectangle {
                            x: seek_bar.leftPadding + seek_bar.visualPosition *(seek_bar.availableWidth - width)
                            y: seek_bar.topPadding + seek_bar.availableHeight / 2 - height / 2
                            width: 14
                            height: 14
                            radius: 7
                            color: "#ffffff"
                        }
                    }
                    Text {              //total duration
                        text: formatTime(media_player.duration)
                        color: "#aaaaaa"
                        font.pixelSize: 13
                        Layout.preferredWidth: 55
                    }
                }

                // Row of buttons
                RowLayout {
                    width: parent.width

                    Rectangle {         // Play / Pause button
                        width: 48
                        height: 48
                        radius: 24
                        color: play_pause_area.containsMouse ? "#ff0a16" : "#e50914"        //changes color on hover
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: media_player.playbackState === MediaPlayer.PlayingState ? "⏸" : "▶"
                            font.pixelSize: 20
                            color: "#ffffff"
                        }

                        MouseArea {
                            id: play_pause_area
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (media_player.playbackState === MediaPlayer.PlayingState) {
                                    media_player.pause()
                                } else {
                                    media_player.play()
                                }
                            }
                        }
                    }

                    Rectangle {         //-10 seconds button
                        width: 42
                        height: 42
                        radius: 21
                        color: skip_back_area.containsMouse ? "#44ffffff" : "transparent"       // changes color in hover
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        Text {          //symbol
                            anchors.centerIn: parent
                            text: "⏮"
                            font.pixelSize: 22
                            color: "#ffffff"
                        }

                        MouseArea {     //clickable area
                            id: skip_back_area
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                media_player.position = Math.max(0,media_player.position - 10000)
                            }
                        }
                    }

                    Rectangle {         //+10 seconds button
                        width: 42
                        height: 42
                        radius: 21
                        color: skip_fwd_area.containsMouse ? "#44ffffff" : "transparent"        //changes color on hover
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        Text {          //symbol
                            anchors.centerIn: parent
                            text: "⏭"
                            font.pixelSize: 22
                            color: "#ffffff"
                        }

                        MouseArea {     //clickable area
                            id: skip_fwd_area
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                media_player.position = Math.min(media_player.duration,media_player.position + 10000)
                            }
                        }
                    }

                    // spacer pushed right side buttons to the right
                    Item {
                        Layout.fillWidth: true
                    }

                    //setting button placeholder
                    Rectangle {
                        width: 42
                        height: 42
                        radius: 21
                        color: settings_area.containsMouse ? "#44ffffff" : "transparent"        // change color on hover
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "⚙"
                            font.pixelSize: 22
                            color: "#ffffff"
                        }

                        MouseArea {
                            id: settings_area
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                console.log("Settings clicked")         // TODO: later if time is left
                            }
                        }
                    }

                    //full screen button placeholder
                    Rectangle {
                        width: 42
                        height: 42
                        radius: 21
                        color: fullscreen_area.containsMouse ? "#44ffffff" : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: "⛶"
                            font.pixelSize: 22
                            color: "#ffffff"
                        }

                        MouseArea {
                            id: fullscreen_area
                            width: parent.width
                            height: parent.height
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (Window.window.visibility === Window.FullScreen) {
                                    Window.window.visibility = Window.Maximized
                                } else {
                                    Window.window.visibility = Window.FullScreen
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Time converter : converts milliseconds to hh:mm:ss
    function formatTime(ms) {
        if (ms <= 0) return "00:00"
        var total_seconds = Math.floor(ms / 1000)
        var hours = Math.floor(total_seconds / 3600)
        var minutes = Math.floor((total_seconds % 3600) / 60)
        var seconds = total_seconds % 60
        var mm = minutes < 10 ? "0" + minutes : minutes
        var ss = seconds < 10 ? "0" + seconds : seconds
        if (hours > 0) {
            var hh = hours < 10 ? "0" + hours : hours
            return hh + ":" + mm + ":" + ss
        }
        return mm + ":" + ss
    }

    Component.onCompleted: {        // autoplay when page loads
        if (video_url !== "") {
            media_player.play()
        }
    }
}

