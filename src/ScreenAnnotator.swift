import Cocoa
import Carbon.HIToolbox

private let hotKeySignature = OSType(
    (UInt32(UInt8(ascii: "S")) << 24) |
    (UInt32(UInt8(ascii: "A")) << 16) |
    (UInt32(UInt8(ascii: "N")) << 8) |
    UInt32(UInt8(ascii: "N"))
)

private struct ShortcutModifier {
    let title: String
    let carbonValue: UInt32
}

private struct ShortcutKey {
    let title: String
    let carbonKeyCode: UInt32
}

private struct Shortcut {
    let key: ShortcutKey
    let modifier: ShortcutModifier

    var displayText: String {
        "\(modifier.title)+\(key.title)"
    }
}

private enum HotKeyAction: UInt32, CaseIterable {
    case rectangle = 1
    case arrow = 2
    case step = 3
    case brush = 4
    case nextStep = 5

    var title: String {
        switch self {
        case .rectangle: return "矩形标注"
        case .arrow: return "箭头标注"
        case .step: return "步骤标注"
        case .brush: return "自由画笔"
        case .nextStep: return "下一步编号"
        }
    }

    var defaultKeyCode: UInt32 {
        switch self {
        case .rectangle: return UInt32(kVK_ANSI_1)
        case .arrow: return UInt32(kVK_ANSI_2)
        case .step: return UInt32(kVK_ANSI_3)
        case .brush: return UInt32(kVK_ANSI_4)
        case .nextStep: return UInt32(kVK_ANSI_5)
        }
    }

    var defaultKeyTitle: String {
        switch self {
        case .rectangle: return "1"
        case .arrow: return "2"
        case .step: return "3"
        case .brush: return "4"
        case .nextStep: return "5"
        }
    }
}

private enum ShortcutStore {
    static let modifiers: [ShortcutModifier] = [
        ShortcutModifier(title: "Option", carbonValue: UInt32(optionKey)),
        ShortcutModifier(title: "Shift", carbonValue: UInt32(shiftKey)),
        ShortcutModifier(title: "Control", carbonValue: UInt32(controlKey)),
        ShortcutModifier(title: "Command", carbonValue: UInt32(cmdKey)),
        ShortcutModifier(title: "Option+Shift", carbonValue: UInt32(optionKey | shiftKey)),
        ShortcutModifier(title: "Control+Option", carbonValue: UInt32(controlKey | optionKey))
    ]

    static let keys: [ShortcutKey] = [
        ShortcutKey(title: "1", carbonKeyCode: UInt32(kVK_ANSI_1)),
        ShortcutKey(title: "2", carbonKeyCode: UInt32(kVK_ANSI_2)),
        ShortcutKey(title: "3", carbonKeyCode: UInt32(kVK_ANSI_3)),
        ShortcutKey(title: "4", carbonKeyCode: UInt32(kVK_ANSI_4)),
        ShortcutKey(title: "5", carbonKeyCode: UInt32(kVK_ANSI_5)),
        ShortcutKey(title: "6", carbonKeyCode: UInt32(kVK_ANSI_6)),
        ShortcutKey(title: "7", carbonKeyCode: UInt32(kVK_ANSI_7)),
        ShortcutKey(title: "8", carbonKeyCode: UInt32(kVK_ANSI_8)),
        ShortcutKey(title: "9", carbonKeyCode: UInt32(kVK_ANSI_9)),
        ShortcutKey(title: "A", carbonKeyCode: UInt32(kVK_ANSI_A)),
        ShortcutKey(title: "B", carbonKeyCode: UInt32(kVK_ANSI_B)),
        ShortcutKey(title: "C", carbonKeyCode: UInt32(kVK_ANSI_C)),
        ShortcutKey(title: "D", carbonKeyCode: UInt32(kVK_ANSI_D)),
        ShortcutKey(title: "E", carbonKeyCode: UInt32(kVK_ANSI_E)),
        ShortcutKey(title: "F", carbonKeyCode: UInt32(kVK_ANSI_F)),
        ShortcutKey(title: "G", carbonKeyCode: UInt32(kVK_ANSI_G)),
        ShortcutKey(title: "H", carbonKeyCode: UInt32(kVK_ANSI_H)),
        ShortcutKey(title: "J", carbonKeyCode: UInt32(kVK_ANSI_J)),
        ShortcutKey(title: "K", carbonKeyCode: UInt32(kVK_ANSI_K)),
        ShortcutKey(title: "L", carbonKeyCode: UInt32(kVK_ANSI_L)),
        ShortcutKey(title: "Q", carbonKeyCode: UInt32(kVK_ANSI_Q)),
        ShortcutKey(title: "R", carbonKeyCode: UInt32(kVK_ANSI_R)),
        ShortcutKey(title: "S", carbonKeyCode: UInt32(kVK_ANSI_S)),
        ShortcutKey(title: "T", carbonKeyCode: UInt32(kVK_ANSI_T)),
        ShortcutKey(title: "W", carbonKeyCode: UInt32(kVK_ANSI_W)),
        ShortcutKey(title: "X", carbonKeyCode: UInt32(kVK_ANSI_X)),
        ShortcutKey(title: "Z", carbonKeyCode: UInt32(kVK_ANSI_Z))
    ]

