/*
 ═ ═*═════════════════════════════════════════════════════════════
 FILE: qml/main.qml
 PHASE: Phase 7 - Communication and Control Features (COMPLETE)
 LOCATION: varuna_ui/qml/main.qml
 ═══════════════════════════════════════════════════════════════
 */

import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "." as Local
import "components"

Window {
    id: root

    width: Local.Constants.defaultWindowWidth
    height: Local.Constants.defaultWindowHeight
    minimumWidth: Local.Constants.minWindowWidth
    minimumHeight: Local.Constants.minWindowHeight
    visible: true
    title: "Varuna - Water Level Monitor"
    color: Local.Constants.backgroundColor

    // ==================== ALERT STATE MANAGEMENT ====================

    property real previousWaterLevel: 0
    property string currentAlertLevel: "none"  // "none", "info", "warning", "danger"
    property bool initialLoadComplete: false

    // ==================== BACKEND CONNECTION ====================

    Connections {
        target: backend

        function onDataUpdated() {
            console.log("QML: Data updated - Water Level:",
                        backend.waterLevel.toFixed(1), "cm,",
                        "Mode:", backend.operatingMode)

            // Check for alerts after initial load
            if (initialLoadComplete) {
                checkWaterLevelAlerts()
                checkSensorHealth()
                checkBatteryStatus()
            } else {
                initialLoadComplete = true
                previousWaterLevel = backend.waterLevel
            }
        }

        function onErrorOccurred(error) {
            console.error("QML: Backend error:", error)
            errorNotification.text = error
            errorNotification.show()
        }

        function onOperatingModeChanged() {
            console.log("QML: Operating mode changed to:", backend.operatingMode)

            if (backend.operatingMode === "FLOOD") {
                showAlert("danger", "FLOOD MODE ACTIVATED",
                          "System switched to 5-minute update interval due to rapid water level changes")
            } else if (backend.operatingMode === "LOW_POWER") {
                showAlert("warning", "Low Power Mode",
                          "Battery low - reducing update frequency to conserve power")
            }
        }
    }

    // ==================== ALERT DETECTION FUNCTIONS ====================

    function checkWaterLevelAlerts() {
        let level = backend.waterLevel
        let rate = backend.rateOfChange

        // Check critical/danger level
        if (level >= 250) {
            if (currentAlertLevel !== "danger") {
                currentAlertLevel = "danger"
                showAlert("danger", "⚠ CRITICAL WATER LEVEL",
                          `Water level at ${level.toFixed(1)} cm - DANGER threshold (250 cm) EXCEEDED! Immediate action required.`)
            }
        }
        // Check warning level
        else if (level >= 200) {
            if (currentAlertLevel !== "warning") {
                currentAlertLevel = "warning"
                showAlert("warning", "⚡ High Water Level Warning",
                          `Water level at ${level.toFixed(1)} cm - WARNING threshold (200 cm) exceeded. Monitor closely.`)
            }
        }
        // Check rapid rise (even if level is normal)
        else if (Math.abs(rate) > 5) {
            if (currentAlertLevel !== "warning") {
                currentAlertLevel = "warning"
                let direction = rate > 0 ? "rising" : "falling"
                showAlert("warning", `⚡ Rapid Water ${direction.charAt(0).toUpperCase() + direction.slice(1)}`,
                          `Water ${direction} at ${Math.abs(rate).toFixed(1)} cm/hr - Rate of change exceeds 5 cm/hr`)
            }
        }
        // All clear - only show if transitioning from alert state
        else {
            if (currentAlertLevel === "warning" || currentAlertLevel === "danger") {
                currentAlertLevel = "info"
                showAlert("success", "✓ Water Level Normal",
                          `Water level at ${level.toFixed(1)} cm - within safe operating range`)
            }
        }

        previousWaterLevel = level
    }

    function checkSensorHealth() {
        let faultySensors = []

        if (backend.mpuStatus === "FAULT") {
            faultySensors.push("MPU6050 (Primary)")
        }
        if (backend.ultrasonicStatus === "FAULT") {
            faultySensors.push("HC-SR04 (Ultrasonic)")
        }
        if (backend.pressureStatus === "FAULT") {
            faultySensors.push("MS5837 (Pressure)")
        }

        if (faultySensors.length > 0) {
            showAlert("warning", "⚠ Sensor Fault Detected",
                      `The following sensors are reporting faults: ${faultySensors.join(", ")}. System using remaining sensors.`)
        }
    }

    function checkBatteryStatus() {
        if (backend.batteryLevel < 10) {
            showAlert("danger", "⚠ CRITICAL BATTERY LEVEL",
                      `Battery at ${backend.batteryLevel}% - System may shut down soon. Check power supply immediately.`)
        } else if (backend.batteryLevel < 20) {
            if (currentAlertLevel !== "danger") {
                showAlert("warning", "⚡ Low Battery Warning",
                          `Battery at ${backend.batteryLevel}% - System will enter low power mode. Check solar/wind charging.`)
            }
        }
    }

    function showAlert(type, title, message) {
        activeAlert.alertType = type
        activeAlert.alertTitle = title
        activeAlert.alertMessage = message
        activeAlert.show()
    }

    // ==================== TIMERS ====================

    Timer {
        id: refreshCooldownTimer
        interval: 1000
        running: false
        repeat: false
    }

    // ==================== MAIN CONTAINER ====================

    Rectangle {
        id: mainContainer
        anchors.fill: parent
        color: Local.Constants.backgroundColor

        ColumnLayout {
            id: mainLayout
            anchors.fill: parent
            anchors.margins: 0
            spacing: 0

            // ========== HEADER COMPONENT ==========
            Header {
                id: header
                Layout.fillWidth: true

                // Bind to backend data
                deviceId: "CWC-RJ-001"
                locationName: "Jaipur, Rajasthan"
                riverName: "River Yamuna"
                isOnline: backend.isOnline
                signalStrength: backend.signalStrength

                onRefreshClicked: {
                    if (!refreshCooldownTimer.running) {
                        console.log("Main: Manual refresh triggered")

                        // Trigger backend refresh
                        backend.refreshData()

                        // Show notification
                        refreshNotification.show()

                        // Start cooldown
                        refreshCooldownTimer.start()
                    } else {
                        console.log("Main: Refresh on cooldown")
                    }
                }

                onSettingsClicked: {
                    console.log("Main: Settings clicked")
                    settingsPopup.open()
                }
            }

            // ========== ACTIVE ALERT BANNER ==========
            AlertBanner {
                id: activeAlert
                Layout.fillWidth: true
                Layout.margins: Local.Constants.spacingNormal
                Layout.topMargin: 0
                z: 1000

                dismissible: true
                autoHideDuration: alertType === "info" || alertType === "success" ? 5000 : 0

                onDismissed: {
                    if (alertType === "info" || alertType === "success") {
                        currentAlertLevel = "none"
                    }
                }
            }

            // ========== DASHBOARD COMPONENT ==========
            Dashboard {
                id: dashboard
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Bind to backend data
                currentWaterLevel: backend.waterLevel
                operatingMode: backend.operatingMode
                rateOfChange: backend.rateOfChange

                // Sensor data
                mpuAngle: backend.mpuAngle
                mpuWaterLevel: backend.mpuWaterLevel
                mpuStatus: backend.mpuStatus

                ultrasonicDistance: backend.ultrasonicDistance
                ultrasonicWaterLevel: backend.ultrasonicWaterLevel
                ultrasonicStatus: backend.ultrasonicStatus

                pressureValue: backend.pressureValue
                pressureWaterLevel: backend.pressureWaterLevel
                pressureStatus: backend.pressureStatus

                // System stats
                batteryLevel: backend.batteryLevel
                signalStrength: backend.signalStrength
                uptime: backend.uptime
                cpuTemp: backend.cpuTemp
            }
        }
    }

    // ==================== REFRESH NOTIFICATION ====================

    Rectangle {
        id: refreshNotification
        anchors.horizontalCenter: parent.horizontalCenter
        y: -height
        width: 250
        height: 50
        radius: Local.Constants.radiusMedium
        color: Local.Constants.accentSuccess

        visible: opacity > 0
        opacity: 0

        function show() {
            showAnimation.start()
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: Local.Constants.spacingNormal

            Text {
                text: "✓"
                font.pixelSize: Local.Constants.fontSizeLarge
                font.bold: true
                color: Local.Constants.textPrimary
            }

            Text {
                text: "Data refreshed"
                font.pixelSize: Local.Constants.fontSizeMedium
                font.family: Local.Constants.fontFamily
                color: Local.Constants.textPrimary
            }
        }

        SequentialAnimation {
            id: showAnimation

            ParallelAnimation {
                NumberAnimation {
                    target: refreshNotification
                    property: "y"
                    to: Local.Constants.spacingLarge
                    duration: Local.Constants.animationDurationNormal
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: refreshNotification
                    property: "opacity"
                    to: 1.0
                    duration: Local.Constants.animationDurationNormal
                    easing.type: Local.Constants.easingType
                }
            }

            PauseAnimation { duration: 2000 }

            ParallelAnimation {
                NumberAnimation {
                    target: refreshNotification
                    property: "y"
                    to: -refreshNotification.height
                    duration: Local.Constants.animationDurationNormal
                    easing.type: Easing.InCubic
                }
                NumberAnimation {
                    target: refreshNotification
                    property: "opacity"
                    to: 0.0
                    duration: Local.Constants.animationDurationNormal
                    easing.type: Local.Constants.easingType
                }
            }
        }
    }

    // ==================== ERROR NOTIFICATION ====================

    Rectangle {
        id: errorNotification
        anchors.horizontalCenter: parent.horizontalCenter
        y: -height
        width: 350
        height: 80
        radius: Local.Constants.radiusMedium
        color: Local.Constants.accentDanger

        visible: opacity > 0
        opacity: 0

        property string text: ""

        function show() {
            errorShowAnimation.start()
        }

        ColumnLayout {
            anchors.centerIn: parent
            anchors.margins: Local.Constants.spacingNormal
            spacing: Local.Constants.spacingSmall

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Local.Constants.spacingNormal

                Text {
                    text: "⚠"
                    font.pixelSize: Local.Constants.fontSizeLarge
                    font.bold: true
                    color: Local.Constants.textPrimary
                }

                Text {
                    text: "Error Occurred"
                    font.pixelSize: Local.Constants.fontSizeMedium
                    font.bold: true
                    font.family: Local.Constants.fontFamily
                    color: Local.Constants.textPrimary
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: 320
                text: errorNotification.text
                font.pixelSize: Local.Constants.fontSizeSmall
                font.family: Local.Constants.fontFamily
                color: Local.Constants.textPrimary
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }

        SequentialAnimation {
            id: errorShowAnimation

            ParallelAnimation {
                NumberAnimation {
                    target: errorNotification
                    property: "y"
                    to: Local.Constants.spacingLarge
                    duration: Local.Constants.animationDurationNormal
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: errorNotification
                    property: "opacity"
                    to: 1.0
                    duration: Local.Constants.animationDurationNormal
                    easing.type: Local.Constants.easingType
                }
            }

            PauseAnimation { duration: 4000 }

            ParallelAnimation {
                NumberAnimation {
                    target: errorNotification
                    property: "y"
                    to: -errorNotification.height
                    duration: Local.Constants.animationDurationNormal
                    easing.type: Easing.InCubic
                }
                NumberAnimation {
                    target: errorNotification
                    property: "opacity"
                    to: 0.0
                    duration: Local.Constants.animationDurationNormal
                    easing.type: Local.Constants.easingType
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                errorNotification.opacity = 0
                errorNotification.y = -errorNotification.height
            }
        }
    }

    // ==================== SETTINGS POPUP ====================

    Popup {
        id: settingsPopup
        anchors.centerIn: parent
        width: 500
        height: 700
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: Local.Constants.cardBackground
            radius: Local.Constants.radiusLarge
            border.color: Local.Constants.borderColor
            border.width: Local.Constants.borderWidthMedium
        }

        enter: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: Local.Constants.animationDurationNormal
                easing.type: Local.Constants.easingType
            }
            NumberAnimation {
                property: "scale"
                from: 0.9
                to: 1.0
                duration: Local.Constants.animationDurationNormal
                easing.type: Easing.OutBack
            }
        }

        exit: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1.0
                to: 0.0
                duration: Local.Constants.animationDurationFast
                easing.type: Local.Constants.easingType
            }
        }

        Flickable {
            anchors.fill: parent
            contentHeight: settingsContent.height
            clip: true

            ColumnLayout {
                id: settingsContent
                width: parent.width
                spacing: Local.Constants.spacingLarge

                anchors.margins: Local.Constants.spacingLarge
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                // Title
                Text {
                    text: "⚙️ System Settings"
                    font.pixelSize: Local.Constants.fontSizeXL
                    font.bold: true
                    font.family: Local.Constants.fontFamily
                    color: Local.Constants.textPrimary
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Local.Constants.borderColor
                }

                // System Information
                Text {
                    text: "System Information"
                    font.pixelSize: Local.Constants.fontSizeMedium
                    font.bold: true
                    font.family: Local.Constants.fontFamily
                    color: Local.Constants.textSecondary
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 140
                    color: Local.Constants.cardBackgroundAlt
                    radius: Local.Constants.radiusMedium

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Local.Constants.spacingNormal
                        spacing: Local.Constants.spacingSmall

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "Status:"
                                font.pixelSize: Local.Constants.fontSizeNormal
                                font.family: Local.Constants.fontFamily
                                color: Local.Constants.textSecondary
                            }
                            Item { Layout.fillWidth: true }
                            StatusIndicator {
                                status: backend.isOnline ? "ok" : "offline"
                                label: backend.isOnline ? "ONLINE" : "OFFLINE"
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "Operating Mode:"
                                font.pixelSize: Local.Constants.fontSizeNormal
                                font.family: Local.Constants.fontFamily
                                color: Local.Constants.textSecondary
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: backend.operatingMode
                                font.pixelSize: Local.Constants.fontSizeNormal
                                font.bold: true
                                font.family: Local.Constants.fontFamily
                                color: backend.operatingMode === "NORMAL" ?
                                Local.Constants.accentSuccess :
                                backend.operatingMode === "FLOOD" || backend.operatingMode === "CRITICAL" ?
                                Local.Constants.accentDanger :
                                Local.Constants.accentWarning
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "Uptime:"
                                font.pixelSize: Local.Constants.fontSizeNormal
                                font.family: Local.Constants.fontFamily
                                color: Local.Constants.textSecondary
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: backend.uptime + " hours"
                                font.pixelSize: Local.Constants.fontSizeNormal
                                font.bold: true
                                font.family: Local.Constants.fontFamily
                                color: Local.Constants.textPrimary
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "Current Alert:"
                                font.pixelSize: Local.Constants.fontSizeNormal
                                font.family: Local.Constants.fontFamily
                                color: Local.Constants.textSecondary
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: currentAlertLevel === "none" ? "None" :
                                currentAlertLevel === "danger" ? "DANGER" :
                                currentAlertLevel === "warning" ? "WARNING" :
                                "INFO"
                                font.pixelSize: Local.Constants.fontSizeNormal
                                font.bold: true
                                font.family: Local.Constants.fontFamily
                                color: currentAlertLevel === "none" ? Local.Constants.textSecondary :
                                currentAlertLevel === "danger" ? Local.Constants.accentDanger :
                                currentAlertLevel === "warning" ? Local.Constants.accentWarning :
                                Local.Constants.accentPrimary
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            visible: backend.lastError !== ""

                            Text {
                                text: "⚠ Last Error:"
                                font.pixelSize: Local.Constants.fontSizeSmall
                                font.family: Local.Constants.fontFamily
                                color: Local.Constants.accentDanger
                            }
                            Item { Layout.fillWidth: true }
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: backend.lastError !== ""
                            text: backend.lastError
                            font.pixelSize: Local.Constants.fontSizeTiny
                            font.family: Local.Constants.fontFamily
                            color: Local.Constants.textSecondary
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Local.Constants.borderColor
                }

                // Update Interval Control
                Text {
                    text: "Data Update Settings"
                    font.pixelSize: Local.Constants.fontSizeMedium
                    font.bold: true
                    font.family: Local.Constants.fontFamily
                    color: Local.Constants.textSecondary
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Local.Constants.spacingNormal

                    Text {
                        text: "Update Interval:"
                        font.pixelSize: Local.Constants.fontSizeNormal
                        font.family: Local.Constants.fontFamily
                        color: Local.Constants.textSecondary
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        id: intervalDisplay
                        text: (updateIntervalSlider.value / 1000).toFixed(0) + " seconds"
                        font.pixelSize: Local.Constants.fontSizeNormal
                        font.bold: true
                        font.family: Local.Constants.fontFamily
                        color: Local.Constants.textPrimary
                    }
                }

                Slider {
                    id: updateIntervalSlider
                    Layout.fillWidth: true
                    from: 5000
                    to: 300000
                    value: 60000
                    stepSize: 5000

                    onValueChanged: {
                        backend.setUpdateInterval(value)
                    }

                    background: Rectangle {
                        x: updateIntervalSlider.leftPadding
                        y: updateIntervalSlider.topPadding + updateIntervalSlider.availableHeight / 2 - height / 2
                        implicitWidth: 200
                        implicitHeight: 4
                        width: updateIntervalSlider.availableWidth
                        height: implicitHeight
                        radius: 2
                        color: Local.Constants.borderColor

                        Rectangle {
                            width: updateIntervalSlider.visualPosition * parent.width
                            height: parent.height
                            color: Local.Constants.accentPrimary
                            radius: 2
                        }
                    }

                    handle: Rectangle {
                        x: updateIntervalSlider.leftPadding + updateIntervalSlider.visualPosition * (updateIntervalSlider.availableWidth - width)
                        y: updateIntervalSlider.topPadding + updateIntervalSlider.availableHeight / 2 - height / 2
                        implicitWidth: 20
                        implicitHeight: 20
                        radius: 10
                        color: updateIntervalSlider.pressed ? Qt.darker(Local.Constants.accentPrimary, 1.2) : Local.Constants.accentPrimary
                        border.color: Local.Constants.textPrimary
                        border.width: 2
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: "Recommended: 60s (NORMAL), 5-10s (FLOOD mode)"
                    font.pixelSize: Local.Constants.fontSizeTiny
                    font.family: Local.Constants.fontFamily
                    color: Local.Constants.textTertiary
                    wrapMode: Text.WordWrap
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Local.Constants.borderColor
                }

                // Quick Actions
                Text {
                    text: "Quick Actions"
                    font.pixelSize: Local.Constants.fontSizeMedium
                    font.bold: true
                    font.family: Local.Constants.fontFamily
                    color: Local.Constants.textSecondary
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Local.Constants.spacingNormal

                    Button {
                        Layout.fillWidth: true
                        text: "🔄 Refresh Now"
                        onClicked: {
                            backend.refreshData()
                            console.log("User triggered: Manual refresh from settings")
                        }

                        background: Rectangle {
                            color: parent.pressed ? Qt.darker(Local.Constants.accentPrimary, 1.2) :
                            parent.hovered ? Qt.lighter(Local.Constants.accentPrimary, 1.1) :
                            Local.Constants.accentPrimary
                            radius: Local.Constants.radiusSmall

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
                        text: backend.isOnline ? "⏸ Stop" : "▶ Start"
                        onClicked: {
                            if (backend.isOnline) {
                                backend.stopMonitoring()
                                console.log("User stopped monitoring")
                            } else {
                                backend.startMonitoring()
                                console.log("User started monitoring")
                            }
                        }

                        background: Rectangle {
                            color: parent.pressed ? Qt.darker(Local.Constants.accentWarning, 1.2) :
                            parent.hovered ? Qt.lighter(Local.Constants.accentWarning, 1.1) :
                            Local.Constants.accentWarning
                            radius: Local.Constants.radiusSmall

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
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Local.Constants.borderColor
                }

                // ========== COMMAND PANEL ==========
                CommandPanel {
                    Layout.fillWidth: true
                }

                Item { Layout.preferredHeight: Local.Constants.spacingLarge }

                // Close button
                Button {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 150
                    text: "Close"
                    onClicked: settingsPopup.close()

                    background: Rectangle {
                        color: parent.pressed ? Qt.darker(Local.Constants.cardBackgroundAlt, 1.2) :
                        parent.hovered ? Qt.lighter(Local.Constants.cardBackgroundAlt, 1.1) :
                        Local.Constants.cardBackgroundAlt
                        radius: Local.Constants.radiusSmall
                        border.color: Local.Constants.borderColor
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

                Item { Layout.preferredHeight: Local.Constants.spacingLarge }
            }
        }
    }
}

/*
 ═ ═*═════════════════════════════════════════════════════════════
 END OF FILE: qml/main.qml
 ═══════════════════════════════════════════════════════════════
 */
