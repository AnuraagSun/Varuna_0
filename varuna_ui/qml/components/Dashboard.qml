/*
 ═ ═*═════════════════════════════════════════════════════════════
 FILE: qml/components/Dashboard.qml
 PHASE: Phase 2 - Dashboard Core Components
 LOCATION: varuna_ui/qml/components/Dashboard.qml
 ═══════════════════════════════════════════════════════════════
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ".." as Local

Rectangle {
    id: dashboard

    // Public properties for data (will be populated from backend in Phase 4)
    property real currentWaterLevel: 145.8
    property string operatingMode: "NORMAL"
    property real rateOfChange: 2.3

    // Sensor data
    property real mpuAngle: 32.5
    property real mpuWaterLevel: 145.3
    property string mpuStatus: "OK"

    property real ultrasonicDistance: 154.7
    property real ultrasonicWaterLevel: 146.1
    property string ultrasonicStatus: "OK"

    property real pressureValue: 1023.4
    property real pressureWaterLevel: 146.0
    property string pressureStatus: "OK"

    // System stats
    property int batteryLevel: 78
    property int signalStrength: -67
    property int uptime: 342
    property int cpuTemp: 48

    color: Local.Constants.backgroundColor

    // Scrollable content area
    Flickable {
        id: scrollView
        anchors.fill: parent
        anchors.margins: Local.Constants.spacingNormal
        contentWidth: dashboardContent.width
        contentHeight: dashboardContent.height
        clip: true

        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        flickDeceleration: 1500
        maximumFlickVelocity: 2500

        Item {
            id: dashboardContent
            width: scrollView.width
            height: dashboardLayout.height

            ColumnLayout {
                id: dashboardLayout
                width: parent.width
                spacing: Local.Constants.spacingNormal

                // ========== WATER LEVEL GAUGE CARD ==========
                Rectangle {
                    id: waterGaugeCard
                    Layout.fillWidth: true
                    Layout.preferredHeight: 500
                    color: Local.Constants.cardBackground
                    radius: Local.Constants.radiusLarge
                    border.color: Local.Constants.borderColor
                    border.width: Local.Constants.borderWidthThin

                    property bool hovered: false

                    Behavior on border.color {
                        ColorAnimation {
                            duration: Local.Constants.animationDurationNormal
                            easing.type: Local.Constants.easingType
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: waterGaugeCard.hovered = true
                        onExited: waterGaugeCard.hovered = false
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Local.Constants.spacingLarge
                        spacing: Local.Constants.spacingNormal

                        // Card title
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
                                text: "💧 Water Level Monitor"
                                font.pixelSize: Local.Constants.fontSizeLarge
                                font.bold: true
                                font.family: Local.Constants.fontFamily
                                color: Local.Constants.textPrimary
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: "Real-time"
                                font.pixelSize: Local.Constants.fontSizeSmall
                                font.family: Local.Constants.fontFamily
                                color: Local.Constants.textSecondary
                                opacity: 0.7
                            }
                        }

                        // Water gauge component
                        WaterGauge {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            currentLevel: dashboard.currentWaterLevel
                            rateOfChange: dashboard.rateOfChange
                        }
                    }
                }

                // ========== SENSOR READINGS SECTION ==========
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Local.Constants.spacingSmall

                    Text {
                        text: "Sensor Readings"
                        font.pixelSize: Local.Constants.fontSizeMedium
                        font.bold: true
                        font.family: Local.Constants.fontFamily
                        color: Local.Constants.textPrimary
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 3
                        rowSpacing: Local.Constants.spacingNormal
                        columnSpacing: Local.Constants.spacingNormal

                        // MPU-6050 sensor
                        SensorCard {
                            Layout.fillWidth: true
                            sensorName: "🎯 MPU-6050 (Primary)"
                            sensorValue: dashboard.mpuWaterLevel.toFixed(1)
                            sensorUnit: "cm"
                            sensorStatus: dashboard.mpuStatus
                            accentColor: Local.Constants.accentPrimary
                        }

                        // Ultrasonic sensor
                        SensorCard {
                            Layout.fillWidth: true
                            sensorName: "📡 HC-SR04 (Ultrasonic)"
                            sensorValue: dashboard.ultrasonicWaterLevel.toFixed(1)
                            sensorUnit: "cm"
                            sensorStatus: dashboard.ultrasonicStatus
                            accentColor: Local.Constants.accentSuccess
                        }

                        // Pressure sensor
                        SensorCard {
                            Layout.fillWidth: true
                            sensorName: "💎 MS5837 (Pressure)"
                            sensorValue: dashboard.pressureWaterLevel.toFixed(1)
                            sensorUnit: "cm"
                            sensorStatus: dashboard.pressureStatus
                            accentColor: Local.Constants.accentWarning
                        }
                    }
                }

                // ========== SYSTEM STATISTICS SECTION ==========
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Local.Constants.spacingSmall

                    Text {
                        text: "System Statistics"
                        font.pixelSize: Local.Constants.fontSizeMedium
                        font.bold: true
                        font.family: Local.Constants.fontFamily
                        color: Local.Constants.textPrimary
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 3
                        rowSpacing: Local.Constants.spacingNormal
                        columnSpacing: Local.Constants.spacingNormal

                        // Battery
                        StatCard {
                            Layout.fillWidth: true
                            title: "Battery Level"
                            value: dashboard.batteryLevel + "%"
                            subtitle: dashboard.batteryLevel > 50 ? "Charging" : "Low"
                            accentColor: dashboard.batteryLevel > 50 ?
                            Local.Constants.accentSuccess :
                            Local.Constants.accentWarning
                            iconType: "circle"
                        }

                        // Signal
                        StatCard {
                            Layout.fillWidth: true
                            title: "GSM Signal"
                            value: dashboard.signalStrength + " dBm"
                            subtitle: "Excellent"
                            accentColor: Local.Constants.accentPrimary
                            iconType: "circle"
                        }

                        // Uptime
                        StatCard {
                            Layout.fillWidth: true
                            title: "System Uptime"
                            value: dashboard.uptime + " hrs"
                            subtitle: Math.floor(dashboard.uptime / 24) + " days"
                            accentColor: Local.Constants.accentSuccess
                            iconType: "circle"
                        }

                        // CPU Temp
                        StatCard {
                            Layout.fillWidth: true
                            title: "CPU Temperature"
                            value: dashboard.cpuTemp + "°C"
                            subtitle: dashboard.cpuTemp < 60 ? "Normal" : "Warm"
                            accentColor: dashboard.cpuTemp < 60 ?
                            Local.Constants.accentSuccess :
                            Local.Constants.accentWarning
                            iconType: "circle"
                        }

                        // Operating Mode
                        StatCard {
                            Layout.fillWidth: true
                            title: "Operating Mode"
                            value: dashboard.operatingMode
                            subtitle: dashboard.operatingMode === "NORMAL" ?
                            "60 min interval" :
                            dashboard.operatingMode === "FLOOD" ?
                            "5 min interval" :
                            "Low power"
                            accentColor: dashboard.operatingMode === "NORMAL" ?
                            Local.Constants.accentPrimary :
                            dashboard.operatingMode === "FLOOD" ?
                            Local.Constants.accentDanger :
                            Local.Constants.accentWarning
                            iconType: "square"
                        }

                        // Rate of change
                        StatCard {
                            Layout.fillWidth: true
                            title: "Rate of Change"
                            value: (dashboard.rateOfChange >= 0 ? "+" : "") +
                            dashboard.rateOfChange.toFixed(1) + " cm/hr"
                            subtitle: dashboard.rateOfChange > 0 ? "Rising" :
                            dashboard.rateOfChange < 0 ? "Falling" : "Stable"
                            accentColor: dashboard.rateOfChange > 5 ?
                            Local.Constants.accentDanger :
                            dashboard.rateOfChange > 0 ?
                            Local.Constants.accentWarning :
                            Local.Constants.accentSuccess
                            iconType: "circle"
                        }
                    }
                }

                // Bottom spacing
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Local.Constants.spacingNormal
                }
            }
        }
    }

    // Custom scrollbar
    Rectangle {
        id: scrollbar
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: Local.Constants.spacingSmall
        width: 6
        radius: 3
        color: Local.Constants.borderColor
        opacity: scrollView.moving ? 0.6 : 0.3
        visible: scrollView.contentHeight > scrollView.height

        Behavior on opacity {
            NumberAnimation {
                duration: Local.Constants.animationDurationNormal
                easing.type: Local.Constants.easingType
            }
        }

        Rectangle {
            id: scrollbarHandle
            y: scrollView.visibleArea.yPosition * scrollbar.height
            width: parent.width
            height: scrollView.visibleArea.heightRatio * scrollbar.height
            radius: 3
            color: Local.Constants.accentPrimary

            Behavior on color {
                ColorAnimation {
                    duration: Local.Constants.animationDurationFast
                    easing.type: Local.Constants.easingType
                }
            }
        }
    }
}

/*
 ═ ═*═════════════════════════════════════════════════════════════
 END OF FILE: qml/components/Dashboard.qml
 ═══════════════════════════════════════════════════════════════
 */