    static func shortcut(for action: HotKeyAction) -> Shortcut {
        let defaults = UserDefaults.standard
        let keyCode = defaults.object(forKey: keyCodeKey(action)) == nil ? action.defaultKeyCode : UInt32(defaults.integer(forKey: keyCodeKey(action)))
        let modifierValue = defaults.object(forKey: modifierKey(action)) == nil ? UInt32(optionKey) : UInt32(defaults.integer(forKey: modifierKey(action)))
        let key = keys.first(where: { $0.carbonKeyCode == keyCode }) ?? ShortcutKey(title: action.defaultKeyTitle, carbonKeyCode: action.defaultKeyCode)
        let modifier = modifiers.first(where: { $0.carbonValue == modifierValue }) ?? modifiers[0]
        return Shortcut(key: key, modifier: modifier)
    }

    static func save(shortcut: Shortcut, for action: HotKeyAction) {
        UserDefaults.standard.set(shortcut.key.carbonKeyCode, forKey: keyCodeKey(action))
        UserDefaults.standard.set(shortcut.modifier.carbonValue, forKey: modifierKey(action))
    }

    static func display(for action: HotKeyAction) -> String {
        shortcut(for: action).displayText
    }

    private static func keyCodeKey(_ action: HotKeyAction) -> String {
        "shortcut.\(action.rawValue).keyCode"
    }

    private static func modifierKey(_ action: HotKeyAction) -> String {
        "shortcut.\(action.rawValue).modifier"
    }
}

private enum ToolMode: Int {
    case rectangle = 1
    case arrow = 2
    case step = 3
    case brush = 4

    var title: String {
        switch self {
        case .rectangle: return "矩形"
        case .arrow: return "箭头"
        case .step: return "步骤"
        case .brush: return "画笔"
        }
    }
}

private final class Annotation {
    enum Shape {
        case rectangle(NSRect)
        case arrow(from: NSPoint, to: NSPoint)
        case step(number: Int, point: NSPoint)
        case brush(points: [NSPoint])
    }

    var shape: Shape
    var color: NSColor

    init(shape: Shape, color: NSColor) {
        self.shape = shape
        self.color = color
    }
}

private final class OverlayWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

private protocol SettingsWindowControllerDelegate: AnyObject {
    func settingsDidSaveShortcuts()
}

private final class SettingsWindowController: NSWindowController {
    weak var settingsDelegate: SettingsWindowControllerDelegate?
    private var modifierPopups: [HotKeyAction: NSPopUpButton] = [:]
    private var keyPopups: [HotKeyAction: NSPopUpButton] = [:]

