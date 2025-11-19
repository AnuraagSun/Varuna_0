/*
 ═ ═*═════════════════════════════════════════════════════════════
 FILE: qml/components/Header.qml (FIX - use Local prefix)
 PHASE: Phase 1 - Project Setup and Core UI Framework
 LOCATION: varuna_ui/qml/components/Header.qml
 ═══════════════════════════════════════════════════════════════
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ".." as Local

Rectangle {
    id: header

    property string deviceId: "CWC-RJ-001"
    property string locationName: "Jaipur, Rajasthan"
    property string riverName: "River Yamuna"
    property bool isOnline: true
    property int signalStrength: -67

    signal refreshClicked()
    signal settingsClicked()

    height: Local.Constants.headerHeight
    color: Local.Constants.cardBackground

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Local.Constants.borderColor
        opacity: 0.5

        Behavior on opacity {
            NumberAnimation {
                duration: Local.Constants.animationDurationNormal
                easing.type: Local.Constants.easingType
            }
        }
    }

    RowLayout {
        id: headerLayout
        anchors.fill: parent
        anchors.margins: Local.Constants.spacingNormal
        spacing: Local.Constants.spacingLarge

        Rectangle {
            id: deviceIcon
            Layout.preferredWidth: Local.Constants.iconSizeXXL
            Layout.preferredHeight: Local.Constants.iconSizeXXL
            radius: Local.Constants.radiusMedium
            color: Local.Constants.accentPrimary

            gradient: Gradient {
                GradientStop { position: 0.0; color: Local.Constants.accentPrimary }
                GradientStop { position: 1.0; color: Qt.darker(Local.Constants.accentPrimary, 1.2) }
            }

            Text {
                anchors.centerIn: parent
                text: "🌊"
                font.pixelSize: Local.Constants.iconSizeLarge
            }

            SequentialAnimation on scale {
                loops: Animation.Infinite
                NumberAnimation {
                    to: 1.05
                    duration: 2000
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    to: 1.0
                    duration: 2000
                    easing.type: Easing.InOutSine
                }
            }
        }

        ColumnLayout {
            id: deviceInfo
            Layout.fillWidth: true
            spacing: Local.Constants.spacingTiny

            Text {
                id: deviceIdText
                text: header.deviceId
                font.pixelSize: Local.Constants.fontSizeXL
                font.bold: true
                font.family: Local.Constants.fontFamily
                color: Local.Constants.textPrimary

                opacity: 0
                Component.onCompleted: {
                    opacity = 1
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Local.Constants.animationDurationSlow
                        easing.type: Local.Constants.easingType
                    }
                }
            }

            RowLayout {
                spacing: Local.Constants.spacingSmall

                Rectangle {
                    width: Local.Constants.iconSizeSmall
                    height: Local.Constants.iconSizeSmall
                    radius: 2
                    color: Local.Constants.textSecondary

                    Rectangle {
                        anchors.centerIn: parent
                        width: 4
                        height: 4
                        radius: 2
                        color: Local.Constants.backgroundColor
                    }
                }

                Text {
                    id: locationText
                    text: header.locationName + " • " + header.riverName
                    font.pixelSize: Local.Constants.fontSizeNormal
                    font.family: Local.Constants.fontFamily
                    color: Local.Constants.textSecondary

                    opacity: 0
                    Component.onCompleted: {
                        opacity = 1
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Local.Constants.animationDurationSlow
                            easing.type: Local.Constants.easingType
                        }
                    }
                }
            }
        }

        Rectangle {
            id: statusBadge
            Layout.preferredWidth: 120
            Layout.preferredHeight: Local.Constants.buttonHeightNormal
            radius: Local.Constants.radiusFull
            color: header.isOnline ? Local.Constants.statusOkBg : Local.Constants.statusFaultBg

            Behavior on color {
                ColorAnimation {
                    duration: Local.Constants.animationDurationNormal
                    easing.type: Local.Constants.easingType
                }
            }

            RowLayout {
                anchors.centerIn: parent
                spacing: Local.Constants.spacingSmall

                Rectangle {
                    id: pulseIndicator
                    width: 10
                    height: 10
                    radius: 5
                    color: header.isOnline ? Local.Constants.accentSuccess : Local.Constants.accentDanger

                    Behavior on color {
                        ColorAnimation {
                            duration: Local.Constants.animationDurationNormal
                            easing.type: Local.Constants.easingType
                        }
                    }

                    SequentialAnimation on opacity {
                        running: header.isOnline
                        loops: Animation.Infinite
                        NumberAnimation {
                            to: 0.3
                            duration: Local.Constants.animationDurationVerySlow
                            easing.type: Local.Constants.easingType
                        }
                        NumberAnimation {
                            to: 1.0
                            duration: Local.Constants.animationDurationVerySlow
                            easing.type: Local.Constants.easingType
                        }
                    }

                    SequentialAnimation on scale {
                        running: header.isOnline
                        loops: Animation.Infinite
                        NumberAnimation {
                            to: 1.2
                            duration: Local.Constants.animationDurationVerySlow
                            easing.type: Local.Constants.easingType
                        }
                        NumberAnimation {
                            to: 1.0
                            duration: Local.Constants.animationDurationVerySlow
                            easing.type: Local.Constants.easingType
                        }
                    }
                }

                Text {
                    text: header.isOnline ? "ONLINE" : "OFFLINE"
                    font.pixelSize: Local.Constants.fontSizeSmall
                    font.bold: true
                    font.family: Local.Constants.fontFamily
                    color: header.isOnline ? Local.Constants.statusOkText : Local.Constants.statusFaultText

                    Behavior on color {
                        ColorAnimation {
                            duration: Local.Constants.animationDurationNormal
                            easing.type: Local.Constants.easingType
                        }
                    }
                }
            }
        }

        Rectangle {
            id: refreshButton
            Layout.preferredWidth: Local.Constants.buttonHeightLarge
            Layout.preferredHeight: Local.Constants.buttonHeightLarge
            radius: Local.Constants.radiusMedium
            color: Local.Constants.accentPrimary

            property bool hovered: false

            Behavior on color {
                ColorAnimation {
                    duration: Local.Constants.animationDurationFast
                    easing.type: Local.Constants.easingType
                }
            }

            Rectangle {
                id: refreshIcon
                anchors.centerIn: parent
                width: Local.Constants.iconSizeLarge * 0.6
                height: Local.Constants.iconSizeLarge * 0.6
                radius: width / 2
                color: "transparent"
                border.color: Local.Constants.textPrimary
                border.width: 2

                rotation: 0

                Behavior on rotation {
                    RotationAnimation {
                        duration: Local.Constants.animationDurationSlow
                        direction: RotationAnimation.Clockwise
                        easing.type: Easing.OutCubic
                    }
                }
            }

            MouseArea {
                id: refreshMouseArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true

                onEntered: {
                    refreshButton.hovered = true
                    refreshButton.color = Qt.lighter(Local.Constants.accentPrimary, 1.1)
                }

                onExited: {
                    refreshButton.hovered = false
                    refreshButton.color = Local.Constants.accentPrimary
                }

                onPressed: {
                    refreshButton.scale = 0.95
                }

                onReleased: {
                    refreshButton.scale = 1.0
                }

                onClicked: {
                    refreshIcon.rotation += 360
                    header.refreshClicked()
                    console.log("Header: Refresh button clicked")
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: Local.Constants.animationDurationFast
                    easing.type: Local.Constants.easingType
                }
            }
        }

        Rectangle {
            id: settingsButton
            Layout.preferredWidth: Local.Constants.buttonHeightLarge
            Layout.preferredHeight: Local.Constants.buttonHeightLarge
            radius: Local.Constants.radiusMedium
            color: "transparent"
            border.color: Local.Constants.accentPrimary
            border.width: Local.Constants.borderWidthMedium

            property bool hovered: false

            Behavior on color {
                ColorAnimation {
                    duration: Local.Constants.animationDurationFast
                    easing.type: Local.Constants.easingType
                }
            }

            Behavior on border.color {
                ColorAnimation {
                    duration: Local.Constants.animationDurationFast
                    easing.type: Local.Constants.easingType
                }
            }

            Rectangle {
                id: settingsIcon
                anchors.centerIn: parent
                width: Local.Constants.iconSizeLarge * 0.7
                height: Local.Constants.iconSizeLarge * 0.7
                radius: width / 2
                color: "transparent"
                border.color: Local.Constants.accentPrimary
                border.width: 2

                Rectangle {
                    anchors.centerIn: parent
                    width: 4
                    height: 4
                    radius: 2
                    color: Local.Constants.accentPrimary
                }

                rotation: 0

                Behavior on rotation {
                    RotationAnimation {
                        duration: Local.Constants.animationDurationNormal
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.5
                    }
                }
            }

            MouseArea {
                id: settingsMouseArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true

                onEntered: {
                    settingsButton.hovered = true
                    settingsButton.color = Local.Constants.accentPrimary
                    settingsButton.border.color = Local.Constants.accentPrimary
                    settingsIcon.rotation = 90
                }

                onExited: {
                    settingsButton.hovered = false
                    settingsButton.color = "transparent"
                    settingsButton.border.color = Local.Constants.accentPrimary
                    settingsIcon.rotation = 0
                }

                onPressed: {
                    settingsButton.scale = 0.95
                }

                onReleased: {
                    settingsButton.scale = 1.0
                }

                onClicked: {
                    header.settingsClicked()
                    console.log("Header: Settings button clicked")
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: Local.Constants.animationDurationFast
                    easing.type: Local.Constants.easingType
                }
            }
        }
    }
}

/*
 ═ ═*═════════════════════════════════════════════════════════════
 END OF FILE: qml/components/Header.qml
 ═══════════════════════════════════════════════════════════════
 */
