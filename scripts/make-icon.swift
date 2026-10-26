// Gera Resources/AppIcon.icns desenhando o ícone com CoreGraphics.
// Uso: swiftc scripts/make-icon.swift -o /tmp/make-icon && /tmp/make-icon
import AppKit

let size: CGFloat = 1024
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size), pixelsHigh: Int(size), bitsPerSample: 8,
                           samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
let ctx = NSGraphicsContext.current!.cgContext
let cs = CGColorSpaceCreateDeviceRGB()
func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor { CGColor(red: r/255, green: g/255, blue: b/255, alpha: a) }

// Fundo: squircle do macOS (margem ~10%) com gradiente azul → turquesa
let inset: CGFloat = 100
let body = CGRect(x: inset, y: inset, width: size - 2*inset, height: size - 2*inset)
let squircle = CGPath(roundedRect: body, cornerWidth: 185, cornerHeight: 185, transform: nil)
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -14), blur: 28, color: color(0, 0, 0, 0.35))
ctx.addPath(squircle); ctx.setFillColor(color(20, 60, 160)); ctx.fillPath()
ctx.restoreGState()
ctx.saveGState()
ctx.addPath(squircle); ctx.clip()
let grad = CGGradient(colorsSpace: cs, colors: [color(36, 99, 235), color(20, 184, 166)] as CFArray, locations: [0, 1])!
ctx.drawLinearGradient(grad, start: CGPoint(x: body.minX, y: body.maxY), end: CGPoint(x: body.maxX, y: body.minY), options: [])
ctx.restoreGState()

// Disco (prato): círculo branco com anéis e furo central
let c = CGPoint(x: size/2, y: size/2 - 10)
let R: CGFloat = 290
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 22, color: color(0, 30, 80, 0.45))
ctx.setFillColor(color(255, 255, 255)); ctx.fillEllipse(in: CGRect(x: c.x-R, y: c.y-R, width: 2*R, height: 2*R))
ctx.restoreGState()
for (r, a) in [(240.0, 0.18), (190.0, 0.14), (140.0, 0.10)] as [(CGFloat, CGFloat)] {
    ctx.setStrokeColor(color(30, 80, 170, a)); ctx.setLineWidth(8)
    ctx.strokeEllipse(in: CGRect(x: c.x-r, y: c.y-r, width: 2*r, height: 2*r))
}
// Setor "limpo": fatia turquesa mostrando o espaço liberado
ctx.saveGState()
ctx.move(to: c); ctx.addArc(center: c, radius: R, startAngle: .pi * 0.08, endAngle: .pi * 0.62, clockwise: false); ctx.closePath()
ctx.clip()
let g2 = CGGradient(colorsSpace: cs, colors: [color(94, 234, 212), color(20, 184, 166)] as CFArray, locations: [0, 1])!
ctx.drawLinearGradient(g2, start: CGPoint(x: c.x, y: c.y + R), end: CGPoint(x: c.x + R, y: c.y - R*0.2), options: [])
ctx.restoreGState()
// Furo central
ctx.setFillColor(color(30, 80, 170)); ctx.fillEllipse(in: CGRect(x: c.x-48, y: c.y-48, width: 96, height: 96))
ctx.setFillColor(color(255, 255, 255)); ctx.fillEllipse(in: CGRect(x: c.x-18, y: c.y-18, width: 36, height: 36))

// Brilho (faísca) no canto superior direito
func sparkle(_ p: CGPoint, _ r: CGFloat) {
    let path = CGMutablePath()
    path.move(to: CGPoint(x: p.x, y: p.y + r))
    path.addQuadCurve(to: CGPoint(x: p.x + r, y: p.y), control: CGPoint(x: p.x + r*0.12, y: p.y + r*0.12))
    path.addQuadCurve(to: CGPoint(x: p.x, y: p.y - r), control: CGPoint(x: p.x + r*0.12, y: p.y - r*0.12))
    path.addQuadCurve(to: CGPoint(x: p.x - r, y: p.y), control: CGPoint(x: p.x - r*0.12, y: p.y - r*0.12))
    path.addQuadCurve(to: CGPoint(x: p.x, y: p.y + r), control: CGPoint(x: p.x - r*0.12, y: p.y + r*0.12))
    ctx.saveGState(); ctx.setShadow(offset: .zero, blur: 16, color: color(255, 255, 255, 0.8))
    ctx.addPath(path); ctx.setFillColor(color(255, 255, 255)); ctx.fillPath(); ctx.restoreGState()
}
sparkle(CGPoint(x: 735, y: 735), 105)
sparkle(CGPoint(x: 820, y: 600), 45)
NSGraphicsContext.restoreGraphicsState()

let fm = FileManager.default
let tmp = NSTemporaryDirectory() + "AppIcon.iconset"
try? fm.removeItem(atPath: tmp); try! fm.createDirectory(atPath: tmp, withIntermediateDirectories: true)
let master = rep.representation(using: .png, properties: [:])!
try! master.write(to: URL(fileURLWithPath: "Resources/AppIcon-1024.png"))
let sizes: [(Int, String)] = [(16,"16x16"),(32,"16x16@2x"),(32,"32x32"),(64,"32x32@2x"),(128,"128x128"),(256,"128x128@2x"),
                              (256,"256x256"),(512,"256x256@2x"),(512,"512x512"),(1024,"512x512@2x")]
for (px, name) in sizes {
    let out = "\(tmp)/icon_\(name).png"
    let p = Process(); p.executableURL = URL(fileURLWithPath: "/usr/bin/sips")
    p.arguments = ["-z", "\(px)", "\(px)", "Resources/AppIcon-1024.png", "--out", out]
    p.standardOutput = FileHandle.nullDevice; try! p.run(); p.waitUntilExit()
}
let ic = Process(); ic.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
ic.arguments = ["-c", "icns", tmp, "-o", "Resources/AppIcon.icns"]; try! ic.run(); ic.waitUntilExit()
print("OK: Resources/AppIcon.icns")