    convenience init(delegate: SettingsWindowControllerDelegate) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 360),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Screen Annotator Settings"
        window.isReleasedWhenClosed = false
        window.center()
        self.init(window: window)
        self.settingsDelegate = delegate
        buildContent()
    }

    private func buildContent() {
        guard let window else { return }
        let root = NSView(frame: window.contentView?.bounds ?? .zero)
        root.translatesAutoresizingMaskIntoConstraints = false

        let title = NSTextField(labelWithString: "快捷键设置")
        title.font = NSFont.systemFont(ofSize: 20, weight: .semibold)

        let subtitle = NSTextField(labelWithString: "保存后立即重新注册全局快捷键。建议每个动作使用不同组合。")
        subtitle.font = NSFont.systemFont(ofSize: 13)
        subtitle.textColor = .secondaryLabelColor

        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 12
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.addArrangedSubview(title)
        stack.addArrangedSubview(subtitle)

        let header = row(labels: ["动作", "修饰键", "按键"], isHeader: true)
        stack.addArrangedSubview(header)

        for action in HotKeyAction.allCases {
            let shortcut = ShortcutStore.shortcut(for: action)
            let actionLabel = NSTextField(labelWithString: action.title)
            actionLabel.font = NSFont.systemFont(ofSize: 14, weight: .medium)
            actionLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true

            let modifierPopup = NSPopUpButton(frame: .zero, pullsDown: false)
            for modifier in ShortcutStore.modifiers {
                modifierPopup.addItem(withTitle: modifier.title)
                modifierPopup.lastItem?.representedObject = Int(modifier.carbonValue)
            }
            modifierPopup.selectItem(withTitle: shortcut.modifier.title)
            modifierPopup.widthAnchor.constraint(equalToConstant: 160).isActive = true
            modifierPopups[action] = modifierPopup

            let keyPopup = NSPopUpButton(frame: .zero, pullsDown: false)
            for key in ShortcutStore.keys {
                keyPopup.addItem(withTitle: key.title)
                keyPopup.lastItem?.representedObject = Int(key.carbonKeyCode)
            }
            keyPopup.selectItem(withTitle: shortcut.key.title)
            keyPopup.widthAnchor.constraint(equalToConstant: 92).isActive = true
            keyPopups[action] = keyPopup

            let row = NSStackView(views: [actionLabel, modifierPopup, keyPopup])
            row.orientation = .horizontal
            row.spacing = 12
            row.alignment = .centerY
            stack.addArrangedSubview(row)
        }

        let buttons = NSStackView()
        buttons.orientation = .horizontal
        buttons.spacing = 10
        buttons.alignment = .centerY

        let resetButton = NSButton(title: "恢复默认", target: self, action: #selector(resetDefaults))
        let saveButton = NSButton(title: "保存", target: self, action: #selector(save))
        saveButton.keyEquivalent = "\r"
        saveButton.bezelStyle = .rounded

        buttons.addArrangedSubview(resetButton)
        buttons.addArrangedSubview(saveButton)
        stack.addArrangedSubview(buttons)

        root.addSubview(stack)
        window.contentView = root

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 26),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: root.trailingAnchor, constant: -26),
            stack.topAnchor.constraint(equalTo: root.topAnchor, constant: 24)
        ])
    }

    private func row(labels: [String], isHeader: Bool) -> NSStackView {
        let widths: [CGFloat] = [150, 160, 92]
        let views = zip(labels, widths).map { label, width in
            let field = NSTextField(labelWithString: label)
            field.font = isHeader ? NSFont.systemFont(ofSize: 12, weight: .semibold) : NSFont.systemFont(ofSize: 13)
            field.textColor = isHeader ? .secondaryLabelColor : .labelColor
            field.widthAnchor.constraint(equalToConstant: width).isActive = true
            return field
        }
        let row = NSStackView(views: views)
        row.orientation = .horizontal
        row.spacing = 12
        return row
    }

    @objc private func save() {
        var seen: Set<String> = []
        for action in HotKeyAction.allCases {
            guard
                let modifierValue = modifierPopups[action]?.selectedItem?.representedObject as? Int,
                let keyCode = keyPopups[action]?.selectedItem?.representedObject as? Int,
                let modifierCarbonValue = UInt32(exactly: modifierValue),
                let keyCarbonCode = UInt32(exactly: keyCode),
                let modifier = ShortcutStore.modifiers.first(where: { $0.carbonValue == modifierCarbonValue }),
                let key = ShortcutStore.keys.first(where: { $0.carbonKeyCode == keyCarbonCode })
            else {
                continue
            }

            let uniqueKey = "\(modifierCarbonValue)-\(keyCarbonCode)"
            if seen.contains(uniqueKey) {
                showAlert(message: "快捷键重复", info: "请为每个动作设置不同的快捷键组合。")
                return
            }
            seen.insert(uniqueKey)
            ShortcutStore.save(shortcut: Shortcut(key: key, modifier: modifier), for: action)
        }

        settingsDelegate?.settingsDidSaveShortcuts()
        window?.close()
    }

    @objc private func resetDefaults() {
        for action in HotKeyAction.allCases {
            modifierPopups[action]?.selectItem(withTitle: "Option")
            keyPopups[action]?.selectItem(withTitle: action.defaultKeyTitle)
        }
    }

    private func showAlert(message: String, info: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = info
        alert.runModal()
    }
}

