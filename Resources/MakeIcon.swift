// Renders the CornerClick app icon into an .iconset folder (used by build.sh).
// A display with its top-left corner lit up and a pointer heading for it.

import AppKit

let outDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon.iconset"

func render(_ px: Int) -> Data {
    let s = CGFloat(px)
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8,
                               samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let ctx = NSGraphicsContext.current!.cgContext
    ctx.scaleBy(x: s / 1024, y: s / 1024)

    // Apple icon grid: 824pt body centred in a 1024 canvas.
    let body = CGRect(x: 100, y: 100, width: 824, height: 824)
    let squircle = CGPath(roundedRect: body, cornerWidth: 186, cornerHeight: 186, transform: nil)

    // Drop shadow
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 28, color: NSColor.black.withAlphaComponent(0.35).cgColor)
    ctx.addPath(squircle); ctx.setFillColor(NSColor.black.cgColor); ctx.fillPath()
    ctx.restoreGState()

    // Background gradient
    ctx.saveGState()
    ctx.addPath(squircle); ctx.clip()
    let bg = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [
        NSColor(red: 0.20, green: 0.42, blue: 0.98, alpha: 1).cgColor,
        NSColor(red: 0.36, green: 0.22, blue: 0.86, alpha: 1).cgColor,
        NSColor(red: 0.18, green: 0.10, blue: 0.48, alpha: 1).cgColor,
    ] as CFArray, locations: [0, 0.55, 1])!
    ctx.drawLinearGradient(bg, start: CGPoint(x: 300, y: 924), end: CGPoint(x: 724, y: 100), options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])

    // Soft top sheen
    let sheen = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [
        NSColor.white.withAlphaComponent(0.28).cgColor, NSColor.white.withAlphaComponent(0).cgColor,
    ] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(sheen, start: CGPoint(x: 512, y: 924), end: CGPoint(x: 512, y: 560), options: [])

    // Display
    let screen = CGRect(x: 214, y: 290, width: 596, height: 420)
    let screenPath = CGPath(roundedRect: screen, cornerWidth: 54, cornerHeight: 54, transform: nil)
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -12), blur: 30, color: NSColor.black.withAlphaComponent(0.35).cgColor)
    ctx.addPath(screenPath)
    ctx.setFillColor(NSColor.white.withAlphaComponent(0.16).cgColor)
    ctx.fillPath()
    ctx.restoreGState()
    ctx.addPath(screenPath)
    ctx.setStrokeColor(NSColor.white.withAlphaComponent(0.92).cgColor)
    ctx.setLineWidth(26)
    ctx.strokePath()

    // Lit corner (quarter disc in the top-left of the display)
    ctx.saveGState()
    ctx.addPath(CGPath(roundedRect: screen.insetBy(dx: 13, dy: 13), cornerWidth: 42, cornerHeight: 42, transform: nil))
    ctx.clip()
    let cornerCenter = CGPoint(x: screen.minX, y: screen.maxY)
    let glow = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [
        NSColor(red: 1.0, green: 0.93, blue: 0.55, alpha: 1).cgColor,
        NSColor(red: 1.0, green: 0.62, blue: 0.22, alpha: 1).cgColor,
        NSColor(red: 1.0, green: 0.55, blue: 0.20, alpha: 0).cgColor,
    ] as CFArray, locations: [0, 0.62, 1])!
    ctx.drawRadialGradient(glow, startCenter: cornerCenter, startRadius: 0, endCenter: cornerCenter, endRadius: 250, options: [])
    ctx.restoreGState()

    // Pointer heading into the corner
    ctx.saveGState()
    ctx.translateBy(x: 505, y: 455)
    ctx.rotate(by: .pi / 4.2)
    let arrow = CGMutablePath()
    let a: [CGPoint] = [(0, 170), (-104, -60), (-34, -40), (-62, -150), (-14, -164), (14, -54), (86, -60)]
        .map { CGPoint(x: $0.0 * 0.95, y: $0.1 * 0.95) }
    arrow.addLines(between: a); arrow.closeSubpath()
    ctx.rotate(by: 0.5 - .pi / 4.2)
    ctx.setShadow(offset: CGSize(width: 0, height: -8), blur: 18, color: NSColor.black.withAlphaComponent(0.45).cgColor)
    ctx.addPath(arrow)
    ctx.setFillColor(NSColor.white.cgColor)
    ctx.fillPath()
    ctx.setShadow(offset: .zero, blur: 0, color: nil)
    ctx.addPath(arrow)
    ctx.setStrokeColor(NSColor(red: 0.10, green: 0.08, blue: 0.25, alpha: 1).cgColor)
    ctx.setLineWidth(14)
    ctx.setLineJoin(.round)
    ctx.strokePath()
    ctx.restoreGState()

    ctx.restoreGState()

    // Subtle rim
    ctx.addPath(squircle)
    ctx.setStrokeColor(NSColor.white.withAlphaComponent(0.18).cgColor)
    ctx.setLineWidth(4)
    ctx.strokePath()

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)
for base in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let name = scale == 1 ? "icon_\(base)x\(base).png" : "icon_\(base)x\(base)@2x.png"
        try! render(base * scale).write(to: URL(fileURLWithPath: outDir).appendingPathComponent(name))
    }
}
