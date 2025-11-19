import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ".." as Local

Rectangle {
    id: alertBanner
    
    property string alertType: "info"
    property string alertTitle: "Alert"
    property string alertMessage: ""
    property bool dismissible: true
    property int autoHideDuration: 0
    
    implicitHeight: 80
    radius: Local.Constants.radiusMedium
    
    color: {
        switch(alertType) {
            case "danger": return Local.Constants.accentDanger
            case "warning": return Local.Constants.accentWarning
            case "success": return Local.Constants.accentSuccess
            default: return Local.Constants.accentPrimary
        }
    }
    
    opacity: 0
    visible: opacity > 0
    
    signal dismissed()
    
    function show() {
        showAnimation.start()
        if (autoHideDuration > 0) {
            autoHideTimer.interval = autoHideDuration
            autoHideTimer.start()
        }
    }
    
    function hide() {
        hideAnimation.start()
    }
    
    Timer {
        id: autoHideTimer
        running: false
        repeat: false
        onTriggered: alertBanner.hide()
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: Local.Constants.spacingNormal
        spacing: Local.Constants.spacingNormal
        
        Text {
            text: {
                switch(alertBanner.alertType) {
                    case "danger": return "⚠"
                    case "warning": return "⚡"
                    case "success": return "✓"
                    default: return "ℹ"
                }
            }
            font.pixelSize: Local.Constants.fontSizeXXL
            color: Local.Constants.textPrimary
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Local.Constants.spacingTiny
            
            Text {
                text: alertBanner.alertTitle
                font.pixelSize: Local.Constants.fontSizeMedium
                font.bold: true
                font.family: Local.Constants.fontFamily
                color: Local.Constants.textPrimary
            }
            
            Text {
                Layout.fillWidth: true
                text: alertBanner.alertMessage
                font.pixelSize: Local.Constants.fontSizeNormal
                font.family: Local.Constants.fontFamily
                color: Local.Constants.textPrimary
                wrapMode: Text.WordWrap
            }
        }
        
        Rectangle {
            visible: alertBanner.dismissible
            width: 32
            height: 32
            radius: 16
            color: Qt.rgba(0, 0, 0, 0.2)
            
            Text {
                anchors.centerIn: parent
                text: "×"
                font.pixelSize: Local.Constants.fontSizeLarge
                font.bold: true
                color: Local.Constants.textPrimary
            }
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    alertBanner.hide()
                    alertBanner.dismissed()
                }
            }
        }
    }
    
    SequentialAnimation {
        id: showAnimation
        ParallelAnimation {
            NumberAnimation {
                target: alertBanner
                property: "opacity"
                to: 1.0
                duration: Local.Constants.animationDurationNormal
                easing.type: Local.Constants.easingType
            }
            NumberAnimation {
                target: alertBanner
                property: "scale"
                from: 0.95
                to: 1.0
                duration: Local.Constants.animationDurationNormal
                easing.type: Easing.OutBack
            }
        }
    }
    
    SequentialAnimation {
        id: hideAnimation
        ParallelAnimation {
            NumberAnimation {
                target: alertBanner
                property: "opacity"
                to: 0.0
                duration: Local.Constants.animationDurationFast
                easing.type: Local.Constants.easingType
            }
            NumberAnimation {
                target: alertBanner
                property: "scale"
                to: 0.95
                duration: Local.Constants.animationDurationFast
                easing.type: Easing.InCubic
            }
        }
    }
}
