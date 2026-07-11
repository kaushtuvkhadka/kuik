import QtQuick
import QtQuick.Controls

// --- Signup Page ---
// Shown when the app starts AND no account exists yet.
// Collects a username + password, saves it via accountManager (C++),
// then moves forward to the home page
Rectangle {
    id: signupPage
    color: "#0f0f0f"   // Theme similar to rest of the app (opaque)

    // Set by whoever loads this page (Main.qml) so we can push new pages
    property var appStack: null

    // Shows an error message below the form (e.g. wrong input, limit reached)
    property string errorMsg: ""

    // --- Centered signup card ---
    Rectangle {
        id: card
        width: 360
        height: 360
        radius: 10
        color: "#1a1a1a"          // Slightly lighter panel color, fully opaque
        border.color: "#3a3a3a"
        border.width: 1
        anchors.centerIn: parent

        Column {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            // App name, styled like the KUik Logo
            Text {
                text: "KUik"
                color: "#e50914"
                font.pixelSize: 26
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "Create your account"
                color: "#aaaaaa"
                font.pixelSize: 14
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // --- Username field ---
            Rectangle {
                width: parent.width
                height: 40
                radius: 6
                color: "#2a2a2a"
                border.color: usernameInput.activeFocus ? "#e50914" : "#3a3a3a"     //changes color nn hover
                border.width: 1

                TextInput {
                    id: usernameInput
                    anchors.fill: parent
                    anchors.margins: 10
                    color: "#ffffff"
                    font.pixelSize: 14
                    clip: true
                    verticalAlignment: Text.AlignVCenter

                    // Placeholder text : hidden once user types something
                    Text {
                        anchors.fill: parent
                        text: "Username"
                        color: "#666666"
                        font.pixelSize: 14
                        verticalAlignment: Text.AlignVCenter
                        visible: !usernameInput.text && !usernameInput.activeFocus
                    }
                }
            }

            // --- Password field ---
            Rectangle {
                width: parent.width
                height: 40
                radius: 6
                color: "#2a2a2a"
                border.color: passwordInput.activeFocus ? "#e50914" : "#3a3a3a"     //change color on hover
                border.width: 1

                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.margins: 10
                    color: "#ffffff"
                    font.pixelSize: 14
                    clip: true
                    verticalAlignment: Text.AlignVCenter
                    echoMode: TextInput.Password   // Hides typed characters with dots for privacy

                    Text {
                        anchors.fill: parent
                        text: "Password"
                        color: "#666666"
                        font.pixelSize: 14
                        verticalAlignment: Text.AlignVCenter
                        visible: !passwordInput.text && !passwordInput.activeFocus
                    }
                }
            }

            // --- Error message (only visible when there's something to show) ---
            Text {
                text: signupPage.errorMsg
                color: "#e50914"
                font.pixelSize: 12
                visible: signupPage.errorMsg.length > 0
                width: parent.width
                wrapMode: Text.WordWrap
            }

            // --- Sign Up button ---
            Rectangle {
                width: parent.width
                height: 42
                radius: 6
                color: "#e50914"

                Text {
                    anchors.centerIn: parent
                    text: "Sign Up"
                    color: "#ffffff"
                    font.pixelSize: 15
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        // Basic validation before calling into C++
                        if (usernameInput.text.length === 0 || passwordInput.text.length === 0) {
                            signupPage.errorMsg = "Please fill in both fields."
                            return
                        }

                        // accountManager.signup() returns true/false (see accountmanager.cpp)
                        var success = accountManager.signup(usernameInput.text, passwordInput.text)

                        if (success) {
                            // Move to the home page, replacing this page in the stack
                            // so the user can't press "back" into signup again
                            appStack.replace(null, homePageComponent)
                        } else {
                            signupPage.errorMsg = "Signup failed (account limit reached?)."
                        }
                    }
                }
            }

            // --- Link to Login page (in case an account already exists) ---
            Text {
                text: "Already have an account? Log in"
                color: "#888888"
                font.pixelSize: 12
                anchors.horizontalCenter: parent.horizontalCenter

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        appStack.replace(null, Qt.resolvedUrl("Login.qml"))     // Switch to the Login page
                    }
                }
            }
        }
    }
}