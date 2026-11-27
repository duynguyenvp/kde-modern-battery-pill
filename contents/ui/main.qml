import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support
import "i18n.js" as I18n

PlasmoidItem {
    id: root

    // Battery state
    property int capacity: 0
    property string status: "Unknown"
    property bool pluggedIn: false
    property real powerWatts: 0.0
    property real energyNowWh: 0.0
    property real energyFullWh: 0.0
    property real energyDesignWh: 0.0
    property real healthPercent: 100.0
    property int cycleCount: -1
    property real voltageVolts: 0.0
    property string timeEstimate: "--"
    property string activeProfile: "balanced"
    property bool profilesAvailable: true

    // Config shortcuts
    readonly property string cfgLanguage: plasmoid.configuration.language || "auto"
    readonly property string cfgPosition: plasmoid.configuration.percentagePosition || "inside"

    function tr(key) {
        return I18n.tr(root.cfgLanguage, Qt.locale().name, key)
    }
    readonly property bool cfgShowChargingIcon: plasmoid.configuration.showChargingIcon
    readonly property bool cfgShowPercentSign: plasmoid.configuration.showPercentSign
    readonly property bool cfgShowBatteryNub: plasmoid.configuration.showBatteryNub

    readonly property string cfgFontFamily: plasmoid.configuration.fontFamily || ""
    readonly property int cfgFontSize: plasmoid.configuration.fontSize || 11
    readonly property int cfgFontWeight: plasmoid.configuration.fontWeight || 700
    readonly property bool cfgFontItalic: plasmoid.configuration.fontItalic
    readonly property bool cfgTextOutline: plasmoid.configuration.textOutline

    readonly property int cfgChargingIconSize: plasmoid.configuration.chargingIconSize || 12
    readonly property string cfgChargingIcon: plasmoid.configuration.chargingIcon || "⚡"
    readonly property string cfgPluggedIcon: plasmoid.configuration.pluggedIcon || "icons/plug-horizontal.svg"
    readonly property bool cfgTintCustomIcon: plasmoid.configuration.tintCustomIcon

    readonly property bool cfgAutoPillWidth: plasmoid.configuration.autoPillWidth
    readonly property int cfgPillWidth: plasmoid.configuration.pillWidth || 56
    readonly property int cfgPillPaddingX: plasmoid.configuration.pillPaddingX || 8
    readonly property int cfgPillHeight: plasmoid.configuration.pillHeight || 22
    readonly property int cfgPillRadius: plasmoid.configuration.pillRadius
    readonly property int cfgBorderWidth: plasmoid.configuration.borderWidth
    readonly property bool cfgUseCustomBorderColor: plasmoid.configuration.useCustomBorderColor
    readonly property color cfgBorderColor: plasmoid.configuration.borderColor || "#99ffffff"

    readonly property int cfgLowThreshold: plasmoid.configuration.lowBatteryThreshold || 20
    readonly property color cfgNormalColor: plasmoid.configuration.normalColor || "#38bdf8"
    readonly property color cfgChargingColor: plasmoid.configuration.chargingColor || "#22c55e"
    readonly property color cfgLowColor: plasmoid.configuration.lowColor || "#ef4444"
    readonly property bool cfgUseCustomBgColor: plasmoid.configuration.useCustomBackgroundColor
    readonly property color cfgBgColor: plasmoid.configuration.backgroundColor || "#33ffffff"
    readonly property bool cfgUseCustomTextColor: plasmoid.configuration.useCustomTextColor
    readonly property color cfgTextColor: plasmoid.configuration.textColor || "#ffffff"
    readonly property int cfgIntervalMs: Math.max(1000, (plasmoid.configuration.updateIntervalSec || 3) * 1000)

    readonly property bool isCharging: status === "Charging"
    readonly property bool isDischarging: status === "Discharging"
    readonly property bool isLow: !pluggedIn && capacity <= cfgLowThreshold

    readonly property color activeFillColor: {
        if (pluggedIn || isCharging) return cfgChargingColor
        if (isLow) return cfgLowColor
        return cfgNormalColor
    }

    readonly property color effectiveBorderColor: {
        if (cfgUseCustomBorderColor) return cfgBorderColor
        return Qt.rgba(activeFillColor.r, activeFillColor.g, activeFillColor.b, 0.6)
    }

    readonly property color effectiveBgColor: {
        if (cfgUseCustomBgColor) return cfgBgColor
        return Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.16)
    }

    readonly property color effectiveTextColor: {
        if (cfgUseCustomTextColor) return cfgTextColor
        return Kirigami.Theme.textColor
    }

    function isLightColor(c) {
        return (0.299 * c.r + 0.587 * c.g + 0.114 * c.b) > 0.5
    }

    function outlineColorFor(c, alpha) {
        return isLightColor(c)
            ? Qt.rgba(0, 0, 0, alpha)
            : Qt.rgba(1, 1, 1, Math.min(1.0, alpha + 0.15))
    }

    readonly property string currentPowerIcon: isCharging ? cfgChargingIcon : cfgPluggedIcon
    readonly property string percentLabel: capacity + (cfgShowPercentSign ? "%" : "")

    readonly property string statusBadgeText: {
        if (isCharging) return tr("statusCharging")
        if (pluggedIn && (status === "Full" || status === "Not charging" || capacity >= 99)) {
            return tr("statusPluggedFullBadge")
        }
        if (pluggedIn) return tr("statusPlugged")
        if (isDischarging) return tr("statusDischarging")
        return status
    }

    readonly property string statusFullText: {
        if (isCharging) return tr("statusCharging")
        if (pluggedIn && (status === "Full" || status === "Not charging" || capacity >= 99)) {
            return tr("statusPluggedFull")
        }
        if (pluggedIn) return tr("statusPlugged")
        if (isDischarging) return tr("statusDischarging")
        return status
    }

    function isFileIcon(val) {
        var s = (val || "").trim()
        return s.startsWith("/") || s.startsWith("file://") || s.startsWith("icons/") || s.startsWith("./") || s.startsWith("../")
    }

    function toFileUrl(val) {
        var s = (val || "").trim()
        if (s.startsWith("/")) return "file://" + s
        if (s.startsWith("file://")) return s
        if (s.startsWith("icons/")) return Qt.resolvedUrl("../../" + s)
        return Qt.resolvedUrl(s)
    }

    function isThemeIconName(val) {
        var s = (val || "").trim()
        return !isFileIcon(s) && /^[a-z0-9][a-z0-9-]{2,}$/.test(s)
    }

    component PowerStatusIcon: Item {
        property string iconValue: ""
        property int iconSize: 12
        property color iconColor: Kirigami.Theme.textColor
        property bool useOutline: true

        readonly property bool isFile: root.isFileIcon(iconValue)
        readonly property bool isThemeIcon: root.isThemeIconName(iconValue)
        readonly property bool useKirigamiIcon: isThemeIcon || (isFile && root.cfgTintCustomIcon)
        readonly property bool useRawImage: isFile && !root.cfgTintCustomIcon

        implicitWidth: (useKirigamiIcon || useRawImage) ? iconSize : glyphText.implicitWidth
        implicitHeight: (useKirigamiIcon || useRawImage) ? iconSize : glyphText.implicitHeight

        Image {
            anchors.centerIn: parent
            visible: parent.useRawImage
            source: visible ? root.toFileUrl(parent.iconValue) : ""
            width: parent.iconSize
            height: parent.iconSize
            sourceSize.width: parent.iconSize * 2
            sourceSize.height: parent.iconSize * 2
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
        }

        Kirigami.Icon {
            anchors.centerIn: parent
            visible: parent.useKirigamiIcon
            source: visible ? (parent.isFile ? root.toFileUrl(parent.iconValue) : parent.iconValue.trim()) : ""
            width: parent.iconSize
            height: parent.iconSize
            isMask: true
            color: parent.iconColor
        }

        Text {
            id: glyphText
            anchors.centerIn: parent
            visible: !parent.useKirigamiIcon && !parent.useRawImage
            text: parent.iconValue
            font.pixelSize: parent.iconSize
            color: parent.iconColor
            style: parent.useOutline ? Text.Outline : Text.Normal
            styleColor: root.outlineColorFor(parent.iconColor, 0.4)
        }
    }

    preferredRepresentation: compactRepresentation

    toolTipMainText: percentLabel + " — " + statusFullText
    toolTipSubText: {
        var parts = []
        if (powerWatts > 0.05) {
            parts.push((isCharging ? "+" : "-") + powerWatts.toFixed(1) + " W")
        }
        if (timeEstimate !== "--") {
            parts.push(timeEstimate)
        }
        parts.push(tr("tooltipHealth") + ": " + healthPercent.toFixed(1) + "%")
        return parts.join("  •  ")
    }

    readonly property string pollCommand: "sh -c '" +
        "BAT=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1); " +
        "AC=$(ls -d /sys/class/power_supply/ADP* /sys/class/power_supply/AC* 2>/dev/null | head -n1); " +
        "cap=$(cat \"$BAT/capacity\" 2>/dev/null || echo 0); " +
        "st=$(cat \"$BAT/status\" 2>/dev/null || echo Unknown); " +
        "ac_on=$(cat \"$AC/online\" 2>/dev/null || echo 0); " +
        "pnow=$(cat \"$BAT/power_now\" 2>/dev/null || echo 0); " +
        "enow=$(cat \"$BAT/energy_now\" 2>/dev/null || echo 0); " +
        "efull=$(cat \"$BAT/energy_full\" 2>/dev/null || echo 0); " +
        "edesign=$(cat \"$BAT/energy_full_design\" 2>/dev/null || echo 0); " +
        "vnow=$(cat \"$BAT/voltage_now\" 2>/dev/null || echo 0); " +
        "if [ \"$efull\" = \"0\" ] && [ -f \"$BAT/charge_full\" ]; then " +
        "  cnow=$(cat \"$BAT/charge_now\" 2>/dev/null || echo 0); " +
        "  cfull=$(cat \"$BAT/charge_full\" 2>/dev/null || echo 0); " +
        "  cdesign=$(cat \"$BAT/charge_full_design\" 2>/dev/null || echo 0); " +
        "  inow=$(cat \"$BAT/current_now\" 2>/dev/null || echo 0); " +
        "  enow=$((cnow * vnow / 1000000)); " +
        "  efull=$((cfull * vnow / 1000000)); " +
        "  edesign=$((cdesign * vnow / 1000000)); " +
        "  pnow=$((inow * vnow / 1000000)); " +
        "fi; " +
        "cyc=$(cat \"$BAT/cycle_count\" 2>/dev/null || echo -1); " +
        "prof=$(busctl get-property org.freedesktop.UPower.PowerProfiles " +
        "  /org/freedesktop/UPower/PowerProfiles " +
        "  org.freedesktop.UPower.PowerProfiles ActiveProfile 2>/dev/null " +
        "  | sed -n \"s/.*\\\"\\([a-z-]*\\)\\\".*/\\1/p\"); " +
        "if [ -z \"$prof\" ]; then " +
        "  prof=$(busctl get-property net.hadess.PowerProfiles " +
        "    /net/hadess/PowerProfiles " +
        "    net.hadess.PowerProfiles ActiveProfile 2>/dev/null " +
        "    | sed -n \"s/.*\\\"\\([a-z-]*\\)\\\".*/\\1/p\"); " +
        "fi; " +
        "printf \"%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\\n\" \"$cap\" \"$st\" \"$ac_on\" \"$pnow\" \"$enow\" \"$efull\" \"$edesign\" \"$cyc\" \"$vnow\" \"$prof\"'"

    function formatHours(hours) {
        if (!isFinite(hours) || hours <= 0 || hours > 99) return "--"
        var totalMins = Math.round(hours * 60)
        var h = Math.floor(totalMins / 60)
        var m = totalMins % 60
        if (h > 0) return h + tr("hourShort") + " " + (m < 10 ? "0" : "") + m + tr("minShort")
        return m + " " + tr("minutesUnit")
    }

    function parsePollOutput(raw) {
        var line = raw.trim()
        if (!line) return
        var parts = line.split("|")
        if (parts.length < 10) return

        root.capacity = parseInt(parts[0], 10) || 0
        root.status = parts[1] || "Unknown"
        root.pluggedIn = (parts[2] === "1") || (root.status === "Charging")

        var pNowUw = parseFloat(parts[3]) || 0
        var eNowUwh = parseFloat(parts[4]) || 0
        var eFullUwh = parseFloat(parts[5]) || 0
        var eDesignUwh = parseFloat(parts[6]) || 0
        var cyc = parseInt(parts[7], 10)
        var vNowUv = parseFloat(parts[8]) || 0
        var prof = parts[9] ? parts[9].trim() : ""

        root.powerWatts = Math.abs(pNowUw) / 1000000.0
        root.energyNowWh = eNowUwh / 1000000.0
        root.energyFullWh = eFullUwh / 1000000.0
        root.energyDesignWh = eDesignUwh / 1000000.0
        root.cycleCount = isNaN(cyc) ? -1 : cyc
        root.voltageVolts = vNowUv / 1000000.0

        if (root.energyDesignWh > 0 && root.energyFullWh > 0) {
            root.healthPercent = Math.min(100.0, (root.energyFullWh / root.energyDesignWh) * 100.0)
        }

        if (root.isCharging && root.powerWatts > 0.2 && root.energyFullWh > root.energyNowWh) {
            root.timeEstimate = formatHours((root.energyFullWh - root.energyNowWh) / root.powerWatts) + " " + tr("timeToFull")
        } else if (root.isDischarging && root.powerWatts > 0.2 && root.energyNowWh > 0) {
            root.timeEstimate = formatHours(root.energyNowWh / root.powerWatts) + " " + tr("timeRemaining")
        } else if (root.pluggedIn) {
            root.timeEstimate = tr("timePluggedFull")
        } else {
            root.timeEstimate = "--"
        }

        if (prof.length > 0) {
            root.activeProfile = prof
            root.profilesAvailable = true
        }
    }

    function setPowerProfile(profileName) {
        if (profileName !== "power-saver" && profileName !== "balanced" && profileName !== "performance") {
            return
        }
        var cmd = "sh -c '" +
            "busctl set-property org.freedesktop.UPower.PowerProfiles " +
            "/org/freedesktop/UPower/PowerProfiles " +
            "org.freedesktop.UPower.PowerProfiles ActiveProfile s " + profileName + " 2>/dev/null " +
            "|| busctl set-property net.hadess.PowerProfiles " +
            "/net/hadess/PowerProfiles " +
            "net.hadess.PowerProfiles ActiveProfile s " + profileName + " 2>/dev/null'"
        profileRunner.connectSource(cmd)
    }

    Plasma5Support.DataSource {
        id: batteryPoller
        engine: "executable"
        connectedSources: []
        onNewData: function(sourceName, data) {
            if (data["stdout"]) {
                root.parsePollOutput(data["stdout"])
            }
            disconnectSource(sourceName)
        }
    }

    Plasma5Support.DataSource {
        id: profileRunner
        engine: "executable"
        connectedSources: []
        onNewData: function(sourceName, data) {
            disconnectSource(sourceName)
            batteryPoller.connectSource(root.pollCommand)
        }
    }

    Timer {
        id: pollTimer
        interval: root.cfgIntervalMs
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: batteryPoller.connectSource(root.pollCommand)
    }

    // ==================== COMPACT (TASKBAR) ====================
    compactRepresentation: Item {
        id: compactItem
        Layout.minimumWidth: compactRow.implicitWidth + 8
        Layout.preferredWidth: compactRow.implicitWidth + 8
        Layout.minimumHeight: Math.max(root.cfgPillHeight, root.cfgChargingIconSize) + 4
        Layout.fillHeight: true

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expanded = !root.expanded
        }

        RowLayout {
            id: compactRow
            anchors.centerIn: parent
            spacing: 6

            // Percentage text BEFORE pill
            Text {
                visible: root.cfgPosition === "before"
                text: root.percentLabel
                font.family: root.cfgFontFamily
                font.pixelSize: root.cfgFontSize
                font.weight: root.cfgFontWeight
                font.italic: root.cfgFontItalic
                color: root.effectiveTextColor
                verticalAlignment: Text.AlignVCenter
                style: root.cfgTextOutline ? Text.Outline : Text.Normal
                styleColor: root.outlineColorFor(root.effectiveTextColor, 0.35)
            }

            // Pill battery container
            Item {
                id: pillWrapper
                readonly property real computedPillWidth: {
                    if (root.cfgAutoPillWidth && root.cfgPosition === "inside") {
                        return Math.max(root.cfgPillWidth, insideContentRow.implicitWidth + root.cfgPillPaddingX * 2 + root.cfgBorderWidth * 2)
                    }
                    return root.cfgPillWidth
                }
                implicitWidth: computedPillWidth + (root.cfgShowBatteryNub ? 4 : 0)
                implicitHeight: root.cfgPillHeight

                // Main pill body
                Rectangle {
                    id: pillBody
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: pillWrapper.computedPillWidth
                    height: root.cfgPillHeight
                    radius: Math.min(root.cfgPillRadius, height / 2)
                    color: root.effectiveBgColor
                    border.color: root.effectiveBorderColor
                    border.width: root.cfgBorderWidth
                    clip: true

                    // Inner fill bar
                    Rectangle {
                        id: pillFill
                        readonly property real inset: root.cfgBorderWidth > 0 ? root.cfgBorderWidth + 0.5 : 0
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.margins: inset
                        width: Math.max(0, (parent.width - inset * 2) * Math.max(0, Math.min(100, root.capacity)) / 100.0)
                        radius: Math.max(0, pillBody.radius - inset)
                        color: root.activeFillColor

                        Behavior on width {
                            NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
                        }
                        Behavior on color {
                            ColorAnimation { duration: 220 }
                        }
                    }

                    // Content inside pill (when percentagePosition === "inside")
                    Row {
                        id: insideContentRow
                        anchors.centerIn: parent
                        spacing: 3
                        visible: root.cfgPosition === "inside"

                        PowerStatusIcon {
                            visible: root.cfgShowChargingIcon && root.pluggedIn
                            iconValue: root.currentPowerIcon
                            iconSize: root.cfgChargingIconSize
                            iconColor: root.effectiveTextColor
                            useOutline: root.cfgTextOutline
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: root.percentLabel
                            font.family: root.cfgFontFamily
                            font.pixelSize: root.cfgFontSize
                            font.weight: root.cfgFontWeight
                            font.italic: root.cfgFontItalic
                            color: root.effectiveTextColor
                            anchors.verticalCenter: parent.verticalCenter
                            style: root.cfgTextOutline ? Text.Outline : Text.Normal
                            styleColor: root.outlineColorFor(root.effectiveTextColor, 0.47)
                        }
                    }

                    // Charging/AC icon inside pill when percentage is before or after
                    PowerStatusIcon {
                        anchors.centerIn: parent
                        visible: root.cfgPosition !== "inside" && root.cfgShowChargingIcon && root.pluggedIn
                        iconValue: root.currentPowerIcon
                        iconSize: root.cfgChargingIconSize
                        iconColor: root.effectiveTextColor
                        useOutline: root.cfgTextOutline
                    }
                }

                // Battery terminal nub on right side
                Rectangle {
                    visible: root.cfgShowBatteryNub
                    anchors.left: pillBody.right
                    anchors.leftMargin: 1
                    anchors.verticalCenter: pillBody.verticalCenter
                    width: 2.5
                    height: Math.max(6, pillBody.height * 0.42)
                    radius: 1.2
                    color: root.effectiveBorderColor
                }
            }

            // Percentage text AFTER pill (supports both "after" and legacy "beside")
            Text {
                visible: root.cfgPosition === "after" || root.cfgPosition === "beside"
                text: root.percentLabel
                font.family: root.cfgFontFamily
                font.pixelSize: root.cfgFontSize
                font.weight: root.cfgFontWeight
                font.italic: root.cfgFontItalic
                color: root.effectiveTextColor
                verticalAlignment: Text.AlignVCenter
                style: root.cfgTextOutline ? Text.Outline : Text.Normal
                styleColor: root.outlineColorFor(root.effectiveTextColor, 0.35)
            }
        }
    }

    // ==================== FULL (POPUP) ====================
    fullRepresentation: Item {
        id: fullRoot
        implicitWidth: 336
        implicitHeight: contentCol.implicitHeight + 28
        Layout.minimumWidth: 320
        Layout.preferredWidth: implicitWidth
        Layout.maximumWidth: 360
        Layout.minimumHeight: implicitHeight
        Layout.preferredHeight: implicitHeight
        clip: true

        QQC2.ToolButton {
            id: configButton
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 6
            anchors.rightMargin: 6
            z: 2
            icon.name: "configure"
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: root.tr("configureWidget")
            onClicked: {
                var act = Plasmoid.internalAction("configure")
                if (act) act.trigger()
            }
        }

        ColumnLayout {
            id: contentCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 14
            spacing: 12

            // Header: Big percentage + status
            ColumnLayout {
                Layout.fillWidth: true
                Layout.rightMargin: configButton.implicitWidth
                spacing: 2

                RowLayout {
                    spacing: 8
                    Text {
                        text: root.capacity + "%"
                        font.family: root.cfgFontFamily
                        font.pixelSize: 28
                        font.weight: root.cfgFontWeight
                        font.italic: root.cfgFontItalic
                        color: Kirigami.Theme.textColor
                    }

                    // Status badge
                    Rectangle {
                        radius: 10
                        color: Qt.rgba(root.activeFillColor.r, root.activeFillColor.g, root.activeFillColor.b, 0.18)
                        border.color: Qt.rgba(root.activeFillColor.r, root.activeFillColor.g, root.activeFillColor.b, 0.5)
                        border.width: 1
                        implicitWidth: badgeRow.implicitWidth + 14
                        implicitHeight: 22

                        Row {
                            id: badgeRow
                            anchors.centerIn: parent
                            spacing: 4
                            PowerStatusIcon {
                                visible: root.pluggedIn
                                iconValue: root.currentPowerIcon
                                iconSize: 12
                                iconColor: root.activeFillColor
                                useOutline: false
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: root.statusBadgeText
                                font.pixelSize: 11
                                font.bold: true
                                color: root.activeFillColor
                                elide: Text.ElideRight
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                Text {
                    text: root.timeEstimate !== "--" ? root.timeEstimate : root.tr("measuringPower")
                    font.pixelSize: 12
                    color: Kirigami.Theme.disabledTextColor
                }
            }

            // Large progress bar
            Rectangle {
                Layout.fillWidth: true
                height: 10
                radius: 5
                color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.12)
                clip: true

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * Math.max(0, Math.min(100, root.capacity)) / 100.0
                    radius: 5
                    color: root.activeFillColor
                    Behavior on width { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
                }
            }

            // 2x2 Metrics Grid
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                uniformCellWidths: true
                rowSpacing: 8
                columnSpacing: 8

                // Card 1: Wattage
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 56
                    radius: 8
                    color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.06)
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 2
                        Text {
                            Layout.fillWidth: true
                            text: root.isCharging ? root.tr("chargingPower") : root.tr("dischargingPower")
                            font.pixelSize: 11
                            color: Kirigami.Theme.disabledTextColor
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: root.powerWatts > 0.05
                                ? ((root.isCharging ? "+" : "-") + root.powerWatts.toFixed(1) + " W")
                                : root.tr("directAcPower")
                            font.pixelSize: 14
                            minimumPixelSize: 11
                            fontSizeMode: Text.HorizontalFit
                            font.bold: true
                            color: Kirigami.Theme.textColor
                            elide: Text.ElideRight
                        }
                    }
                }

                // Card 2: Health
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 56
                    radius: 8
                    color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.06)
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 2
                        Text {
                            Layout.fillWidth: true
                            text: root.tr("batteryHealth")
                            font.pixelSize: 11
                            color: Kirigami.Theme.disabledTextColor
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: root.healthPercent.toFixed(1) + "%"
                            font.pixelSize: 14
                            font.bold: true
                            color: root.healthPercent >= 80 ? "#22c55e" : "#f59e0b"
                            elide: Text.ElideRight
                        }
                    }
                }

                // Card 3: Energy capacity
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 56
                    radius: 8
                    color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.06)
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 2
                        Text {
                            Layout.fillWidth: true
                            text: root.tr("energyCapacity")
                            font.pixelSize: 11
                            color: Kirigami.Theme.disabledTextColor
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: root.energyNowWh.toFixed(1) + " / " + root.energyFullWh.toFixed(1) + " Wh"
                            font.pixelSize: 13
                            minimumPixelSize: 11
                            fontSizeMode: Text.HorizontalFit
                            font.bold: true
                            color: Kirigami.Theme.textColor
                            elide: Text.ElideRight
                        }
                    }
                }

                // Card 4: Cycle count & Voltage
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 56
                    radius: 8
                    color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.06)
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 2
                        Text {
                            Layout.fillWidth: true
                            text: root.tr("cyclesAndVoltage")
                            font.pixelSize: 11
                            color: Kirigami.Theme.disabledTextColor
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: (root.cycleCount >= 0 ? root.cycleCount + " " + root.tr("cyclesUnit") : "--")
                                + (root.voltageVolts > 0 ? " • " + root.voltageVolts.toFixed(1) + "V" : "")
                            font.pixelSize: 13
                            minimumPixelSize: 11
                            fontSizeMode: Text.HorizontalFit
                            font.bold: true
                            color: Kirigami.Theme.textColor
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            // Power Profiles selector
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                visible: root.profilesAvailable

                Text {
                    text: root.tr("powerProfileTitle")
                    font.pixelSize: 12
                    font.bold: true
                    color: Kirigami.Theme.textColor
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: [
                            { id: "power-saver", label: root.tr("profileSaver"), icon: "battery-profile-powersave" },
                            { id: "balanced", label: root.tr("profileBalanced"), icon: "battery-profile-balanced" },
                            { id: "performance", label: root.tr("profilePerformance"), icon: "battery-profile-performance" }
                        ]

                        QQC2.Button {
                            required property var modelData
                            Layout.fillWidth: true
                            text: modelData.label
                            highlighted: root.activeProfile === modelData.id
                            onClicked: root.setPowerProfile(modelData.id)
                        }
                    }
                }
            }
        }
    }
}
