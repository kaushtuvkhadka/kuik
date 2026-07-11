import QtQuick
import QtQuick.Controls

// --- Login Page ---
// Shown when the app starts AND at least one account already exists
// Checks username + password against saved accounts via accountManager (C++).
Rectangle {
    id: loginPage
    color: "#0f0f0f"   // Same opaque background as the rest of the app

    property var appStack: null
    property string errorMsg: ""

    // --- Centered login card ---
    Rectangle {
        id: card
        width: 360
        height: 320
        radius: 10
        color: "#1a1a1a"
        border.color: "#3a3a3a"
        border.width: 1
        anchors.centerIn: parent

        Column {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            Text {
                text: "KUik"
                color: "#e50914"
                font.pixelSize: 26
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "Log in to your account"
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
                border.color: usernameInput.activeFocus ? "#e50914" : "#3a3a3a"     //changes color on hover
                border.width: 1

                TextInput {
                    id: usernameInput
                    anchors.fill: parent
                    anchors.margins: 10
                    color: "#ffffff"
                    font.pixelSize: 14
                    clip: true
                    verticalAlignment: Text.AlignVCenter

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
                border.color: passwordInput.activeFocus ? "#e50914" : "#3a3a3a"     //changes color on hover
                border.width: 1

                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.margins: 10
                    color: "#ffffff"
                    font.pixelSize: 14
                    clip: true
                    verticalAlignment: Text.AlignVCenter
                    echoMode: TextInput.Password

                    Text {
                        anchors.fill: parent
                        text: "Password"
                        color: "#666666"
                        font.pixelSize: 14
                        verticalAlignment: Text.AlignVCenter
                        visible: !passwordInput.text && !passwordInput.activeFocus
                    }

                    // Pressing Enter also submits, like a normal website
                    Keys.onReturnPressed: loginButton.doLogin()
                }
            }

            Text {
                text: loginPage.errorMsg
                color: "#e50914"
                font.pixelSize: 12
                visible: loginPage.errorMsg.length > 0
                width: parent.width
                wrapMode: Text.WordWrap
            }

            // --- Log In button ---
            Rectangle {
                id: loginButton
                width: parent.width
                height: 42
                radius: 6
                color: "#e50914"

                // Small helper function so both the click and Enter key
                // can trigger the exact same logic without repeating code
                function doLogin() {
                    if (usernameInput.text.length === 0 || passwordInput.text.length === 0) {
                        loginPage.errorMsg = "Please fill in both fields."
                        return
                    }

                    var success = accountManager.login(usernameInput.text, passwordInput.text)

                    if (success) {
                        appStack.replace(null, homePageComponent)
                    } else {
                        loginPage.errorMsg = "Incorrect username or password."
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "Log In"
                    color: "#ffffff"
                    font.pixelSize: 15
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: loginButton.doLogin()
                }
            }

            // --- Link to Signup (in case a 2nd account slot is free) --
            Text {
                text: "Need an account? Sign up"
                color: "#888888"
                font.pixelSize: 12
                anchors.horizontalCenter: parent.horizontalCenter

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        appStack.replace(null, Qt.resolvedUrl("Signup.qml"))
                    }
                }
            }
        }
    }
}