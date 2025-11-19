import QtQuick 2.15
import QtQuick.Layouts 1.15
import ".." as Local

Rectangle {
    id: statusIndicator
    
    property string status: "unknown"
    property string label: ""
    property bool showPulse: true
    
    implicitWidth: label !== "" ? contentRow.width + 24 : 40
    implicitHeight: 32
    radius: Local.Constants.radiusFull
    
    color: {
        switch(status) {
            case "ok": return Local.Constants.statusOkBg
            case "warning": return Local.Constants.statusWarningBg
            case "danger": return Local.Constants.statusFaultBg
            case "offline": return Local.Constants.cardBackgroundAlt
            default: return Local.Constants.borderColor
        }
    }
    
    Behavior on color {
        ColorAnimation {
            duration: Local.Constants.animationDurationNormal
            easing.type: Local.Constants.easingType
        }
    }
    
    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: Local.Constants.spacingSmall
        
        Rectangle {
            width: 10
            height: 10
            radius: 5
            color: {
                switch(statusIndicator.status) {
                    case "ok": return Local.Constants.accentSuccess
                    case "warning": return Local.Constants.accentWarning
                    case "danger": return Local.Constants.accentDanger
                    case "offline": return Local.Constants.textTertiary
                    default: return Local.Constants.textSecondary
                }
            }
            
            Behavior on color {
                ColorAnimation {
                    duration: Local.Constants.animationDurationNormal
                    easing.type: Local.Constants.easingType
                }
            }
            
            SequentialAnimation on opacity {
                running: statusIndicator.showPulse && statusIndicator.status === "ok"
                loops: Animation.Infinite
                NumberAnimation { to: 0.3; duration: 1000 }
                NumberAnimation { to: 1.0; duration: 1000 }
            }
            
            SequentialAnimation on scale {
                running: statusIndicator.showPulse && statusIndicator.status === "ok"
                loops: Animation.Infinite
                NumberAnimation { to: 1.2; duration: 1000 }
                NumberAnimation { to: 1.0; duration: 1000 }
            }
        }
        
        Text {
            visible: statusIndicator.label !== ""
            text: statusIndicator.label
            font.pixelSize: Local.Constants.fontSizeSmall
            font.bold: true
            font.family: Local.Constants.fontFamily
            color: {
                switch(statusIndicator.status) {
                    case "ok": return Local.Constants.statusOkText
                    case "warning": return Local.Constants.statusWarningText
                    case "danger": return Local.Constants.statusFaultText
                    default: return Local.Constants.textSecondary
                }
            }
        }
    }
}