private final class AnnotationView: NSView {
    private var annotations: [Annotation] = []
    private var startPoint: NSPoint?
    private var currentPoint: NSPoint?
    private var currentRect: NSRect?
    private var currentBrushPoints: [NSPoint] = []
    private var mode: ToolMode = .rectangle
    private var colorIndex = 0
    private var nextStepNumber = 1
    private var dimBackground = false

    private let colors: [NSColor] = [
        NSColor.systemRed,
        NSColor.systemYellow,
        NSColor.systemGreen,
        NSColor.systemBlue,
        NSColor.systemPurple
    ]
    private let colorNames = ["红色", "黄色", "绿色", "蓝色", "紫色"]

    override var acceptsFirstResponder: Bool { true }

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .crosshair)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        if dimBackground {
            NSColor.black.withAlphaComponent(0.18).setFill()
            bounds.fill()
        } else {
            NSColor.black.withAlphaComponent(0.025).setFill()
            bounds.fill()
        }

        for annotation in annotations {
            draw(annotation: annotation, isPreview: false)
        }

        if let startPoint, let currentPoint {
            drawPreview(from: startPoint, to: currentPoint)
        }
        if mode == .brush, currentBrushPoints.count > 1 {
            drawBrush(points: currentBrushPoints, color: currentColor, isPreview: true)
        }

        drawHelpStrip()
    }

    override func mouseDown(with event: NSEvent) {
        startPoint = convert(event.locationInWindow, from: nil)
        currentPoint = startPoint
        currentBrushPoints = startPoint.map { [$0] } ?? []
        currentRect = nil
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        guard let startPoint else { return }
        let point = convert(event.locationInWindow, from: nil)
        currentPoint = point
        currentRect = normalizedRect(from: startPoint, to: point)
        if mode == .brush {
            currentBrushPoints.append(point)
        }
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        guard let startPoint else { return }
        let point = convert(event.locationInWindow, from: nil)
        let rect = normalizedRect(from: startPoint, to: point)

        switch mode {
        case .rectangle:
            if rect.width > 8 && rect.height > 8 {
                annotations.append(Annotation(shape: .rectangle(rect), color: currentColor))
            }
        case .arrow:
            if distance(from: startPoint, to: point) > 10 {
                annotations.append(Annotation(shape: .arrow(from: startPoint, to: point), color: currentColor))
            }
        case .step:
            annotations.append(Annotation(shape: .step(number: nextStepNumber, point: point), color: currentColor))
            nextStepNumber += 1
        case .brush:
            if currentBrushPoints.count > 1 {
                annotations.append(Annotation(shape: .brush(points: currentBrushPoints), color: currentColor))
            }
        }

        self.startPoint = nil
        currentPoint = nil
        currentRect = nil
        currentBrushPoints = []
        needsDisplay = true
    }

    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case UInt16(kVK_Escape):
            clear()
            window?.orderOut(nil)
        case UInt16(kVK_ANSI_C):
            clear()
        case UInt16(kVK_ANSI_Z):
            undo()
        case UInt16(kVK_ANSI_R):
            colorIndex = (colorIndex + 1) % colors.count
            needsDisplay = true
        case UInt16(kVK_ANSI_1):
            setMode(.rectangle)
        case UInt16(kVK_ANSI_2):
            setMode(.arrow)
        case UInt16(kVK_ANSI_3):
            setMode(.step)
        case UInt16(kVK_ANSI_4):
            setMode(.brush)
        case UInt16(kVK_ANSI_5):
            nextStepNumber += 1
            setMode(.step)
        case UInt16(kVK_Space):
            dimBackground.toggle()
            needsDisplay = true
        default:
            super.keyDown(with: event)
        }
    }

    func setMode(_ mode: ToolMode) {
        self.mode = mode
        currentRect = nil
        currentPoint = nil
        startPoint = nil
        currentBrushPoints = []
        needsDisplay = true
    }

    func incrementStepNumber() {
        nextStepNumber += 1
        setMode(.step)
    }

    func clear() {
        annotations.removeAll()
        currentRect = nil
        currentPoint = nil
        currentBrushPoints = []
        nextStepNumber = 1
        needsDisplay = true
    }

    func cancelCurrentGesture() {
        currentRect = nil
        currentPoint = nil
        startPoint = nil
        currentBrushPoints = []
        needsDisplay = true
    }

    func undo() {
        _ = annotations.popLast()
        nextStepNumber = max(1, nextStepNumber - 1)
        needsDisplay = true
    }

    private var currentColor: NSColor {
        colors[colorIndex]
    }

    private var currentColorName: String {
        colorNames[colorIndex]
    }

    private func normalizedRect(from first: NSPoint, to second: NSPoint) -> NSRect {
        NSRect(
            x: min(first.x, second.x),
            y: min(first.y, second.y),
            width: abs(first.x - second.x),
            height: abs(first.y - second.y)
        )
    }

    private func distance(from first: NSPoint, to second: NSPoint) -> CGFloat {
        hypot(first.x - second.x, first.y - second.y)
    }

    private func draw(annotation: Annotation, isPreview: Bool) {
        switch annotation.shape {
        case .rectangle(let rect):
            draw(rect: rect, color: annotation.color, isPreview: isPreview)
        case .arrow(let start, let end):
            drawArrow(from: start, to: end, color: annotation.color, isPreview: isPreview)
        case .step(let number, let point):
            drawStep(number: number, at: point, color: annotation.color, isPreview: isPreview)
        case .brush(let points):
            drawBrush(points: points, color: annotation.color, isPreview: isPreview)
        }
    }

    private func drawPreview(from start: NSPoint, to end: NSPoint) {
        switch mode {
        case .rectangle:
            draw(rect: normalizedRect(from: start, to: end), color: currentColor, isPreview: true)
        case .arrow:
            drawArrow(from: start, to: end, color: currentColor, isPreview: true)
        case .step:
            drawStep(number: nextStepNumber, at: end, color: currentColor, isPreview: true)
        case .brush:
            break
        }
    }

    private func draw(rect: NSRect, color: NSColor, isPreview: Bool) {
        let path = NSBezierPath(roundedRect: rect, xRadius: 8, yRadius: 8)
        color.withAlphaComponent(isPreview ? 0.16 : 0.10).setFill()
        path.fill()

        color.setStroke()
        path.lineWidth = isPreview ? 4 : 5
        path.stroke()

        let glow = NSBezierPath(roundedRect: rect.insetBy(dx: -2, dy: -2), xRadius: 10, yRadius: 10)
        color.withAlphaComponent(0.22).setStroke()
        glow.lineWidth = 3
        glow.stroke()
    }

    private func drawArrow(from start: NSPoint, to end: NSPoint, color: NSColor, isPreview: Bool) {
        let totalLength = distance(from: start, to: end)
        guard totalLength > 8 else { return }

        let angle = atan2(end.y - start.y, end.x - start.x)
        let shaftWidth = min(max(totalLength * 0.055, 9), isPreview ? 18 : 24)
        let headLength = min(max(totalLength * 0.13, 28), 58)
        let headWidth = shaftWidth * 2.25
        let perpendicular = angle + .pi / 2
        let headBase = point(from: end, distance: -headLength, angle: angle)
        let neck = point(from: end, distance: -headLength * 0.72, angle: angle)
        let tailJoin = point(from: start, distance: min(totalLength * 0.78, max(totalLength - headLength * 0.80, 0)), angle: angle)

        let arrow = NSBezierPath()
        arrow.move(to: start)
        arrow.line(to: offset(tailJoin, perpendicular: perpendicular, amount: shaftWidth / 2))
        arrow.line(to: offset(neck, perpendicular: perpendicular, amount: shaftWidth / 2))
        arrow.line(to: offset(headBase, perpendicular: perpendicular, amount: headWidth / 2))
        arrow.line(to: end)
        arrow.line(to: offset(headBase, perpendicular: perpendicular, amount: -headWidth / 2))
        arrow.line(to: offset(neck, perpendicular: perpendicular, amount: -shaftWidth / 2))
        arrow.line(to: offset(tailJoin, perpendicular: perpendicular, amount: -shaftWidth / 2))
        arrow.close()

        color.withAlphaComponent(isPreview ? 0.82 : 0.98).setFill()
        arrow.fill()
    }

    private func point(from point: NSPoint, distance: CGFloat, angle: CGFloat) -> NSPoint {
        NSPoint(x: point.x + distance * cos(angle), y: point.y + distance * sin(angle))
    }

    private func offset(_ point: NSPoint, perpendicular: CGFloat, amount: CGFloat) -> NSPoint {
        NSPoint(x: point.x + amount * cos(perpendicular), y: point.y + amount * sin(perpendicular))
    }

    private func drawStep(number: Int, at point: NSPoint, color: NSColor, isPreview: Bool) {
        let radius: CGFloat = 18
        let rect = NSRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
        let circle = NSBezierPath(ovalIn: rect)

        color.withAlphaComponent(isPreview ? 0.72 : 0.92).setFill()
        circle.fill()
        NSColor.white.setStroke()
        circle.lineWidth = 3
        circle.stroke()

        let text = "\(number)"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 18, weight: .bold),
            .foregroundColor: NSColor.white
        ]
        let attributed = NSAttributedString(string: text, attributes: attributes)
        let size = attributed.size()
        attributed.draw(at: NSPoint(x: point.x - size.width / 2, y: point.y - size.height / 2))
    }

    private func drawBrush(points: [NSPoint], color: NSColor, isPreview: Bool) {
        guard points.count > 1 else { return }
        let path = NSBezierPath()
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.line(to: point)
        }
        path.lineWidth = isPreview ? 5 : 6
        path.lineCapStyle = .round
        path.lineJoinStyle = .round

        let glow = path.copy() as? NSBezierPath
        glow?.lineWidth = path.lineWidth + 6
        color.withAlphaComponent(0.18).setStroke()
        glow?.stroke()

        color.withAlphaComponent(isPreview ? 0.80 : 0.95).setStroke()
        path.stroke()
    }

    private func drawHelpStrip() {
        let text = "颜色：\(currentColorName)  ·  当前：\(mode.title)  ·  \(ShortcutStore.display(for: .rectangle)) 矩形  ·  \(ShortcutStore.display(for: .arrow)) 箭头  ·  \(ShortcutStore.display(for: .step)) 步骤  ·  \(ShortcutStore.display(for: .brush)) 画笔  ·  \(ShortcutStore.display(for: .nextStep)) 下一步  ·  R 换色  ·  Z 撤销  ·  C 清空  ·  Space 聚焦  ·  Esc 退出"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: NSColor.white
        ]
        let attributed = NSAttributedString(string: text, attributes: attributes)
        let size = attributed.size()
        let paddingX: CGFloat = 16
        let paddingY: CGFloat = 9
        let swatchSize: CGFloat = 14
        let swatchGap: CGFloat = 9
        let stripRect = NSRect(
            x: max(20, (bounds.width - size.width - swatchSize - swatchGap) / 2 - paddingX),
            y: bounds.height - size.height - 28 - paddingY * 2,
            width: size.width + swatchSize + swatchGap + paddingX * 2,
            height: size.height + paddingY * 2
        )

        let background = NSBezierPath(roundedRect: stripRect, xRadius: 8, yRadius: 8)
        NSColor.black.withAlphaComponent(0.54).setFill()
        background.fill()

        let swatchRect = NSRect(
            x: stripRect.minX + paddingX,
            y: stripRect.midY - swatchSize / 2,
            width: swatchSize,
            height: swatchSize
        )
        let swatch = NSBezierPath(ovalIn: swatchRect)
        currentColor.setFill()
        swatch.fill()
        NSColor.white.withAlphaComponent(0.88).setStroke()
        swatch.lineWidth = 1.5
        swatch.stroke()

        attributed.draw(at: NSPoint(x: swatchRect.maxX + swatchGap, y: stripRect.minY + paddingY))
    }
}

