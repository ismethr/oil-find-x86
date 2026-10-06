// Composes the app icon and writes Resources/AppIcon.icns.
// The transparent mark (Resources/icon-src/oil-find-mark.png) is tinted to the accent colour and placed
// on a white tile that follows the macOS icon grid. The composed 1024 px master is saved next to it.
// Usage: swift scripts/make-icon.swift [preview.png]

import AppKit
import SwiftUI

let canvas = 1024
let body = CGRect(x: 100, y: 100, width: 824, height: 824)
let bodyRadius: CGFloat = 186
let markExtent: CGFloat = 700                 // longest side of the mark's visible pixels, in canvas units
let accent: (h: CGFloat, s: CGFloat, b: CGFloat) = (216.0 / 360.0, 0.81, 0.96)   // #2F7CF6

let sRGB = CGColorSpace(name: CGColorSpace.sRGB)!
func color(_ hex: UInt32, _ alpha: CGFloat = 1) -> CGColor {
    CGColor(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255, blue: CGFloat(hex & 0xFF) / 255, alpha: alpha)
}

let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
let markURL = root.appendingPathComponent("Resources/icon-src/oil-find-mark.png")
guard let source = CGImageSourceCreateWithURL(markURL as CFURL, nil),
      let rawMark = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
    print("cannot read \(markURL.path)")
    exit(1)
}

/// Re-tints every chromatic pixel of the mark to the accent hue and returns the image with the
/// bounding box of its visibly opaque pixels (top-left origin).
func prepare(_ image: CGImage) -> (CGImage, CGRect) {
    let width = image.width, height = image.height
    var px = [UInt8](repeating: 0, count: width * height * 4)
    let ctx = CGContext(data: &px, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
                        space: sRGB, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
    // The average coloured pixel defines the mark's own accent colour.
    var peakS: CGFloat = 0.2, peakB: CGFloat = 1, sumS: CGFloat = 0, sumB: CGFloat = 0, coloured: CGFloat = 0
    var hsb = [(CGFloat, CGFloat, CGFloat)](repeating: (0, 0, 0), count: width * height)
    for p in 0..<(width * height) {
        let i = p * 4, a = CGFloat(px[i + 3]) / 255
        guard a > 0.02 else { continue }
        let r = CGFloat(px[i]) / 255 / a, g = CGFloat(px[i + 1]) / 255 / a, b = CGFloat(px[i + 2]) / 255 / a
        let maxC = max(r, g, b), minC = min(r, g, b)
        let s = maxC == 0 ? 0 : (maxC - minC) / maxC
        // Chroma, not saturation, decides what counts as coloured: near-black ink has noisy saturation.
        hsb[p] = (maxC - minC, s, maxC)
        if a > 0.9 && maxC - minC > 0.2 { sumS += s; sumB += maxC; coloured += 1 }
    }
    if coloured > 0 { peakS = sumS / coloured; peakB = sumB / coloured }
    var minX = width, minY = height, maxX = -1, maxY = -1
    for p in 0..<(width * height) {
        let i = p * 4, alpha = px[i + 3]
        if alpha > 96 {
            let x = p % width, y = p / width
            minX = min(minX, x); maxX = max(maxX, x); minY = min(minY, y); maxY = max(maxY, y)
        }
        let (chroma, s, b) = hsb[p]
        guard alpha > 5, chroma > 0.10 else { continue }
        let tint = NSColor(hue: accent.h, saturation: min(1, s / peakS * accent.s), brightness: min(1, b / peakB * accent.b), alpha: 1).usingColorSpace(.sRGB)!
        let a = CGFloat(alpha) / 255
        px[i] = UInt8(tint.redComponent * a * 255); px[i + 1] = UInt8(tint.greenComponent * a * 255); px[i + 2] = UInt8(tint.blueComponent * a * 255)
    }
    let out = CGContext(data: &px, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
                        space: sRGB, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!.makeImage()!
    let bounds = maxX >= minX ? CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1) : CGRect(x: 0, y: 0, width: width, height: height)
    return (out, bounds)
}

let (mark, markBounds) = prepare(rawMark)

func draw(in ctx: CGContext) {
    let squircle = RoundedRectangle(cornerRadius: bodyRadius, style: .continuous).path(in: body).cgPath

    // Soft contact shadow under the tile.
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -12), blur: 34, color: color(0x1A1A1A, 0.22))
    ctx.addPath(squircle)
    ctx.setFillColor(color(0xFFFFFF))
    ctx.fillPath()
    ctx.restoreGState()

    // Tile: white, shading very slightly toward the bottom.
    ctx.saveGState()
    ctx.addPath(squircle)
    ctx.clip()
    let wash = CGGradient(colorsSpace: sRGB, colors: [color(0xFFFFFF), color(0xFFFFFF), color(0xF1F2F5)] as CFArray, locations: [0, 0.6, 1])!
    ctx.drawLinearGradient(wash, start: CGPoint(x: body.midX, y: body.maxY), end: CGPoint(x: body.midX, y: body.minY), options: [])
    ctx.restoreGState()

    // Hairline so the tile keeps its edge on white backgrounds.
    ctx.addPath(squircle)
    ctx.setStrokeColor(color(0x1A1A1A, 0.08))
    ctx.setLineWidth(2)
    ctx.strokePath()

    // Mark, scaled so its visible pixels span `markExtent` and sit centred in the tile.
    let scale = markExtent / max(markBounds.width, markBounds.height)
    let size = CGSize(width: CGFloat(mark.width) * scale, height: CGFloat(mark.height) * scale)
    let origin = CGPoint(x: body.midX - markBounds.midX * scale, y: body.midY - (CGFloat(mark.height) - markBounds.midY) * scale)
    ctx.saveGState()
    ctx.addPath(squircle)
    ctx.clip()
    ctx.interpolationQuality = .high
    ctx.draw(mark, in: CGRect(origin: origin, size: size))
    ctx.restoreGState()
}

func render(size: Int) -> Data {
    let ctx = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0, space: sRGB,
                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.interpolationQuality = .high
    ctx.scaleBy(x: CGFloat(size) / CGFloat(canvas), y: CGFloat(size) / CGFloat(canvas))
    draw(in: ctx)
    return NSBitmapImageRep(cgImage: ctx.makeImage()!).representation(using: .png, properties: [:])!
}

let fm = FileManager.default
if CommandLine.arguments.count > 1 {
    let out = URL(fileURLWithPath: CommandLine.arguments[1])
    try render(size: canvas).write(to: out)
    print("preview: \(out.path)")
    exit(0)
}

try render(size: canvas).write(to: root.appendingPathComponent("Resources/icon-src/oil-find-icon-1024.png"))
let iconset = fm.temporaryDirectory.appendingPathComponent("OilFind-\(UUID().uuidString).iconset")
try fm.createDirectory(at: iconset, withIntermediateDirectories: true)
defer { try? fm.removeItem(at: iconset) }
for base in [16, 32, 128, 256, 512] {
    try render(size: base).write(to: iconset.appendingPathComponent("icon_\(base)x\(base).png"))
    try render(size: base * 2).write(to: iconset.appendingPathComponent("icon_\(base)x\(base)@2x.png"))
}
let icns = root.appendingPathComponent("Resources/AppIcon.icns")
let task = Process()
task.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
task.arguments = ["-c", "icns", iconset.path, "-o", icns.path]
try task.run()
task.waitUntilExit()
guard task.terminationStatus == 0 else {
    print("iconutil failed")
    exit(1)
}
print("icon: \(icns.path)")
