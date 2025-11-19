/*
 ═ ═*═════════════════════════════════════════════════════════════
 FILE: qml/utils/DataSimulator.qml
 PHASE: Phase 3 - Basic Interactivity and Data Simulation
 LOCATION: varuna_ui/qml/utils/DataSimulator.qml
 ═══════════════════════════════════════════════════════════════
 */

import QtQuick 2.15
import ".." as Local

QtObject {
    id: simulator

    // ==================== SIMULATED SENSOR DATA ====================

    // Water level data
    property real waterLevel: 145.8
    property real rateOfChange: 2.3
    property real targetWaterLevel: 145.8

    // MPU-6050 data
    property real mpuAngle: 32.5
    property real mpuWaterLevel: 145.3
    property string mpuStatus: "OK"

    // HC-SR04 data
    property real ultrasonicDistance: 154.7
    property real ultrasonicWaterLevel: 146.1
    property string ultrasonicStatus: "OK"

    // MS5837 data
    property real pressureValue: 1023.4
    property real pressureWaterLevel: 146.0
    property string pressureStatus: "OK"

    // System stats
    property int batteryLevel: 78
    property bool isCharging: true
    property int signalStrength: -67
    property int uptime: 342
    property int cpuTemp: 48
    property string operatingMode: "NORMAL"

    // Device info
    property bool isOnline: true

    // ==================== SIMULATION PARAMETERS ====================

    property real simulationSpeed: 1.0  // Multiplier for simulation speed
    property bool enableRandomFluctuations: true
    property bool enableScenarios: true

    // Scenario control
    property string currentScenario: "normal"  // "normal", "flood", "drought", "sensor_fault"

    // ==================== SIMULATION FUNCTIONS ====================

    function updateSimulation() {
        // Update uptime
        uptime += 1

        // Simulate water level changes based on scenario
        switch(currentScenario) {
            case "flood":
                targetWaterLevel = Math.min(280, targetWaterLevel + Math.random() * 3)
                rateOfChange = 5 + Math.random() * 5
                operatingMode = "FLOOD"
                break

            case "drought":
                targetWaterLevel = Math.max(50, targetWaterLevel - Math.random() * 2)
                rateOfChange = -3 - Math.random() * 2
                operatingMode = "NORMAL"
                break

            case "sensor_fault":
                mpuStatus = Math.random() > 0.7 ? "FAULT" : "OK"
                ultrasonicStatus = Math.random() > 0.8 ? "FAULT" : "OK"
                operatingMode = "NORMAL"
                break

            default:  // "normal"
                targetWaterLevel = 145 + Math.sin(uptime * 0.01) * 20 + (Math.random() - 0.5) * 5
                rateOfChange = (Math.random() - 0.5) * 4
                operatingMode = waterLevel > 200 ? "FLOOD" :
                batteryLevel < 20 ? "LOW_POWER" :
                "NORMAL"
                mpuStatus = "OK"
                ultrasonicStatus = "OK"
                pressureStatus = "OK"
                break
        }

        // Smooth transition to target water level
        waterLevel += (targetWaterLevel - waterLevel) * 0.1

        // Add small random fluctuations if enabled
        if (enableRandomFluctuations) {
            waterLevel += (Math.random() - 0.5) * 0.5
        }

        // Clamp water level
        waterLevel = Math.max(0, Math.min(300, waterLevel))

        // Update sensor readings with slight variations
        mpuWaterLevel = waterLevel + (Math.random() - 0.5) * 1.5
        ultrasonicWaterLevel = waterLevel + (Math.random() - 0.5) * 1.0
        pressureWaterLevel = waterLevel + (Math.random() - 0.5) * 0.8

        // Calculate MPU angle from water level (assuming 1.5m arm)
        mpuAngle = Math.asin(Math.min(1, waterLevel / 150)) * (180 / Math.PI)

        // Update ultrasonic distance (assuming 2m post height)
        ultrasonicDistance = 200 - waterLevel

        // Update pressure value
        pressureValue = 1013 + (waterLevel * 0.1)

        // Simulate battery charging/discharging
        if (isCharging && batteryLevel < 100) {
            batteryLevel = Math.min(100, batteryLevel + 0.1)
        } else if (!isCharging && batteryLevel > 0) {
            batteryLevel = Math.max(0, batteryLevel - 0.05)
        }

        // Toggle charging state occasionally
        if (Math.random() > 0.98) {
            isCharging = !isCharging
        }

        // Simulate signal strength fluctuations
        signalStrength = -67 + Math.floor(Math.random() * 20 - 10)

        // Simulate CPU temperature based on activity
        if (operatingMode === "FLOOD") {
            cpuTemp = 52 + Math.floor(Math.random() * 8)
        } else {
            cpuTemp = 45 + Math.floor(Math.random() * 6)
        }

        // Clamp values
        batteryLevel = Math.max(0, Math.min(100, Math.floor(batteryLevel)))
        signalStrength = Math.max(-100, Math.min(-40, signalStrength))
        cpuTemp = Math.max(35, Math.min(75, cpuTemp))
    }

    function triggerFloodScenario() {
        console.log("DataSimulator: Triggering FLOOD scenario")
        currentScenario = "flood"
        targetWaterLevel = 220
    }

    function triggerDroughtScenario() {
        console.log("DataSimulator: Triggering DROUGHT scenario")
        currentScenario = "drought"
        targetWaterLevel = 80
    }

    function triggerSensorFaultScenario() {
        console.log("DataSimulator: Triggering SENSOR FAULT scenario")
        currentScenario = "sensor_fault"
    }

    function resetToNormal() {
        console.log("DataSimulator: Resetting to NORMAL scenario")
        currentScenario = "normal"
        targetWaterLevel = 145
        mpuStatus = "OK"
        ultrasonicStatus = "OK"
        pressureStatus = "OK"
    }

    function randomizeData() {
        console.log("DataSimulator: Randomizing all data")
        waterLevel = 50 + Math.random() * 200
        targetWaterLevel = waterLevel
        batteryLevel = Math.floor(20 + Math.random() * 80)
        signalStrength = Math.floor(-90 + Math.random() * 40)
        cpuTemp = Math.floor(40 + Math.random() * 20)
    }
}

/*
 ═ ═*═════════════════════════════════════════════════════════════
 END OF FILE: qml/utils/DataSimulator.qml
 ═══════════════════════════════════════════════════════════════
 */
