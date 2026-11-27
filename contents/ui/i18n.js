.pragma library

var translations = {
    en: {
        // Status & Popup
        statusCharging: "Charging",
        statusPluggedFullBadge: "Plugged • Full",
        statusPluggedFull: "Plugged in (Full / Holding)",
        statusPlugged: "Plugged in",
        statusDischarging: "On battery",
        measuringPower: "Measuring power...",
        timeToFull: "to full",
        timeRemaining: "remaining",
        timePluggedFull: "Full / On AC power",
        minutesUnit: "min",
        hourShort: "h",
        minShort: "m",
        tooltipHealth: "Health",
        configureWidget: "Widget settings",
        chargingPower: "Charging power",
        dischargingPower: "Power draw",
        directAcPower: "0.0 W (AC Direct)",
        batteryHealth: "Battery health",
        energyCapacity: "Capacity (Wh)",
        cyclesAndVoltage: "Cycles & Voltage",
        cyclesUnit: "cycles",
        powerProfileTitle: "Power Profile",
        profileSaver: "Power Saver",
        profileBalanced: "Balanced",
        profilePerformance: "Performance",

        // Settings
        langLabel: "Language:",
        langAuto: "System default",
        langVi: "Tiếng Việt",
        langEn: "English",
        posLabel: "Battery % position:",
        posInside: "Inside battery pill",
        posBefore: "Before battery pill",
        posAfter: "After battery pill",
        chargingIconLabel: "Power icon:",
        showChargingIconText: "Show icon when charging / on AC",
        percentSignLabel: "% symbol:",
        showPercentSignText: "Show % sign after number",
        nubLabel: "Battery tip:",
        showNubText: "Show battery terminal nub on the right",

        sectionTypography: "Battery % Typography",
        fontFamilyLabel: "Font family:",
        systemDefaultFont: "(System default)",
        fontWeightLabel: "Font weight:",
        weightLight: "Light (300)",
        weightRegular: "Regular (400)",
        weightMedium: "Medium (500)",
        weightSemiBold: "SemiBold (600)",
        weightBold: "Bold (700)",
        weightExtraBold: "ExtraBold (800)",
        fontSizeLabel: "Font size (px):",
        textEffectsLabel: "Text effects:",
        italicText: "Italic",
        outlineText: "Text outline (better contrast)",

        sectionIcons: "Charging & AC Plugged Icons",
        iconSizeLabel: "Icon size (px):",
        tintIconLabel: "Custom file icon color:",
        tintIconText: "Tint SVG/PNG with text color (uncheck to keep original)",
        chargingIconField: "Charging icon:",
        pluggedIconField: "AC plugged icon:",
        chooseFileBtn: "Browse...",
        fileDialogTitle: "Select icon file (SVG, PNG, WebP, ICO...)",
        customPrefix: "Custom",
        filePrefix: "File",
        chargingPlaceholder: "File path (/path/icon.svg), KDE icon name, or glyph (⚡)",
        pluggedPlaceholder: "File path (/path/icon.svg), KDE icon name, or glyph (🔌)",

        sectionDimensions: "Pill Size & Border",
        autoWidthLabel: "Auto width:",
        autoWidthText: "Expand to fit text & icon (uses width below as minimum)",
        minWidthLabel: "Minimum width (px):",
        fixedWidthLabel: "Fixed width (px):",
        paddingXLabel: "Horizontal padding (px):",
        pillHeightLabel: "Pill height (px):",
        pillRadiusLabel: "Corner radius (px):",
        borderWidthLabel: "Border width (px):",
        borderColorLabel: "Border color:",
        customCheckbox: "Custom",
        pickColorBtn: "Choose color",

        sectionColors: "Colors",
        normalColorLabel: "Normal battery color:",
        chargingColorLabel: "Charging / AC color:",
        lowColorLabel: "Low battery color:",
        bgColorLabel: "Pill background color:",
        textColorLabel: "Text & icon color:",

        sectionAlerts: "Alerts & Refresh",
        lowThresholdLabel: "Low battery threshold (%):",
        intervalLabel: "Refresh interval (sec):"
    },
    vi: {
        // Status & Popup
        statusCharging: "Đang sạc",
        statusPluggedFullBadge: "Cắm sạc • Đầy",
        statusPluggedFull: "Đang cắm sạc (Đã đầy / Giữ mức)",
        statusPlugged: "Đang cắm sạc",
        statusDischarging: "Đang dùng pin",
        measuringPower: "Đang đo công suất...",
        timeToFull: "tới đầy",
        timeRemaining: "còn lại",
        timePluggedFull: "Đã đầy / Cắm điện",
        minutesUnit: "phút",
        hourShort: "g",
        minShort: "p",
        tooltipHealth: "Sức khỏe",
        configureWidget: "Cài đặt widget",
        chargingPower: "Công suất sạc",
        dischargingPower: "Công suất tiêu thụ",
        directAcPower: "0.0 W (Nguồn AC)",
        batteryHealth: "Sức khỏe pin",
        energyCapacity: "Dung lượng (Wh)",
        cyclesAndVoltage: "Chu kỳ sạc & Điện áp",
        cyclesUnit: "chu kỳ",
        powerProfileTitle: "Chế độ hiệu năng (Power Profile)",
        profileSaver: "Tiết kiệm",
        profileBalanced: "Cân bằng",
        profilePerformance: "Hiệu năng",

        // Settings
        langLabel: "Ngôn ngữ:",
        langAuto: "Tự động theo hệ điều hành",
        langVi: "Tiếng Việt",
        langEn: "English",
        posLabel: "Vị trí hiển thị % pin:",
        posInside: "Bên trong thanh pin (Pill)",
        posBefore: "Phía trước thanh pin",
        posAfter: "Phía sau thanh pin",
        chargingIconLabel: "Biểu tượng sạc:",
        showChargingIconText: "Hiển thị icon khi cắm sạc / AC",
        percentSignLabel: "Ký hiệu %:",
        showPercentSignText: "Hiển thị dấu % sau con số",
        nubLabel: "Đầu cực pin:",
        showNubText: "Hiển thị núm đầu pin bên phải",

        sectionTypography: "Kiểu chữ % pin",
        fontFamilyLabel: "Font chữ:",
        systemDefaultFont: "(Mặc định hệ thống)",
        fontWeightLabel: "Độ đậm chữ:",
        weightLight: "Mảnh (Light - 300)",
        weightRegular: "Thường (Regular - 400)",
        weightMedium: "Trung bình (Medium - 500)",
        weightSemiBold: "Hơi đậm (SemiBold - 600)",
        weightBold: "Đậm (Bold - 700)",
        weightExtraBold: "Rất đậm (ExtraBold - 800)",
        fontSizeLabel: "Cỡ chữ (px):",
        textEffectsLabel: "Hiệu ứng chữ:",
        italicText: "In nghiêng",
        outlineText: "Viền bóng chữ (dễ đọc)",

        sectionIcons: "Icon cắm sạc (Charging & AC Plugged)",
        iconSizeLabel: "Kích thước icon (px):",
        tintIconLabel: "Màu icon file ngoài:",
        tintIconText: "Nhuộm màu file SVG/PNG theo màu chữ (bỏ chọn để giữ màu gốc)",
        chargingIconField: "Icon đang sạc:",
        pluggedIconField: "Icon cắm nguồn (AC):",
        chooseFileBtn: "Chọn file...",
        fileDialogTitle: "Chọn file icon (SVG, PNG, WebP, ICO...)",
        customPrefix: "Tùy chỉnh",
        filePrefix: "File",
        chargingPlaceholder: "Đường dẫn file (/path/icon.svg), tên KDE icon, hoặc ký tự (⚡)",
        pluggedPlaceholder: "Đường dẫn file (/path/icon.svg), tên KDE icon, hoặc ký tự (🔌)",

        sectionDimensions: "Kích thước & Viền thanh pin (Border)",
        autoWidthLabel: "Co giãn độ rộng:",
        autoWidthText: "Tự động mở rộng theo chữ & icon (dùng chiều rộng bên dưới làm tối thiểu)",
        minWidthLabel: "Chiều rộng tối thiểu (px):",
        fixedWidthLabel: "Chiều rộng cố định (px):",
        paddingXLabel: "Khoảng đệm ngang (px):",
        pillHeightLabel: "Chiều cao thanh pin (px):",
        pillRadiusLabel: "Bo góc thanh pin (px):",
        borderWidthLabel: "Độ dày viền pin (px):",
        borderColorLabel: "Màu viền pin:",
        customCheckbox: "Tùy chỉnh",
        pickColorBtn: "Chọn màu",

        sectionColors: "Màu sắc",
        normalColorLabel: "Màu pin bình thường:",
        chargingColorLabel: "Màu khi cắm sạc:",
        lowColorLabel: "Màu pin yếu:",
        bgColorLabel: "Màu nền thanh pin:",
        textColorLabel: "Màu chữ % & icon:",

        sectionAlerts: "Cảnh báo & Cập nhật",
        lowThresholdLabel: "Ngưỡng pin yếu (%):",
        intervalLabel: "Chu kỳ làm mới (giây):"
    }
};

function resolveLang(setting, localeName) {
    if (setting === "vi" || setting === "en") {
        return setting;
    }
    var loc = (localeName || "").toLowerCase();
    if (loc.indexOf("vi") === 0) {
        return "vi";
    }
    return "en";
}

function tr(setting, localeName, key) {
    var lang = resolveLang(setting, localeName);
    var dict = translations[lang] || translations.en;
    return dict[key] !== undefined ? dict[key] : (translations.en[key] || key);
}
