import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import "i18n.js" as I18n

KCM.SimpleKCM {
    id: configPage

    property string cfg_language: "auto"
    property string cfg_percentagePosition: "inside"
    property alias cfg_showChargingIcon: showChargingIconCheck.checked
    property alias cfg_showPercentSign: showPercentSignCheck.checked
    property alias cfg_showBatteryNub: showBatteryNubCheck.checked

    property string cfg_fontFamily: ""
    property alias cfg_fontSize: fontSizeSpin.value
    property int cfg_fontWeight: 700
    property alias cfg_fontItalic: fontItalicCheck.checked
    property alias cfg_textOutline: textOutlineCheck.checked

    property alias cfg_chargingIconSize: chargingIconSizeSpin.value
    property string cfg_chargingIcon: "⚡"
    property string cfg_pluggedIcon: "icons/plug-horizontal.svg"
    property alias cfg_tintCustomIcon: tintCustomIconCheck.checked

    property alias cfg_autoPillWidth: autoPillWidthCheck.checked
    property alias cfg_pillWidth: pillWidthSpin.value
    property alias cfg_pillPaddingX: pillPaddingXSpin.value
    property alias cfg_pillHeight: pillHeightSpin.value
    property alias cfg_pillRadius: pillRadiusSpin.value
    property alias cfg_borderWidth: borderWidthSpin.value
    property alias cfg_useCustomBorderColor: customBorderColorCheck.checked
    property string cfg_borderColor: "#99ffffff"

    property string cfg_normalColor: "#38bdf8"
    property string cfg_chargingColor: "#22c55e"
    property string cfg_lowColor: "#ef4444"
    property alias cfg_useCustomBackgroundColor: customBgColorCheck.checked
    property string cfg_backgroundColor: "#33ffffff"
    property alias cfg_useCustomTextColor: customTextColorCheck.checked
    property string cfg_textColor: "#ffffff"

    property alias cfg_lowBatteryThreshold: lowThresholdSpin.value
    property alias cfg_updateIntervalSec: intervalSpin.value

    property string activeColorProp: ""
    property string activeIconFileProp: ""

    function tr(key) {
        return I18n.tr(configPage.cfg_language, Qt.locale().name, key)
    }

    readonly property var languageModel: [
        { text: tr("langAuto"), value: "auto" },
        { text: tr("langVi"), value: "vi" },
        { text: tr("langEn"), value: "en" }
    ]

    readonly property var positionModel: [
        { text: tr("posInside"), value: "inside" },
        { text: tr("posBefore"), value: "before" },
        { text: tr("posAfter"), value: "after" }
    ]

    readonly property var fontList: [tr("systemDefaultFont")].concat(Qt.fontFamilies())

    readonly property var chargingPresets: [
        { text: "Lightning (⚡)", value: "⚡" },
        { text: "Vector: battery-charging", value: "battery-charging" },
        { text: "Vector: lightning", value: "lightning" },
        { text: "Vector: flash", value: "flash" },
        { text: "Arrow up (▲)", value: "▲" },
        { text: "Plus (+)", value: "+" }
    ]

    readonly property var pluggedPresets: [
        { text: "Plug horizontal (SVG)", value: "icons/plug-horizontal.svg" },
        { text: "Vector: ac-adapter", value: "ac-adapter" },
        { text: "Vector: battery-full-charging", value: "battery-full-charging" },
        { text: "Vector: emblem-checked", value: "emblem-checked" },
        { text: "Plug (🔌)", value: "🔌" },
        { text: "Lightning (⚡)", value: "⚡" },
        { text: "Check (✓)", value: "✓" }
    ]

    readonly property var weightModel: [
        { text: tr("weightLight"), value: 300 },
        { text: tr("weightRegular"), value: 400 },
        { text: tr("weightMedium"), value: 500 },
        { text: tr("weightSemiBold"), value: 600 },
        { text: tr("weightBold"), value: 700 },
        { text: tr("weightExtraBold"), value: 800 }
    ]

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

    FileDialog {
        id: iconFileDialog
        title: configPage.tr("fileDialogTitle")
        nameFilters: [
            "Icons & Images (*.svg *.svgz *.png *.webp *.ico *.jpg *.jpeg)",
            "All files (*)"
        ]
        onAccepted: {
            var chosen = selectedFile.toString()
            if (chosen.startsWith("file://")) {
                chosen = decodeURIComponent(chosen.replace("file://", ""))
            }
            if (configPage.activeIconFileProp === "charging") {
                configPage.cfg_chargingIcon = chosen
            } else if (configPage.activeIconFileProp === "plugged") {
                configPage.cfg_pluggedIcon = chosen
            }
        }
    }

    function openIconFilePicker(propName) {
        activeIconFileProp = propName
        iconFileDialog.open()
    }

    ColorDialog {
        id: colorDialog
        options: ColorDialog.ShowAlphaChannel
        onAccepted: {
            if (configPage.activeColorProp === "normal") {
                configPage.cfg_normalColor = selectedColor.toString()
            } else if (configPage.activeColorProp === "charging") {
                configPage.cfg_chargingColor = selectedColor.toString()
            } else if (configPage.activeColorProp === "low") {
                configPage.cfg_lowColor = selectedColor.toString()
            } else if (configPage.activeColorProp === "bg") {
                configPage.cfg_backgroundColor = selectedColor.toString()
            } else if (configPage.activeColorProp === "text") {
                configPage.cfg_textColor = selectedColor.toString()
            } else if (configPage.activeColorProp === "border") {
                configPage.cfg_borderColor = selectedColor.toString()
            }
        }
    }

    function openColorPicker(propName, currentHex) {
        activeColorProp = propName
        colorDialog.selectedColor = currentHex
        colorDialog.open()
    }

    Kirigami.FormLayout {
        // ========== GENERAL ==========
        QQC2.ComboBox {
            id: languageCombo
            Kirigami.FormData.label: configPage.tr("langLabel")
            textRole: "text"
            valueRole: "value"
            model: configPage.languageModel
            currentIndex: {
                for (var i = 0; i < configPage.languageModel.length; i++) {
                    if (configPage.languageModel[i].value === configPage.cfg_language) return i
                }
                return 0
            }
            onActivated: function(index) {
                configPage.cfg_language = configPage.languageModel[index].value
            }
        }

        QQC2.ComboBox {
            id: positionCombo
            Kirigami.FormData.label: configPage.tr("posLabel")
            textRole: "text"
            valueRole: "value"
            model: configPage.positionModel
            currentIndex: {
                var val = configPage.cfg_percentagePosition === "beside" ? "after" : configPage.cfg_percentagePosition
                for (var i = 0; i < configPage.positionModel.length; i++) {
                    if (configPage.positionModel[i].value === val) return i
                }
                return 0
            }
            onActivated: function(index) {
                configPage.cfg_percentagePosition = configPage.positionModel[index].value
            }
        }

        QQC2.CheckBox {
            id: showChargingIconCheck
            Kirigami.FormData.label: configPage.tr("chargingIconLabel")
            text: configPage.tr("showChargingIconText")
        }

        QQC2.CheckBox {
            id: showPercentSignCheck
            Kirigami.FormData.label: configPage.tr("percentSignLabel")
            text: configPage.tr("showPercentSignText")
        }

        QQC2.CheckBox {
            id: showBatteryNubCheck
            Kirigami.FormData.label: configPage.tr("nubLabel")
            text: configPage.tr("showNubText")
        }

        // ========== TYPOGRAPHY ==========
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: configPage.tr("sectionTypography")
        }

        QQC2.ComboBox {
            id: fontFamilyCombo
            Kirigami.FormData.label: configPage.tr("fontFamilyLabel")
            Layout.fillWidth: true
            model: configPage.fontList
            currentIndex: {
                if (!configPage.cfg_fontFamily) return 0
                var idx = configPage.fontList.indexOf(configPage.cfg_fontFamily)
                return idx >= 0 ? idx : 0
            }
            onActivated: function(index) {
                configPage.cfg_fontFamily = (index === 0) ? "" : configPage.fontList[index]
            }
        }

        QQC2.ComboBox {
            id: fontWeightCombo
            Kirigami.FormData.label: configPage.tr("fontWeightLabel")
            textRole: "text"
            valueRole: "value"
            model: configPage.weightModel
            currentIndex: {
                for (var i = 0; i < configPage.weightModel.length; i++) {
                    if (configPage.weightModel[i].value === configPage.cfg_fontWeight) return i
                }
                return 4
            }
            onActivated: function(index) {
                configPage.cfg_fontWeight = configPage.weightModel[index].value
            }
        }

        QQC2.SpinBox {
            id: fontSizeSpin
            Kirigami.FormData.label: configPage.tr("fontSizeLabel")
            from: 8
            to: 28
        }

        RowLayout {
            Kirigami.FormData.label: configPage.tr("textEffectsLabel")
            spacing: 14
            QQC2.CheckBox {
                id: fontItalicCheck
                text: configPage.tr("italicText")
            }
            QQC2.CheckBox {
                id: textOutlineCheck
                text: configPage.tr("outlineText")
            }
        }

        // ========== CHARGING & AC ICONS ==========
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: configPage.tr("sectionIcons")
        }

        QQC2.SpinBox {
            id: chargingIconSizeSpin
            Kirigami.FormData.label: configPage.tr("iconSizeLabel")
            from: 6
            to: 32
        }

        QQC2.CheckBox {
            id: tintCustomIconCheck
            Kirigami.FormData.label: configPage.tr("tintIconLabel")
            text: configPage.tr("tintIconText")
        }

        ColumnLayout {
            Kirigami.FormData.label: configPage.tr("chargingIconField")
            Layout.fillWidth: true
            spacing: 6

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                QQC2.ComboBox {
                    id: chargingPresetCombo
                    Layout.fillWidth: true
                    textRole: "text"
                    valueRole: "value"
                    model: configPage.chargingPresets
                    displayText: {
                        for (var i = 0; i < configPage.chargingPresets.length; i++) {
                            if (configPage.chargingPresets[i].value === configPage.cfg_chargingIcon) {
                                return configPage.chargingPresets[i].text
                            }
                        }
                        if (configPage.isFileIcon(configPage.cfg_chargingIcon)) {
                            var parts = configPage.cfg_chargingIcon.split("/")
                            return configPage.tr("filePrefix") + ": " + parts[parts.length - 1]
                        }
                        return configPage.tr("customPrefix") + " (" + configPage.cfg_chargingIcon + ")"
                    }
                    onActivated: function(index) {
                        configPage.cfg_chargingIcon = configPage.chargingPresets[index].value
                    }
                }

                QQC2.Button {
                    text: configPage.tr("chooseFileBtn")
                    icon.name: "document-open"
                    onClicked: configPage.openIconFilePicker("charging")
                }

                Rectangle {
                    width: 28; height: 28; radius: 6
                    color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.1)
                    Image {
                        anchors.centerIn: parent
                        visible: configPage.isFileIcon(configPage.cfg_chargingIcon) && !configPage.cfg_tintCustomIcon
                        source: visible ? configPage.toFileUrl(configPage.cfg_chargingIcon) : ""
                        width: 18; height: 18
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }
                    Kirigami.Icon {
                        anchors.centerIn: parent
                        visible: configPage.isThemeIconName(configPage.cfg_chargingIcon)
                            || (configPage.isFileIcon(configPage.cfg_chargingIcon) && configPage.cfg_tintCustomIcon)
                        source: visible ? (configPage.isFileIcon(configPage.cfg_chargingIcon)
                            ? configPage.toFileUrl(configPage.cfg_chargingIcon)
                            : configPage.cfg_chargingIcon) : ""
                        width: 18; height: 18
                        isMask: true
                        color: Kirigami.Theme.textColor
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: !configPage.isFileIcon(configPage.cfg_chargingIcon)
                            && !configPage.isThemeIconName(configPage.cfg_chargingIcon)
                        text: configPage.cfg_chargingIcon
                        font.pixelSize: 15
                        color: Kirigami.Theme.textColor
                    }
                }
            }

            QQC2.TextField {
                Layout.fillWidth: true
                placeholderText: configPage.tr("chargingPlaceholder")
                text: configPage.cfg_chargingIcon
                onTextEdited: configPage.cfg_chargingIcon = text
            }
        }

        ColumnLayout {
            Kirigami.FormData.label: configPage.tr("pluggedIconField")
            Layout.fillWidth: true
            spacing: 6

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                QQC2.ComboBox {
                    id: pluggedPresetCombo
                    Layout.fillWidth: true
                    textRole: "text"
                    valueRole: "value"
                    model: configPage.pluggedPresets
                    displayText: {
                        for (var i = 0; i < configPage.pluggedPresets.length; i++) {
                            if (configPage.pluggedPresets[i].value === configPage.cfg_pluggedIcon) {
                                return configPage.pluggedPresets[i].text
                            }
                        }
                        if (configPage.isFileIcon(configPage.cfg_pluggedIcon)) {
                            var parts = configPage.cfg_pluggedIcon.split("/")
                            return configPage.tr("filePrefix") + ": " + parts[parts.length - 1]
                        }
                        return configPage.tr("customPrefix") + " (" + configPage.cfg_pluggedIcon + ")"
                    }
                    onActivated: function(index) {
                        configPage.cfg_pluggedIcon = configPage.pluggedPresets[index].value
                    }
                }

                QQC2.Button {
                    text: configPage.tr("chooseFileBtn")
                    icon.name: "document-open"
                    onClicked: configPage.openIconFilePicker("plugged")
                }

                Rectangle {
                    width: 28; height: 28; radius: 6
                    color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.1)
                    Image {
                        anchors.centerIn: parent
                        visible: configPage.isFileIcon(configPage.cfg_pluggedIcon) && !configPage.cfg_tintCustomIcon
                        source: visible ? configPage.toFileUrl(configPage.cfg_pluggedIcon) : ""
                        width: 18; height: 18
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }
                    Kirigami.Icon {
                        anchors.centerIn: parent
                        visible: configPage.isThemeIconName(configPage.cfg_pluggedIcon)
                            || (configPage.isFileIcon(configPage.cfg_pluggedIcon) && configPage.cfg_tintCustomIcon)
                        source: visible ? (configPage.isFileIcon(configPage.cfg_pluggedIcon)
                            ? configPage.toFileUrl(configPage.cfg_pluggedIcon)
                            : configPage.cfg_pluggedIcon) : ""
                        width: 18; height: 18
                        isMask: true
                        color: Kirigami.Theme.textColor
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: !configPage.isFileIcon(configPage.cfg_pluggedIcon)
                            && !configPage.isThemeIconName(configPage.cfg_pluggedIcon)
                        text: configPage.cfg_pluggedIcon
                        font.pixelSize: 15
                        color: Kirigami.Theme.textColor
                    }
                }
            }

            QQC2.TextField {
                Layout.fillWidth: true
                placeholderText: configPage.tr("pluggedPlaceholder")
                text: configPage.cfg_pluggedIcon
                onTextEdited: configPage.cfg_pluggedIcon = text
            }
        }

        // ========== DIMENSIONS & BORDER ==========
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: configPage.tr("sectionDimensions")
        }

        QQC2.CheckBox {
            id: autoPillWidthCheck
            Kirigami.FormData.label: configPage.tr("autoWidthLabel")
            text: configPage.tr("autoWidthText")
        }

        QQC2.SpinBox {
            id: pillWidthSpin
            Kirigami.FormData.label: autoPillWidthCheck.checked ? configPage.tr("minWidthLabel") : configPage.tr("fixedWidthLabel")
            from: 16
            to: 240
        }

        QQC2.SpinBox {
            id: pillPaddingXSpin
            Kirigami.FormData.label: configPage.tr("paddingXLabel")
            enabled: autoPillWidthCheck.checked
            from: 2
            to: 24
        }

        QQC2.SpinBox {
            id: pillHeightSpin
            Kirigami.FormData.label: configPage.tr("pillHeightLabel")
            from: 12
            to: 38
        }

        QQC2.SpinBox {
            id: pillRadiusSpin
            Kirigami.FormData.label: configPage.tr("pillRadiusLabel")
            from: 0
            to: 19
        }

        QQC2.SpinBox {
            id: borderWidthSpin
            Kirigami.FormData.label: configPage.tr("borderWidthLabel")
            from: 0
            to: 4
        }

        RowLayout {
            Kirigami.FormData.label: configPage.tr("borderColorLabel")
            spacing: 8
            QQC2.CheckBox {
                id: customBorderColorCheck
                text: configPage.tr("customCheckbox")
            }
            Rectangle {
                width: 28; height: 20; radius: 4
                enabled: customBorderColorCheck.checked
                opacity: enabled ? 1.0 : 0.4
                color: configPage.cfg_borderColor
                border.color: Kirigami.Theme.disabledTextColor
                border.width: 1
            }
            QQC2.Button {
                text: configPage.tr("pickColorBtn")
                enabled: customBorderColorCheck.checked
                onClicked: configPage.openColorPicker("border", configPage.cfg_borderColor)
            }
        }

        // ========== COLORS ==========
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: configPage.tr("sectionColors")
        }

        RowLayout {
            Kirigami.FormData.label: configPage.tr("normalColorLabel")
            spacing: 8
            Rectangle {
                width: 28; height: 20; radius: 4
                color: configPage.cfg_normalColor
                border.color: Kirigami.Theme.disabledTextColor
                border.width: 1
            }
            QQC2.Button {
                text: configPage.tr("pickColorBtn")
                onClicked: configPage.openColorPicker("normal", configPage.cfg_normalColor)
            }
        }

        RowLayout {
            Kirigami.FormData.label: configPage.tr("chargingColorLabel")
            spacing: 8
            Rectangle {
                width: 28; height: 20; radius: 4
                color: configPage.cfg_chargingColor
                border.color: Kirigami.Theme.disabledTextColor
                border.width: 1
            }
            QQC2.Button {
                text: configPage.tr("pickColorBtn")
                onClicked: configPage.openColorPicker("charging", configPage.cfg_chargingColor)
            }
        }

        RowLayout {
            Kirigami.FormData.label: configPage.tr("lowColorLabel")
            spacing: 8
            Rectangle {
                width: 28; height: 20; radius: 4
                color: configPage.cfg_lowColor
                border.color: Kirigami.Theme.disabledTextColor
                border.width: 1
            }
            QQC2.Button {
                text: configPage.tr("pickColorBtn")
                onClicked: configPage.openColorPicker("low", configPage.cfg_lowColor)
            }
        }

        RowLayout {
            Kirigami.FormData.label: configPage.tr("bgColorLabel")
            spacing: 8
            QQC2.CheckBox {
                id: customBgColorCheck
                text: configPage.tr("customCheckbox")
            }
            Rectangle {
                width: 28; height: 20; radius: 4
                enabled: customBgColorCheck.checked
                opacity: enabled ? 1.0 : 0.4
                color: configPage.cfg_backgroundColor
                border.color: Kirigami.Theme.disabledTextColor
                border.width: 1
            }
            QQC2.Button {
                text: configPage.tr("pickColorBtn")
                enabled: customBgColorCheck.checked
                onClicked: configPage.openColorPicker("bg", configPage.cfg_backgroundColor)
            }
        }

        RowLayout {
            Kirigami.FormData.label: configPage.tr("textColorLabel")
            spacing: 8
            QQC2.CheckBox {
                id: customTextColorCheck
                text: configPage.tr("customCheckbox")
            }
            Rectangle {
                width: 28; height: 20; radius: 4
                enabled: customTextColorCheck.checked
                opacity: enabled ? 1.0 : 0.4
                color: configPage.cfg_textColor
                border.color: Kirigami.Theme.disabledTextColor
                border.width: 1
            }
            QQC2.Button {
                text: configPage.tr("pickColorBtn")
                enabled: customTextColorCheck.checked
                onClicked: configPage.openColorPicker("text", configPage.cfg_textColor)
            }
        }

        // ========== ALERTS & REFRESH ==========
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: configPage.tr("sectionAlerts")
        }

        QQC2.SpinBox {
            id: lowThresholdSpin
            Kirigami.FormData.label: configPage.tr("lowThresholdLabel")
            from: 5
            to: 50
        }

        QQC2.SpinBox {
            id: intervalSpin
            Kirigami.FormData.label: configPage.tr("intervalLabel")
            from: 1
            to: 30
        }
    }
}
