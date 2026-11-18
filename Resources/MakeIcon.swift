// Renders the CornerClick app icon into an .iconset folder (used by build.sh).
// A graphite tile with a display centred on it and its top-left corner lit up.

import AppKit

let outDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon.iconset"

func grey(_ w: CGFloat, _ a: CGFloat = 1) -> CGColor { NSColor(white: w, alpha: a).cgColor }

func render(_ px: Int) -> Data {
    let s = CGFloat(px)
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8,
                               samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let ctx = NSGraphicsContext.current!.cgContext
    ctx.scaleBy(x: s / 1024, y: s / 1024)
    let space = CGColorSpaceCreateDeviceRGB()

    // Apple icon grid: 824pt body centred in a 1024 canvas.
    let body = CGRect(x: 100, y: 100, width: 824, height: 824)
    let squircle = CGPath(roundedRect: body, cornerWidth: 186, cornerHeight: 186, transform: nil)

    // Drop shadow
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 28, color: grey(0, 0.35))
    ctx.addPath(squircle); ctx.setFillColor(grey(0)); ctx.fillPath()
    ctx.restoreGState()

    // Graphite background
    ctx.saveGState()
    ctx.addPath(squircle); ctx.clip()
    let bg = CGGradient(colorsSpace: space, colors: [grey(0.40), grey(0.22), grey(0.11)] as CFArray,
                        locations: [0, 0.5, 1])!
    ctx.drawLinearGradient(bg, start: CGPoint(x: 512, y: 924), end: CGPoint(x: 512, y: 100),
                           options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])

    // Soft top sheen
    let sheen = CGGradient(colorsSpace: space, colors: [grey(1, 0.16), grey(1, 0)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(sheen, start: CGPoint(x: 512, y: 924), end: CGPoint(x: 512, y: 600), options: [])

    // Display, centred in the body
    let screen = CGRect(x: 512 - 298, y: 512 - 210, width: 596, height: 420)
    let screenPath = CGPath(roundedRect: screen, cornerWidth: 54, cornerHeight: 54, transform: nil)
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -12), blur: 30, color: grey(0, 0.4))
    ctx.addPath(screenPath)
    ctx.setFillColor(grey(0.06, 0.55))
    ctx.fillPath()
    ctx.restoreGState()

    // Lit corner (quarter disc in the top-left of the display)
    ctx.saveGState()
    ctx.addPath(CGPath(roundedRect: screen.insetBy(dx: 13, dy: 13), cornerWidth: 42, cornerHeight: 42, transform: nil))
    ctx.clip()
    let cornerCenter = CGPoint(x: screen.minX, y: screen.maxY)
    let glow = CGGradient(colorsSpace: space, colors: [grey(1, 0.98), grey(0.86, 0.9), grey(0.8, 0)] as CFArray,
                          locations: [0, 0.86, 1])!
    ctx.drawRadialGradient(glow, startCenter: cornerCenter, startRadius: 0, endCenter: cornerCenter, endRadius: 230, options: [])
    ctx.restoreGState()

    // Bezel
    ctx.addPath(screenPath)
    ctx.setStrokeColor(grey(0.94))
    ctx.setLineWidth(26)
    ctx.strokePath()

    ctx.restoreGState()

    // Subtle rim
    ctx.addPath(squircle)
    ctx.setStrokeColor(grey(1, 0.14))
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
