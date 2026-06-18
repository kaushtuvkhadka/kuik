import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Item {
    id: playerPage

    // DetailsPage parameters passed during navigation
    property var    appStack:    null
    property string video_url:   "" // Video URL to stream or download
    property string movie_title: ""

    // UI State and Feature Flags
    property bool  settingsOpen:  false
    property real  playbackSpeed: 1.0

    // Backend Core Instance
    // Automatically hooked into your C++ QML_ELEMENT class
    ArchiveAPI {
        id: archiveApi

        // Handle errors emitted by startDownload() or search routines
        onErrorOccurred: (errorString) => {
            error_text.text = errorString
            error_banner.visible = true
        }
    }

    // Background Layer
    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    // Native Media Processing Pipeline
    MediaPlayer {
        id: media_player
        source: playerPage.video_url
        videoOutput: video_output
        audioOutput: AudioOutput {
            volume: vol_slider.value / 100.
        }

        onPositionChanged: {
            if (!seek_bar.pressed)
                seek_bar.value = media_player.position
        }
        onDurationChanged: {
            seek_bar.to = media_player.duration
        }
        onPlaybackStateChanged: {
            hide_timer.restart() // Restart the auto-fade timer on playback events
            controls_overlay.opacity = 1
        }
        onErrorOccurred: function(error, errorString) {
            error_text.text = "Playback error: " + errorString
            error_banner.visible = true
        }
    }

    // Video Rendering Surface
    VideoOutput {
        id: video_output
        anchors.fill: parent
    }

    // Controls Auto-Hide Management
    Timer {
        id: hide_timer
        interval: 3500
        running: true
        repeat: false
        onTriggered: {
            if (media_player.playbackState === MediaPlayer.PlayingState)
                controls_overlay.opacity = 0
        }
    }

    // Global Overlay Toggle Input Capture
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        onPositionChanged: { controls_overlay.opacity = 1; hide_timer.restart() }
        onClicked:         { controls_overlay.opacity = 1; hide_timer.restart() }
    }

    // Notification and Error Banner Alert Component
    Rectangle {
        id: error_banner
        visible: false
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 80

        width: error_text.width + 40
        height: 40
        radius: 6
        color: "#cc330000"
        border.color: "#e50914"
        border.width: 1
        z: 20

        Text {
            id: error_text
            anchors.centerIn: parent
            color: "#ffaaaa"
            font.pixelSize: 13
        }
        MouseArea {
            anchors.fill: parent
            onClicked: error_banner.visible = false
        }
    }

    // Slide-out Audio & Speed Adjustment Settings Control Panel
    Rectangle {
        id: settings_panel
        width: 230
        height: settings_col.implicitHeight + 32
        radius: 10
        color: "#f0111111"
        border.color: "#2a2a2a"
        border.width: 1
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 118
        anchors.rightMargin: 20
        z: 10
        visible: settingsOpen
        opacity: settingsOpen ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 180 } }

        Column {
            id: settings_col
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 16
            spacing: 20

            Text { text: "Settings"; color: "#ffffff"; font.pixelSize: 13; font.bold: true }

            // Playback Speed Controls Selector
            Column {
                width: parent.width
                spacing: 8
                Text { text: "Playback Speed"; color: "#aaaaaa"; font.pixelSize: 11 }
                Row {
                    spacing: 6
                    Repeater {
                        model: [
                            { label: "0.5×",  rate: 0.5  },
                            { label: "0.75×", rate: 0.75 },
                            { label: "1×",    rate: 1.0  },
                            { label: "1.5×",  rate: 1.5  },
                            { label: "2×",    rate: 2.0  }
                        ]
                        Rectangle {
                            width: sp_lbl.width + 14; height: 26; radius: 13
                            color: playerPage.playbackSpeed === modelData.rate ? "#e50914" : "#2a2a2a"
                            border.color: playerPage.playbackSpeed === modelData.rate ? "#e50914" : "#3a3a3a"
                            border.width: 1
                            Text {
                                id: sp_lbl
                                anchors.centerIn: parent
                                text: modelData.label; color: "#ffffff"; font.pixelSize: 11
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    playerPage.playbackSpeed  = modelData.rate
                                    media_player.playbackRate = modelData.rate
                                }
                            }
                        }
                    }
                }
            }

            // Audio Level Configuration Slider
            Column {
                width: parent.width
                spacing: 8
                Text { text: "Volume  " + Math.round(vol_slider.value) + "%"; color: "#aaaaaa"; font.pixelSize: 11 }

                Slider {
                    id: settings_vol
                    width: parent.width
                    from: 0; to: 100; value: vol_slider.value
                    onValueChanged: vol_slider.value = value
                }
            }
        }
    }

    // Unified HUD Control HUD Layout Containers
    Item {
        id: controls_overlay
        anchors.fill: parent
        opacity: 1
        Behavior on opacity { NumberAnimation { duration: 350 } }

        // Top Navigation Title Bar Element
        Rectangle {
            anchors.top: parent.top
            width: parent.width; height: 80
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "#bb000000" }
                GradientStop { position: 1.0; color: "transparent" }
            }
            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 16
                spacing: 12

                // Navigation Pop Back Command Button
                Rectangle {
                    width: 32; height: 32; radius: 16
                    color: back_ma.containsMouse ? "#44ffffff" : "transparent"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Text { anchors.centerIn: parent; text: "◀"; color: "#fff"; font.pixelSize: 14 }

                    MouseArea {
                        id: back_ma
                        anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            media_player.stop()
                            if (playerPage.appStack)
                                playerPage.appStack.pop()
                        }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: playerPage.movie_title
                    color: "#ffffff"; font.pixelSize: 15; font.bold: true
                    elide: Text.ElideRight
                    width: playerPage.width - 180
                }
            }
        }

        // Bottom Timeline Position & Action Control Strip Bar
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width; height: 110
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: "#dd000000" }
            }

            Column {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                anchors.bottomMargin: 12
                spacing: 4

                // Seek Progress Slider Metrics Tracker Strip
                RowLayout {
                    width: parent.width
                    spacing: 10

                    Text {
                        text: formatTime(media_player.position)
                        color: "#ffffff"; font.pixelSize: 12
                        Layout.preferredWidth: 45
                    }

                    Slider {
                        id: seek_bar
                        Layout.fillWidth: true
                        from: 0; to: 1; value: 0
                        onPressedChanged: {
                            if (!pressed) media_player.position = value
                        }
                    }

                    Text {
                        text: formatTime(media_player.duration)
                        color: "#888888"; font.pixelSize: 12
                        Layout.preferredWidth: 45
                        horizontalAlignment: Text.AlignRight
                    }
                }

                // Core Playback Controls & Utility Bar Components Toggle Row
                RowLayout {
                    width: parent.width
                    spacing: 2

                    // Primary Play / Pause State Controller Switch
                    CtrlBtn {
                        btnIcon: media_player.playbackState === MediaPlayer.PlayingState ? "⭕" : "▶"
                        onBtnClicked: {
                            if (media_player.playbackState === MediaPlayer.PlayingState)
                                media_player.pause()
                            else
                                media_player.play()
                        }
                    }

                    // Seek Backward 10 Seconds
                    CtrlBtn {
                        btnIcon: "↺"
                        onBtnClicked: media_player.position = Math.max(0, media_player.position - 10000)
                    }

                    // Seek Forward 10 Seconds
                    CtrlBtn {
                        btnIcon: "↻"
                        onBtnClicked: media_player.position = Math.min(media_player.duration, media_player.position + 10000)
                    }

                    Item { Layout.fillWidth: true } // Expandable Spacer Block Component

                    // Audio Mode Indicator Symbol Flag
                    Text {
                        text: vol_slider.value === 0 ? "🔇" : vol_slider.value < 50 ? "🔉" : "🔊"
                        color: "#ffffff"; font.pixelSize: 15
                        Layout.alignment: Qt.AlignVCenter
                    }

                    // Direct Action Audio Volume Adjust Track Slider
                    Slider {
                        id: vol_slider
                        width: 80; from: 0; to: 100; value: 80
                        Layout.alignment: Qt.AlignVCenter
                    }

                    // Options Control Menu Layer Toggle Button Layout
                    CtrlBtn {
                        btnIcon: "⚙"
                        active: settingsOpen
                        onBtnClicked: settingsOpen = !settingsOpen
                    }

                    // Asynchronous Local System Downloads Storage Hook Button Entry
                    CtrlBtn {
                        btnIcon: "🡻"
                        onBtnClicked: {
                            // Safely invokes the non-static download execution pipeline method inside your ArchiveAPI object model wrapper instance
                            archiveApi.startDownload(playerPage.video_url)
                        }
                    }

                    // Device App Window Fullscreen Aspect State Alternator Modality
                    CtrlBtn {
                        btnIcon: "⛶"
                        onBtnClicked: {
                            var w = Window.window
                            w.visibility = w.visibility === Window.FullScreen
                                           ? Window.Maximized
                                           : Window.FullScreen
                        }
                    }
                }
            }
        }
    }

    // Inline Reusable Custom Styled Control Button Template Object Factory Implementation
    component CtrlBtn: Rectangle {
        property string btnIcon: ""
        property bool   active:  false
        signal btnClicked()

        width: 34; height: 34; radius: 17
        color: active ? "#33e50914"
                      : _ma.containsMouse ? "#33ffffff" : "transparent"

        Behavior on color { ColorAnimation { duration: 120 } }
        Layout.alignment: Qt.AlignVCenter

        Text {
            anchors.centerIn: parent
            text: parent.btnIcon
            color: parent.active ? "#e50914" : "#ffffff"
            font.pixelSize: 16
        }
        MouseArea {
            id: _ma
            anchors.fill: parent; hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.btnClicked()
        }
    }

    // Human Readable Media Time Unit Transformation Engine Formatting Routine
    function formatTime(ms) {
        if (ms <= 0) return "00:00"
        var s   = Math.floor(ms / 1000)
        var h   = Math.floor(s / 3600)
        var m   = Math.floor((s % 3600) / 60)
        var sec = s % 60
        var mm  = m   < 10 ? "0" + m   : m
        var ss  = sec < 10 ? "0" + sec : sec
        if (h > 0) return (h < 10 ? "0" + h : h) + ":" + mm + ":" + ss
        return mm + ":" + ss
    }

    // Automate Autoplay Launch On Interface Component Render Attachment Execution
    Component.onCompleted: {
        if (video_url !== "") media_player.play()
    }
}