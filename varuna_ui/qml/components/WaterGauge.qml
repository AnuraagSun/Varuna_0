/*
 ═ ═*═════════════════════════════════════════════════════════════
 FILE: qml/components/WaterGauge.qml
 PHASE: Phase 2 - Dashboard Core Components
 LOCATION: varuna_ui/qml/components/WaterGauge.qml
 ═══════════════════════════════════════════════════════════════
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ".." as Local

Item {
    id: waterGauge

    // Public properties
    property real currentLevel: 0.0
    property real maxLevel: Local.Constants.waterLevelMax
    property real warningLevel: Local.Constants.waterLevelWarning
    property real dangerLevel: Local.Constants.waterLevelDanger
    property real rateOfChange: 0.0
    property bool isRising: rateOfChange > 0

    // Visual properties
    implicitWidth: 400
    implicitHeight: 400

    ColumnLayout {
        anchors.fill: parent
        spacing: Local.Constants.spacingLarge

        // Main gauge visualization
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                anchors.fill: parent
                spacing: Local.Constants.spacingXL

                // ========== VERTICAL GAUGE ==========
                Item {
                    Layout.preferredWidth: 200
                    Layout.fillHeight: true

                    // Gauge container
                    Rectangle {
                        id: gaugeContainer
                        anchors.centerIn: parent
                        width: 180
                        height: parent.height * 0.9
                        radius: Local.Constants.radiusLarge
                        color: Qt.rgba(
                            Local.Constants.accentPrimary.r,
                            Local.Constants.accentPrimary.g,
                            Local.Constants.accentPrimary.b,
                            0.05
                        )
                        border.color: Local.Constants.borderColor
                        border.width: Local.Constants.borderWidthMedium

                        // Gauge fill (water level)
                        Rectangle {
                            id: waterFill
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: Local.Constants.borderWidthMedium
                            height: Math.max(0, Math.min(parent.height - Local.Constants.borderWidthMedium * 2,
                                                         (waterGauge.currentLevel / waterGauge.maxLevel) * (parent.height - Local.Constants.borderWidthMedium * 2)))
                            radius: Local.Constants.radiusMedium

                            gradient: Gradient {
                                GradientStop {
                                    position: 0.0
                                    color: waterGauge.currentLevel >= waterGauge.dangerLevel ?
                                    Local.Constants.accentDanger :
                                    waterGauge.currentLevel >= waterGauge.warningLevel ?
                                    Local.Constants.accentWarning :
                                    Local.Constants.accentPrimary
                                }
                                GradientStop {
                                    position: 1.0
                                    color: Qt.darker(
                                        waterGauge.currentLevel >= waterGauge.dangerLevel ?
                                        Local.Constants.accentDanger :
                                        waterGauge.currentLevel >= waterGauge.warningLevel ?
                                        Local.Constants.accentWarning :
                                        Local.Constants.accentPrimary,
                                        1.3
                                    )
                                }
                            }

                            Behavior on height {
                                NumberAnimation {
                                    duration: 1000
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: Local.Constants.animationDurationSlow
                                    easing.type: Local.Constants.easingType
                                }
                            }

                            // Animated wave effect
                            Rectangle {
                                id: wave
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 20
                                color: Qt.rgba(1, 1, 1, 0.15)

                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 0.3; duration: 2000; easing.type: Easing.InOutSine }
                                    NumberAnimation { to: 0.15; duration: 2000; easing.type: Easing.InOutSine }
                                }
                            }
                        }

                        // Danger level line
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.rightMargin: -40
                            y: parent.height - ((waterGauge.dangerLevel / waterGauge.maxLevel) * parent.height)
                            height: 2
                            color: Local.Constants.accentDanger

                            Rectangle {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                width: 35
                                height: 18
                                radius: 4
                                color: Local.Constants.accentDanger

                                Text {
                                    anchors.centerIn: parent
                                    text: "DANGER"
                                    font.pixelSize: 8
                                    font.bold: true
                                    font.family: Local.Constants.fontFamily
                                    color: Local.Constants.textPrimary
                                }
                            }
                        }

                        // Warning level line
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.rightMargin: -40
                            y: parent.height - ((waterGauge.warningLevel / waterGauge.maxLevel) * parent.height)
                            height: 2
                            color: Local.Constants.accentWarning
                            opacity: 0.7

                            Rectangle {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                width: 35
                                height: 18
                                radius: 4
                                color: Local.Constants.accentWarning

                                Text {
                                    anchors.centerIn: parent
                                    text: "WARN"
                                    font.pixelSize: 8
                                    font.bold: true
                                    font.family: Local.Constants.fontFamily
                                    color: Local.Constants.cardBackground
                                }
                            }
                        }

                        // Scale markers
                        Column {
                            anchors.left: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 50
                            spacing: 0

                            Repeater {
                                model: 7

                                Item {
                                    width: 40
                                    height: gaugeContainer.height / 6

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: Math.round(waterGauge.maxLevel - (index * waterGauge.maxLevel / 6)) + " cm"
                                        font.pixelSize: Local.Constants.fontSizeTiny
                                        font.family: Local.Constants.fontFamilyMono
                                        color: Local.Constants.textTertiary
                                    }
                                }
                            }
                        }
                    }
                }

                // ========== READING DISPLAY ==========
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Local.Constants.spacingLarge

                    Item { Layout.fillHeight: true }

                    // Current level value
                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Local.Constants.spacingSmall

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: waterGauge.currentLevel.toFixed(1)
                            font.pixelSize: 72
                            font.bold: true
                            font.family: Local.Constants.fontFamily
                            color: waterGauge.currentLevel >= waterGauge.dangerLevel ?
                            Local.Constants.accentDanger :
                            waterGauge.currentLevel >= waterGauge.warningLevel ?
                            Local.Constants.accentWarning :
                            Local.Constants.accentPrimary

                            Behavior on color {
                                ColorAnimation {
                                    duration: Local.Constants.animationDurationSlow
                                    easing.type: Local.Constants.easingType
                                }
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "centimeters"
                            font.pixelSize: Local.Constants.fontSizeMedium
                            font.family: Local.Constants.fontFamily
                            color: Local.Constants.textSecondary
                        }
                    }

                    // Trend indicator
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 250
                        Layout.preferredHeight: 60
                        radius: Local.Constants.radiusMedium
                        color: waterGauge.isRising ?
                        Qt.rgba(Local.Constants.accentDanger.r, Local.Constants.accentDanger.g, Local.Constants.accentDanger.b, 0.1) :
                        Qt.rgba(Local.Constants.accentSuccess.r, Local.Constants.accentSuccess.g, Local.Constants.accentSuccess.b, 0.1)
                        border.color: waterGauge.isRising ? Local.Constants.accentDanger : Local.Constants.accentSuccess
                        border.width: Local.Constants.borderWidthThin

                        Behavior on color {
                            ColorAnimation {
                                duration: Local.Constants.animationDurationNormal
                                easing.type: Local.Constants.easingType
                            }
                        }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: Local.Constants.spacingNormal

                            Text {
                                text: waterGauge.isRising ? "↗" : "↘"
                                font.pixelSize: Local.Constants.fontSizeXXL
                                color: waterGauge.isRising ? Local.Constants.accentDanger : Local.Constants.accentSuccess
                            }

                            ColumnLayout {
                                spacing: 2

                                Text {
                                    text: (waterGauge.isRising ? "Rising " : "Falling ") +
                                    Math.abs(waterGauge.rateOfChange).toFixed(1) + " cm/hr"
                                    font.pixelSize: Local.Constants.fontSizeMedium
                                    font.bold: true
                                    font.family: Local.Constants.fontFamily
                                    color: Local.Constants.textPrimary
                                }

                                Text {
                                    text: waterGauge.isRising ? "Water level increasing" : "Water receding"
                                    font.pixelSize: Local.Constants.fontSizeSmall
                                    font.family: Local.Constants.fontFamily
                                    color: Local.Constants.textSecondary
                                }
                            }
                        }
                    }

                    // Threshold info
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 250
                        Layout.preferredHeight: 80
                        radius: Local.Constants.radiusMedium
                        color: Qt.rgba(
                            Local.Constants.cardBackgroundAlt.r,
                            Local.Constants.cardBackgroundAlt.g,
                            Local.Constants.cardBackgroundAlt.b,
                            0.5
                        )

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: Local.Constants.spacingSmall

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Local.Constants.spacingNormal

                                Text {
                                    text: "Warning Level:"
                                    font.pixelSize: Local.Constants.fontSizeSmall
                                    font.family: Local.Constants.fontFamily
                                    color: Local.Constants.textSecondary
                                }

                                Item { Layout.fillWidth: true }

                                Text {
                                    text: waterGauge.warningLevel + " cm"
                                    font.pixelSize: Local.Constants.fontSizeSmall
                                    font.bold: true
                                    font.family: Local.Constants.fontFamily
                                    color: Local.Constants.textPrimary
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Local.Constants.spacingNormal

                                Text {
                                    text: "Danger Level:"
                                    font.pixelSize: Local.Constants.fontSizeSmall
                                    font.family: Local.Constants.fontFamily
                                    color: Local.Constants.textSecondary
                                }

                                Item { Layout.fillWidth: true }

                                Text {
                                    text: waterGauge.dangerLevel + " cm"
                                    font.pixelSize: Local.Constants.fontSizeSmall
                                    font.bold: true
                                    font.family: Local.Constants.fontFamily
                                    color: Local.Constants.accentDanger
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }
        }
    }
}

/*
 ═ ═*═════════════════════════════════════════════════════════════
 END OF FILE: qml/components/WaterGauge.qml
 ═══════════════════════════════════════════════════════════════
 */
