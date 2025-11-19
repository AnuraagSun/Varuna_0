/*
 ═ ═*═════════════════════════════════════════════════════════════
 FILE: qml/components/SensorCard.qml
 PHASE: Phase 2 - Dashboard Core Components
 LOCATION: varuna_ui/qml/components/SensorCard.qml
 ═══════════════════════════════════════════════════════════════
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ".." as Local

Rectangle {
    id: sensorCard

    // Public properties
    property string sensorName: "Sensor"
    property string sensorValue: "0.0"
    property string sensorUnit: "unit"
    property string sensorStatus: "OK"
    property color accentColor: Local.Constants.accentPrimary

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
            sensorCard.hovered = true
            sensorCard.border.color = sensorCard.accentColor
            sensorCard.scale = 1.02
        }

        onExited: {
            sensorCard.hovered = false
            sensorCard.border.color = Local.Constants.borderColor
            sensorCard.scale = 1.0
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Local.Constants.spacingNormal
        spacing: Local.Constants.spacingSmall

        // Sensor name with status
        RowLayout {
            Layout.fillWidth: true
            spacing: Local.Constants.spacingSmall

            Text {
                Layout.fillWidth: true
                text: sensorCard.sensorName
                font.pixelSize: Local.Constants.fontSizeSmall
                font.bold: true
                font.family: Local.Constants.fontFamily
                color: Local.Constants.textSecondary
                elide: Text.ElideRight
            }

            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: sensorCard.sensorStatus === "OK" ?
                Local.Constants.accentSuccess :
                Local.Constants.accentDanger

                SequentialAnimation on opacity {
                    running: sensorCard.sensorStatus === "OK"
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.3; duration: 1000 }
                    NumberAnimation { to: 1.0; duration: 1000 }
                }
            }
        }

        Item { Layout.fillHeight: true }

        // Sensor value
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: sensorCard.sensorValue
            font.pixelSize: Local.Constants.fontSizeXXL
            font.bold: true
            font.family: Local.Constants.fontFamilyMono
            color: Local.Constants.textPrimary
        }

        // Sensor unit
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: sensorCard.sensorUnit
            font.pixelSize: Local.Constants.fontSizeSmall
            font.family: Local.Constants.fontFamily
            color: Local.Constants.textSecondary
        }

        Item { Layout.fillHeight: true }

        // Status badge
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 60
            Layout.preferredHeight: 22
            radius: Local.Constants.radiusSmall
            color: sensorCard.sensorStatus === "OK" ?
            Local.Constants.statusOkBg :
            Local.Constants.statusFaultBg

            Text {
                anchors.centerIn: parent
                text: "✓ " + sensorCard.sensorStatus
                font.pixelSize: Local.Constants.fontSizeTiny
                font.bold: true
                font.family: Local.Constants.fontFamily
                color: sensorCard.sensorStatus === "OK" ?
                Local.Constants.statusOkText :
                Local.Constants.statusFaultText
            }
        }
    }
}

/*
 ═ ═*═════════════════════════════════════════════════════════════
 END OF FILE: qml/components/SensorCard.qml
 ═══════════════════════════════════════════════════════════════
 */
