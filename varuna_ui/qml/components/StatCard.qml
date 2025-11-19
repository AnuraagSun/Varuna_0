/*
 ═ ═*═════════════════════════════════════════════════════════════
 FILE: qml/components/StatCard.qml
 PHASE: Phase 2 - Dashboard Core Components
 LOCATION: varuna_ui/qml/components/StatCard.qml
 ═══════════════════════════════════════════════════════════════
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ".." as Local

Rectangle {
    id: statCard

    // Public properties
    property string title: "Stat"
    property string value: "0"
    property string subtitle: ""
    property color accentColor: Local.Constants.accentPrimary
    property string iconType: "circle"

    // Visual properties
    implicitWidth: 200
    implicitHeight: 160

    color: Local.Constants.cardBackground
    radius: Local.Constants.radiusMedium
    border.color: Local.Constants.borderColor
    border.width: Local.Constants.borderWidthThin

    property bool hovered: false

    Behavior on border.color {
        ColorAnimation {
            duration: Local.Constants.animationDurationNormal
            easing.type: Local.Constants.easingType
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Local.Constants.animationDurationFast
            easing.type: Local.Constants.easingType
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            statCard.hovered = true
            statCard.border.color = statCard.accentColor
            statCard.scale = 1.02
        }

        onExited: {
            statCard.hovered = false
            statCard.border.color = Local.Constants.borderColor
            statCard.scale = 1.0
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Local.Constants.spacingNormal
        spacing: Local.Constants.spacingNormal

        // Icon
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Local.Constants.iconSizeLarge
            Layout.preferredHeight: Local.Constants.iconSizeLarge
            radius: statCard.iconType === "circle" ?
            Local.Constants.iconSizeLarge / 2 :
            Local.Constants.radiusSmall
            color: Qt.rgba(
                statCard.accentColor.r,
                statCard.accentColor.g,
                statCard.accentColor.b,
                0.15
            )
            border.color: statCard.accentColor
            border.width: Local.Constants.borderWidthMedium

            Behavior on opacity {
                NumberAnimation {
                    duration: Local.Constants.animationDurationNormal
                    easing.type: Local.Constants.easingType
                }
            }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width * 0.4
                height: parent.height * 0.4
                radius: width / 2
                color: statCard.accentColor

                SequentialAnimation on scale {
                    running: statCard.hovered
                    loops: Animation.Infinite
                    NumberAnimation { to: 1.2; duration: 800; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutSine }
                }
            }
        }

        // Title
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: statCard.title
            font.pixelSize: Local.Constants.fontSizeSmall
            font.family: Local.Constants.fontFamily
            color: Local.Constants.textSecondary
            horizontalAlignment: Text.AlignHCenter
        }

        // Value
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: statCard.value
            font.pixelSize: Local.Constants.fontSizeXL
            font.bold: true
            font.family: Local.Constants.fontFamily
            color: Local.Constants.textPrimary
            horizontalAlignment: Text.AlignHCenter
        }

        // Subtitle
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: statCard.subtitle
            font.pixelSize: Local.Constants.fontSizeTiny
            font.family: Local.Constants.fontFamily
            color: Local.Constants.textTertiary
            horizontalAlignment: Text.AlignHCenter
            visible: statCard.subtitle !== ""
        }

        Item { Layout.fillHeight: true }
    }
}

/*
 ═ ═*═════════════════════════════════════════════════════════════
 END OF FILE: qml/components/StatCard.qml
 ═══════════════════════════════════════════════════════════════
 */
