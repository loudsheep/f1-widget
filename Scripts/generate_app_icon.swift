#!/usr/bin/env swift
// Usage: swift Scripts/generate_app_icon.swift
// Draws the app icon and writes every size into the AppIcon asset set.

import AppKit

let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
let circuitURL = root.appending(path: "Packages/F1Core/Sources/F1Core/Resources/CircuitMaps/suzuka.svg")
let outputDirectory = root.appending(path: "F1Widget/Assets.xcassets/AppIcon.appiconset")

let canvas: CGFloat = 1024
let inset: CGFloat = 100
let shape = NSRect(x: inset, y: inset, width: canvas - 2 * inset, height: canvas - 2 * inset)
let red = NSColor(srgbRed: 0.88, green: 0.02, blue: 0, alpha: 1)

func whiteCircuit() -> NSImage {
    let svg = try! String(contentsOf: circuitURL, encoding: .utf8)
        .replacingOccurrences(of: "stroke-width=\"2.4\"", with: "stroke-width=\"3.2\"")
    let image = NSImage(data: Data(svg.utf8))!
    let tinted = NSImage(size: image.size)
    tinted.lockFocus()
    image.draw(in: NSRect(origin: .zero, size: image.size))
    NSColor.white.set()
    NSRect(origin: .zero, size: image.size).fill(using: .sourceAtop)
    tinted.unlockFocus()
    return tinted
}

func renderMaster() -> NSBitmapImageRep {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: Int(canvas), pixelsHigh: Int(canvas),
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
    )!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    let path = NSBezierPath(roundedRect: shape, xRadius: 185, yRadius: 185)
    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.35)
    shadow.shadowOffset = NSSize(width: 0, height: -12)
    shadow.shadowBlurRadius = 24
    shadow.set()
    NSColor.black.setFill()
    path.fill()
    NSGraphicsContext.restoreGraphicsState()

    NSGraphicsContext.saveGraphicsState()
    path.addClip()
    NSColor.black.setFill()
    shape.fill()
    NSGradient(colors: [red.withAlphaComponent(0.9), .clear])!
        .draw(fromCenter: NSPoint(x: shape.minX + 120, y: shape.maxY - 120), radius: 0,
              toCenter: NSPoint(x: shape.minX + 120, y: shape.maxY - 120), radius: 640, options: [])
    NSGradient(colors: [red.withAlphaComponent(0.55), .clear])!
        .draw(fromCenter: NSPoint(x: shape.maxX - 100, y: shape.minY + 100), radius: 0,
              toCenter: NSPoint(x: shape.maxX - 100, y: shape.minY + 100), radius: 520, options: [])

    let circuit = whiteCircuit()
    let box: CGFloat = 600
    let scale = min(box / circuit.size.width, box / circuit.size.height)
    let size = NSSize(width: circuit.size.width * scale, height: circuit.size.height * scale)
    circuit.draw(in: NSRect(x: canvas / 2 - size.width / 2, y: canvas / 2 - size.height / 2,
                            width: size.width, height: size.height))
    NSGraphicsContext.restoreGraphicsState()

    NSColor.white.withAlphaComponent(0.14).setStroke()
    let border = NSBezierPath(roundedRect: shape.insetBy(dx: 1, dy: 1), xRadius: 184, yRadius: 184)
    border.lineWidth = 2
    border.stroke()

    NSGraphicsContext.restoreGraphicsState()
    return rep
}

func resized(_ master: NSBitmapImageRep, to pixels: Int) -> Data {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
    )!
    NSGraphicsContext.saveGraphicsState()
    let context = NSGraphicsContext(bitmapImageRep: rep)!
    context.imageInterpolation = .high
    NSGraphicsContext.current = context
    NSImage(size: NSSize(width: canvas, height: canvas), flipped: false) { _ in
        master.draw(in: NSRect(x: 0, y: 0, width: canvas, height: canvas))
        return true
    }.draw(in: NSRect(x: 0, y: 0, width: pixels, height: pixels))
    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

let master = renderMaster()
let points = [16, 32, 128, 256, 512]
var images: [[String: String]] = []

for point in points {
    for scale in [1, 2] {
        let name = "icon_\(point)x\(point)@\(scale)x.png"
        try! resized(master, to: point * scale).write(to: outputDirectory.appending(path: name))
        images.append(["filename": name, "idiom": "mac", "scale": "\(scale)x", "size": "\(point)x\(point)"])
    }
}

let contents: [String: Any] = ["images": images, "info": ["author": "xcode", "version": 1]]
let json = try! JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
try! json.write(to: outputDirectory.appending(path: "Contents.json"))
print("Wrote \(images.count) icons")
