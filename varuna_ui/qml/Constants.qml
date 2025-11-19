/*
 ═ ═*═════════════════════════════════════════════════════════════
 FILE: qml/Constants.qml (ALTERNATIVE FIX)
 PHASE: Phase 1 - Project Setup and Core UI Framework
 LOCATION: varuna_ui/qml/Constants.qml
 ═══════════════════════════════════════════════════════════════
 */

pragma Singleton
import QtQuick 2.15

QtObject {
    id: constants

    // ==================== COLOR PALETTE ====================

    // Background colors
    readonly property color backgroundColor: "#0A0A0F"
    readonly property color cardBackground: "#1F2937"
    readonly property color cardBackgroundAlt: "#111827"
    readonly property color borderColor: "#374151"

    // Text colors
    readonly property color textPrimary: "#F9FAFB"
    readonly property color textSecondary: "#D1D5DB"
    readonly property color textTertiary: "#9CA3AF"

    // Accent colors
    readonly property color accentPrimary: "#3B82F6"
    readonly property color accentSuccess: "#10B981"
    readonly property color accentWarning: "#F59E0B"
    readonly property color accentDanger: "#EF4444"

    // Status colors
    readonly property color statusOkBg: "#d1fae5"
    readonly property color statusOkText: "#065f46"
    readonly property color statusFaultBg: "#fee2e2"
    readonly property color statusFaultText: "#991b1b"
    readonly property color statusWarningBg: "#fef3c7"
    readonly property color statusWarningText: "#92400e"
    readonly property color statusInfoBg: "#dbeafe"
    readonly property color statusInfoText: "#1e40af"

    // ==================== TYPOGRAPHY ====================

    readonly property string fontFamily: "Roboto"
    readonly property string fontFamilyMono: "Courier New"

    readonly property int fontSizeHuge: 48
    readonly property int fontSizeXXL: 32
    readonly property int fontSizeXL: 24
    readonly property int fontSizeLarge: 20
    readonly property int fontSizeMedium: 16
    readonly property int fontSizeNormal: 14
    readonly property int fontSizeSmall: 12
    readonly property int fontSizeTiny: 10

    // ==================== SPACING ====================

    readonly property int spacingTiny: 4
    readonly property int spacingSmall: 8
    readonly property int spacingMedium: 12
    readonly property int spacingNormal: 16
    readonly property int spacingLarge: 24
    readonly property int spacingXL: 32
    readonly property int spacingXXL: 48

    // ==================== BORDER & RADIUS ====================

    readonly property int borderWidthThin: 1
    readonly property int borderWidthMedium: 2
    readonly property int borderWidthThick: 4

    readonly property int radiusSmall: 8
    readonly property int radiusMedium: 12
    readonly property int radiusLarge: 16
    readonly property int radiusXL: 20
    readonly property int radiusFull: 9999

    // ==================== ANIMATION ====================

    readonly property int animationDurationFast: 150
    readonly property int animationDurationNormal: 300
    readonly property int animationDurationSlow: 500
    readonly property int animationDurationVerySlow: 800

    readonly property int easingType: Easing.InOutCubic

    // ==================== COMPONENT SIZES ====================

    readonly property int headerHeight: 80
    readonly property int buttonHeightSmall: 32
    readonly property int buttonHeightNormal: 40
    readonly property int buttonHeightLarge: 48

    readonly property int iconSizeSmall: 16
    readonly property int iconSizeNormal: 24
    readonly property int iconSizeLarge: 32
    readonly property int iconSizeXL: 48
    readonly property int iconSizeXXL: 64

    // ==================== SHADOWS ====================

    readonly property color shadowColor: "#000000"
    readonly property real shadowOpacity: 0.15
    readonly property int shadowRadius: 20

    // ==================== WATER LEVEL THRESHOLDS ====================

    readonly property int waterLevelMax: 300
    readonly property int waterLevelDanger: 250
    readonly property int waterLevelWarning: 200

    // ==================== DEVICE SPECIFIC ====================

    readonly property int minWindowWidth: 800
    readonly property int minWindowHeight: 480
    readonly property int defaultWindowWidth: 1024
    readonly property int defaultWindowHeight: 600
}

/*
 ═ ═*═════════════════════════════════════════════════════════════
 END OF FILE: qml/Constants.qml
 ═══════════════════════════════════════════════════════════════
 */
