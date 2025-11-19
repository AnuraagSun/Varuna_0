/*
 ═ ═*═════════════════════════════════════════════════════════════
 FILE: qml/components/CommandPanel.qml
 PHASE: Phase 7 - Communication and Control Features
 LOCATION: varuna_ui/qml/components/CommandPanel.qml
 ═══════════════════════════════════════════════════════════════
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ".." as Local

Rectangle {
    id: commandPanel

    color: Local.Constants.cardBackground
    radius: Local.Constants.radiusLarge
    border.color: Local.Constants.borderColor
    border.width: Local.Constants.borderWidthThin

    implicitHeight: 600

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Local.Constants.spacingLarge
        spacing: Local.Constants.spacingLarge

        // Title
        RowLayout {
            Layout.fillWidth: true
            spacing: Local.Constants.spacingSmall

            Rectangle {
                width: 6
                height: 6
                radius: 3
                color: Local.Constants.accentPrimary

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.3; duration: 1500 }
                    NumberAnimation { to: 1.0; duration: 1500 }
                }
            }

            Text {
                text: "📱 Remote Commands"
                font.pixelSize: Local.Constants.fontSizeLarge
                font.bold: true
                font.family: Local.Constants.fontFamily
                color: Local.Constants.textPrimary
            }

            Item { Layout.fillWidth: true }

            StatusIndicator {
                status: commandHandler.isBusy ? "warning" : "ok"
                label: commandHandler.isBusy ? "BUSY" : "READY"
                showPulse: !commandHandler.isBusy
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Local.Constants.borderColor
        }

        // SMS Send Section
        Text {
            text: "Send SMS Command"
            font.pixelSize: Local.Constants.fontSizeMedium
            font.bold: true
            font.family: Local.Constants.fontFamily
            color: Local.Constants.textSecondary
        }

        // Phone Number Input
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Local.Constants.spacingSmall

            Text {
                text: "Recipient Phone Number:"
                font.pixelSize: Local.Constants.fontSizeSmall
                font.family: Local.Constants.fontFamily
                color: Local.Constants.textSecondary
            }

            TextField {
                id: phoneNumberInput
                Layout.fillWidth: true
                placeholderText: "+919876543210"
                font.pixelSize: Local.Constants.fontSizeNormal
                font.family: Local.Constants.fontFamily
                color: Local.Constants.textPrimary

                background: Rectangle {
                    color: Local.Constants.cardBackgroundAlt
                    radius: Local.Constants.radiusSmall
                    border.color: phoneNumberInput.activeFocus ?
                    Local.Constants.accentPrimary :
                    Local.Constants.borderColor
                    border.width: Local.Constants.borderWidthMedium

                    Behavior on border.color {
                        ColorAnimation {
                            duration: Local.Constants.animationDurationFast
                            easing.type: Local.Constants.easingType
                        }
                    }
                }
            }
        }

        // Message Input
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Local.Constants.spacingSmall

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Message:"
                    font.pixelSize: Local.Constants.fontSizeSmall
                    font.family: Local.Constants.fontFamily
                    color: Local.Constants.textSecondary
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: messageInput.text.length + "/160"
                    font.pixelSize: Local.Constants.fontSizeTiny
                    font.family: Local.Constants.fontFamilyMono
                    color: messageInput.text.length > 160 ?
                    Local.Constants.accentDanger :
                    Local.Constants.textTertiary
                }
            }

            TextArea {
                id: messageInput
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                placeholderText: "Enter message (max 160 characters)..."
                font.pixelSize: Local.Constants.fontSizeNormal
                font.family: Local.Constants.fontFamily
                color: Local.Constants.textPrimary
                wrapMode: TextArea.Wrap

                background: Rectangle {
                    color: Local.Constants.cardBackgroundAlt
                    radius: Local.Constants.radiusSmall
                    border.color: messageInput.activeFocus ?
                    Local.Constants.accentPrimary :
                    Local.Constants.borderColor
                    border.width: Local.Constants.borderWidthMedium

                    Behavior on border.color {
                        ColorAnimation {
                            duration: Local.Constants.animationDurationFast
                            easing.type: Local.Constants.easingType
                        }
                    }
                }
            }
        }

        // Send Button
        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: Local.Constants.buttonHeightLarge
            text: "📤 Send SMS"
            enabled: !commandHandler.isBusy &&
            phoneNumberInput.text.length > 0 &&
            messageInput.text.length > 0 &&
            messageInput.text.length <= 160

            onClicked: {
                commandHandler.sendSMS(phoneNumberInput.text, messageInput.text)
                console.log("Sending SMS to:", phoneNumberInput.text)
            }

            background: Rectangle {
                color: parent.enabled ?
                (parent.pressed ? Qt.darker(Local.Constants.accentPrimary, 1.2) :
                parent.hovered ? Qt.lighter(Local.Constants.accentPrimary, 1.1) :
                Local.Constants.accentPrimary) :
                Local.Constants.borderColor
                radius: Local.Constants.radiusMedium

                Behavior on color {
                    ColorAnimation {
                        duration: Local.Constants.animationDurationFast
                        easing.type: Local.Constants.easingType
                    }
                }
            }

            contentItem: Text {
                text: parent.text
                font.pixelSize: Local.Constants.fontSizeMedium
                font.bold: true
                font.family: Local.Constants.fontFamily
                color: parent.enabled ? Local.Constants.textPrimary : Local.Constants.textTertiary
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Local.Constants.borderColor
        }

        // Quick Commands
        Text {
            text: "Quick Commands"
            font.pixelSize: Local.Constants.fontSizeMedium
            font.bold: true
            font.family: Local.Constants.fontFamily
            color: Local.Constants.textSecondary
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: Local.Constants.spacingNormal
            columnSpacing: Local.Constants.spacingNormal

            Button {
                Layout.fillWidth: true
                text: "📊 STATUS"
                onClicked: {
                    messageInput.text = "STATUS"
                    console.log("Quick command: STATUS")
                }

                background: Rectangle {
                    color: parent.pressed ? Qt.darker(Local.Constants.accentPrimary, 1.2) :
                    parent.hovered ? Qt.lighter(Local.Constants.accentPrimary, 1.1) :
                    Local.Constants.cardBackgroundAlt
                    radius: Local.Constants.radiusSmall
                    border.color: Local.Constants.accentPrimary
                    border.width: Local.Constants.borderWidthThin

                    Behavior on color {
                        ColorAnimation { duration: Local.Constants.animationDurationFast }
                    }
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: Local.Constants.fontSizeNormal
                    font.family: Local.Constants.fontFamily
                    color: Local.Constants.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                Layout.fillWidth: true
                text: "🎯 CALIBRATE"
                onClicked: {
                    messageInput.text = "CALIBRATE"
                    console.log("Quick command: CALIBRATE")
                }

                background: Rectangle {
                    color: parent.pressed ? Qt.darker(Local.Constants.accentSuccess, 1.2) :
                    parent.hovered ? Qt.lighter(Local.Constants.accentSuccess, 1.1) :
                    Local.Constants.cardBackgroundAlt
                    radius: Local.Constants.radiusSmall
                    border.color: Local.Constants.accentSuccess
                    border.width: Local.Constants.borderWidthThin

                    Behavior on color {
                        ColorAnimation { duration: Local.Constants.animationDurationFast }
                    }
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: Local.Constants.fontSizeNormal
                    font.family: Local.Constants.fontFamily
                    color: Local.Constants.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                Layout.fillWidth: true
                text: "🔄 RESET"
                onClicked: {
                    messageInput.text = "RESET"
                    console.log("Quick command: RESET")
                }

                background: Rectangle {
                    color: parent.pressed ? Qt.darker(Local.Constants.accentWarning, 1.2) :
                    parent.hovered ? Qt.lighter(Local.Constants.accentWarning, 1.1) :
                    Local.Constants.cardBackgroundAlt
                    radius: Local.Constants.radiusSmall
                    border.color: Local.Constants.accentWarning
                    border.width: Local.Constants.borderWidthThin

                    Behavior on color {
                        ColorAnimation { duration: Local.Constants.animationDurationFast }
                    }
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: Local.Constants.fontSizeNormal
                    font.family: Local.Constants.fontFamily
                    color: Local.Constants.cardBackground
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                Layout.fillWidth: true
                text: "📄 LOGS LAST 5"
                onClicked: {
                    messageInput.text = "LOGS LAST 5"
                    console.log("Quick command: LOGS LAST 5")
                }

                background: Rectangle {
                    color: parent.pressed ? Qt.darker(Local.Constants.accentPrimary, 1.2) :
                    parent.hovered ? Qt.lighter(Local.Constants.accentPrimary, 1.1) :
                    Local.Constants.cardBackgroundAlt
                    radius: Local.Constants.radiusSmall
                    border.color: Local.Constants.accentPrimary
                    border.width: Local.Constants.borderWidthThin

                    Behavior on color {
                        ColorAnimation { duration: Local.Constants.animationDurationFast }
                    }
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: Local.Constants.fontSizeNormal
                    font.family: Local.Constants.fontFamily
                    color: Local.Constants.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Local.Constants.borderColor
        }

        // Last Command Status
        Text {
            text: "Last Command Status"
            font.pixelSize: Local.Constants.fontSizeMedium
            font.bold: true
            font.family: Local.Constants.fontFamily
            color: Local.Constants.textSecondary
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            color: Local.Constants.cardBackgroundAlt
            radius: Local.Constants.radiusMedium

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Local.Constants.spacingNormal
                spacing: Local.Constants.spacingSmall

                Text {
                    text: "Command: " + (commandHandler.lastCommand || "None")
                    font.pixelSize: Local.Constants.fontSizeSmall
                    font.family: Local.Constants.fontFamilyMono
                    color: Local.Constants.textSecondary
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }

                Text {
                    text: "Response: " + (commandHandler.lastResponse || "No response yet")
                    font.pixelSize: Local.Constants.fontSizeSmall
                    font.family: Local.Constants.fontFamilyMono
                    color: Local.Constants.textPrimary
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }
            }
        }

        Item { Layout.fillHeight: true }
    }

    // Connections to handle command responses
    Connections {
        target: commandHandler

        function onSmsSent(phoneNumber, success) {
            if (success) {
                console.log("SMS sent successfully to:", phoneNumber)
                phoneNumberInput.text = ""
                messageInput.text = ""
            } else {
                console.error("Failed to send SMS to:", phoneNumber)
            }
        }
    }
}

/*
 ═ ═*═════════════════════════════════════════════════════════════
 END OF FILE: qml/components/CommandPanel.qml
 ═══════════════════════════════════════════════════════════════
 */
