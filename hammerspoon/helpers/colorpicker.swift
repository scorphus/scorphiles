import AppKit

// Show the native macOS eyedropper loupe and print the picked color as hex.
let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let sampler = NSColorSampler()
sampler.show { picked in
    if let color = picked?.usingColorSpace(.sRGB) {
        let r = Int((color.redComponent   * 255).rounded())
        let g = Int((color.greenComponent * 255).rounded())
        let b = Int((color.blueComponent  * 255).rounded())
        print(String(format: "#%02X%02X%02X", r, g, b))
    }
    NSApp.terminate(nil)
}
app.run()