private final class AppDelegate: NSObject, NSApplicationDelegate, SettingsWindowControllerDelegate {
    private var windows: [OverlayWindow] = []
    private var hotKeyRefs: [EventHotKeyRef] = []
    private var eventHandlerRef: EventHandlerRef?
    private var shiftMonitor: Any?
    private var localShiftMonitor: Any?
    private var isShiftHoldActive = false
    private var statusItem: NSStatusItem?
    private var settingsWindowController: SettingsWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        createWindows()
        createStatusItem()
        installShiftHoldMonitors()
        registerHotKey()
    }

    func applicationWillTerminate(_ notification: Notification) {
        for hotKeyRef in hotKeyRefs {
            UnregisterEventHotKey(hotKeyRef)
        }
        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
        }
        if let shiftMonitor {
            NSEvent.removeMonitor(shiftMonitor)
        }
        if let localShiftMonitor {
            NSEvent.removeMonitor(localShiftMonitor)
        }
    }

    func activateMode(_ mode: ToolMode) {
        showOverlay()
        for window in windows {
            (window.contentView as? AnnotationView)?.setMode(mode)
        }
    }

    func bumpStepNumber() {
        showOverlay()
        for window in windows {
            let view = window.contentView as? AnnotationView
            view?.setMode(.step)
            view?.incrementStepNumber()
        }
    }

    private func installShiftHoldMonitors() {
        shiftMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            DispatchQueue.main.async {
                self?.handleModifierFlags(event.modifierFlags)
            }
        }
        localShiftMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleModifierFlags(event.modifierFlags)
            return event
        }
    }

    private func handleModifierFlags(_ flags: NSEvent.ModifierFlags) {
        let relevantFlags = flags.intersection([.shift, .control, .option, .command])
        let isShiftOnly = relevantFlags == .shift

        if isShiftOnly && !isShiftHoldActive {
            isShiftHoldActive = true
            showOverlay()
        } else if !isShiftOnly && isShiftHoldActive {
            isShiftHoldActive = false
            clearAndHideOverlay()
        }
    }

    func settingsDidSaveShortcuts() {
        reloadHotKeys()
        for window in windows {
            window.contentView?.needsDisplay = true
        }
    }

    @objc private func openSettings() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController(delegate: self)
        }
        settingsWindowController?.showWindow(nil)
        settingsWindowController?.window?.center()
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    private func createWindows() {
        windows = NSScreen.screens.map { screen in
            let window = OverlayWindow(
                contentRect: screen.frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            window.backgroundColor = .clear
            window.isOpaque = false
            window.hasShadow = false
            window.level = .screenSaver
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
            window.contentView = AnnotationView(frame: screen.frame)
            window.orderOut(nil)
            return window
        }
    }

    private func createStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.title = "✎"
        item.button?.toolTip = "Screen Annotator"

        let menu = NSMenu()
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        menu.addItem(.separator())
        let quitItem = NSMenuItem(title: "Quit Screen Annotator", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        item.menu = menu
        statusItem = item
    }

    private func showOverlay() {
        createWindowsIfScreensChanged()
        NSApp.activate(ignoringOtherApps: true)

        for window in windows {
            window.makeKeyAndOrderFront(nil)
            window.contentView?.window?.makeFirstResponder(window.contentView)
        }
    }

    private func hideOverlay() {
        for window in windows {
            window.orderOut(nil)
        }
    }

    private func clearAndHideOverlay() {
        for window in windows {
            if let view = window.contentView as? AnnotationView {
                view.cancelCurrentGesture()
                view.clear()
            }
            window.orderOut(nil)
        }
    }

    private func createWindowsIfScreensChanged() {
        if windows.count != NSScreen.screens.count {
            createWindows()
        }
    }

    private func registerHotKey() {
        for action in HotKeyAction.allCases {
            let shortcut = ShortcutStore.shortcut(for: action)
            registerHotKey(keyCode: shortcut.key.carbonKeyCode, modifiers: shortcut.modifier.carbonValue, id: action.rawValue)
        }

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let selfPointer = Unmanaged.passUnretained(self).toOpaque()
        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, userData in
                guard let event, let userData else { return noErr }
                var hotKeyID = EventHotKeyID()
                let status = GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )
                guard status == noErr, hotKeyID.signature == hotKeySignature else {
                    return noErr
                }

                let delegate = Unmanaged<AppDelegate>.fromOpaque(userData).takeUnretainedValue()
                DispatchQueue.main.async {
                    switch hotKeyID.id {
                    case 1:
                        delegate.activateMode(.rectangle)
                    case 2:
                        delegate.activateMode(.arrow)
                    case 3:
                        delegate.activateMode(.step)
                    case 4:
                        delegate.activateMode(.brush)
                    case 5:
                        delegate.bumpStepNumber()
                    default:
                        break
                    }
                }
                return noErr
            },
            1,
            &eventType,
            selfPointer,
            &eventHandlerRef
        )
    }

    private func reloadHotKeys() {
        for hotKeyRef in hotKeyRefs {
            UnregisterEventHotKey(hotKeyRef)
        }
        hotKeyRefs.removeAll()
        for action in HotKeyAction.allCases {
            let shortcut = ShortcutStore.shortcut(for: action)
            registerHotKey(keyCode: shortcut.key.carbonKeyCode, modifiers: shortcut.modifier.carbonValue, id: action.rawValue)
        }
    }

    private func registerHotKey(keyCode: UInt32, modifiers: UInt32, id: UInt32) {
        var hotKeyRef: EventHotKeyRef?
        let hotKeyID = EventHotKeyID(signature: hotKeySignature, id: id)
        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        guard status == noErr, let hotKeyRef else {
            let alert = NSAlert()
            alert.messageText = "屏幕标注快捷键注册失败"
            alert.informativeText = "请确认 \(ShortcutStore.display(for: HotKeyAction(rawValue: id) ?? .rectangle)) 没有被其他应用占用。"
            alert.runModal()
            return
        }

        hotKeyRefs.append(hotKeyRef)
    }
}

private let app = NSApplication.shared
private let delegate = AppDelegate()
app.delegate = delegate
app.run()
