import Foundation
import AppKit
import Vision

// Load metadata
let metaData = try! Data(contentsOf: URL(fileURLWithPath: "pokemon_metadata.json"))
let metadataList = try! JSONSerialization.jsonObject(with: metaData) as! [[String: Any]]

let fileManager = FileManager.default
let conceptsDir = URL(fileURLWithPath: "vectors/concepts")
let creaturesDir = URL(fileURLWithPath: "vectors/creatures")
let cardsDir = URL(fileURLWithPath: "vectors/cards")

try? fileManager.createDirectory(at: conceptsDir, withIntermediateDirectories: true)
try? fileManager.createDirectory(at: creaturesDir, withIntermediateDirectories: true)
try? fileManager.createDirectory(at: cardsDir, withIntermediateDirectories: true)

// Type color mapping
let typeColors: [String: (primary: String, light: String, accent: String)] = [
    "Fairy": ("#EC407A", "#FCE4EC", "#880E4F"),
    "Water": ("#29B6F6", "#E1F5FE", "#01579B"),
    "Bug": ("#9CCC65", "#F1F8E9", "#33691E"),
    "Electric": ("#FFEE58", "#FFFDE7", "#F57F17"),
    "Fire": ("#FF7043", "#FBE9E7", "#BF360C"),
    "Normal": ("#BDBDBD", "#F5F5F5", "#424242"),
    "Fighting": ("#EF5350", "#FFEBEE", "#B71C1C"),
    "Poison": ("#AB47BC", "#F3E5F5", "#4A148C"),
    "Ice": ("#4DD0E1", "#E0F7FA", "#006064"),
    "Steel": ("#90A4AE", "#ECEFF1", "#263238"),
    "Ghost": ("#7E57C2", "#EDE7F6", "#311B92"),
    "Grass": ("#66BB6A", "#E8F5E9", "#1B5E20"),
    "Dragon": ("#5C6BC0", "#E8EAF6", "#1A237E"),
    "Rock": ("#BCAAA4", "#EFEBE9", "#3E2723"),
    "Ground": ("#D4E157", "#F9FBE7", "#827717"),
    "Flying": ("#4FC3F7", "#E1F5FE", "#0277BD"),
    "Psychic": ("#F06292", "#FCE4EC", "#880E4F"),
    "Dark": ("#78909C", "#ECEFF1", "#263238")
]

func potrace(inputPbm: String, outputSvg: String, turdsize: Int = 10) {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/Users/mabino/.homebrew/bin/potrace")
    task.arguments = ["-s", "-o", outputSvg, "--turdsize", "\(turdsize)", inputPbm]
    try? task.run()
    task.waitUntilExit()
}

print("Starting enhanced vector generation for 42 Pokémon concepts...")

for entry in metadataList {
    let id = entry["id"] as! Int
    let name = entry["name"] as! String
    let primaryType = entry["primary_type"] as! String
    let secondaryType = entry["secondary_type"] as? String
    let ev1 = entry["ev1"] as? String
    let ev2 = entry["ev2"] as? String
    let notes = entry["notes"] as? String ?? ""
    
    let safeName = name.lowercased().replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: ".", with: "")
    let idStr = String(format: "%02d", id)
    let pagePng = String(format: "pdf_preview/page_%02d.png", id)
    
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: pagePng)),
          let rep = NSBitmapImageRep(data: data) else {
        print("Failed to load \(pagePng)")
        continue
    }
    
    let width = rep.pixelsWide
    let height = rep.pixelsHigh
    guard let cgImage = rep.cgImage else { continue }
    
    // OCR for text detection
    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    try? handler.perform([request])
    
    // Grayscale buffer
    var pixels = [[UInt8]](repeating: [UInt8](repeating: 255, count: width), count: height)
    for y in 0..<height {
        for x in 0..<width {
            if let c = rep.colorAt(x: x, y: y)?.usingColorSpace(.deviceRGB) {
                let gray = Double(c.redComponent) * 0.299 + Double(c.greenComponent) * 0.587 + Double(c.blueComponent) * 0.114
                pixels[y][x] = UInt8(gray * 255.0)
            }
        }
    }
    
    // Detect paper bounds (where scanner background ends)
    var topPaperY = 0
    let startX = Int(Double(width) * 0.15)
    let endX = Int(Double(width) * 0.85)
    let checkW = endX - startX
    for y in 0..<height/3 {
        var whiteCount = 0
        for x in startX..<endX {
            if pixels[y][x] > 200 { whiteCount += 1 }
        }
        if Double(whiteCount) / Double(checkW) > 0.70 {
            topPaperY = y
            break
        }
    }
    
    // Mask top scanner background
    if topPaperY > 0 {
        let wipeTop = min(height - 1, topPaperY + 15)
        for y in 0...wipeTop {
            for x in 0..<width { pixels[y][x] = 255 }
        }
    }
    
    // Outer border margin
    let mX = Int(Double(width) * 0.035)
    let mY = Int(Double(height) * 0.025)
    for y in 0..<height {
        for x in 0..<width {
            if x < mX || x >= width - mX || y < mY || y >= height - mY {
                pixels[y][x] = 255
            }
        }
    }
    
    // Mask spiral holes if applicable
    if id == 24 || id == 25 || id == 26 || id == 27 || id == 32 || id == 33 {
        let spiralH = Int(Double(height) * 0.09)
        for y in 0..<spiralH {
            for x in 0..<width { pixels[y][x] = 255 }
        }
    }
    
    // Mask Ocean Beach header & footer
    for obs in request.results ?? [] {
        let text = obs.topCandidates(1).first?.string ?? ""
        let b = obs.boundingBox
        let topY = Int((1.0 - (b.origin.y + b.size.height)) * CGFloat(height))
        let botY = Int((1.0 - b.origin.y) * CGFloat(height))
        let l = text.lowercased()
        
        // Header (in top 35%)
        if topY < Int(Double(height) * 0.35) {
            if l.contains("ocean beach") || l.contains("rentals") || l.contains("sales") {
                let wipeTo = min(height - 1, botY + 45)
                for y in 0...wipeTo {
                    for x in 0..<width { pixels[y][x] = 255 }
                }
            }
        }
        
        // Footer (in bottom 35%)
        if botY > Int(Double(height) * 0.65) {
            if l.contains("sales office") || l.contains("rental office") || l.contains("oceanbeachnj") || l.contains("3170 route") || l.contains("facebook") || l.contains("jersey") {
                let wipeFrom = max(0, topY - 20)
                for y in wipeFrom..<height {
                    for x in 0..<width { pixels[y][x] = 255 }
                }
            }
        }
    }
    
    // Border flood fill to clear any edge smudges or torn paper shadows
    var visited = [[Bool]](repeating: [Bool](repeating: false, count: width), count: height)
    var queue: [(Int, Int)] = []
    for y in 0..<height {
        queue.append((0, y)); queue.append((width - 1, y))
        visited[y][0] = true; visited[y][width - 1] = true
    }
    for x in 0..<width {
        queue.append((x, 0)); queue.append((x, height - 1))
        visited[0][x] = true; visited[height - 1][x] = true
    }
    let marginX = Int(Double(width) * 0.07)
    let marginY = Int(Double(height) * 0.07)
    var qHead = 0
    while qHead < queue.count {
        let (cx, cy) = queue[qHead]
        qHead += 1
        pixels[cy][cx] = 255
        let neighbors = [(cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)]
        for (nx, ny) in neighbors {
            guard nx >= 0, nx < width, ny >= 0, ny < height else { continue }
            if !visited[ny][nx] {
                let isDark = pixels[ny][nx] < 165
                let inMargin = (nx < marginX || nx >= width - marginX || ny < marginY || ny >= height - marginY)
                if isDark && inMargin {
                    visited[ny][nx] = true
                    queue.append((nx, ny))
                }
            }
        }
    }
    
    // Save Concept PBM & run potrace
    let bytesPerRow = (width + 7) / 8
    var pbmConcept = "P4\n\(width) \(height)\n".data(using: .ascii)!
    var pbmConceptBytes = [UInt8](repeating: 0, count: bytesPerRow * height)
    for y in 0..<height {
        for x in 0..<width {
            if pixels[y][x] < 190 {
                let bIdx = y * bytesPerRow + (x / 8)
                let bitIdx = 7 - (x % 8)
                pbmConceptBytes[bIdx] |= (1 << bitIdx)
            }
        }
    }
    pbmConcept.append(contentsOf: pbmConceptBytes)
    
    let tempConceptPbm = "/tmp/concept_\(idStr).pbm"
    let conceptSvgPath = "vectors/concepts/\(idStr)_\(safeName).svg"
    try? pbmConcept.write(to: URL(fileURLWithPath: tempConceptPbm))
    potrace(inputPbm: tempConceptPbm, outputSvg: conceptSvgPath, turdsize: 12)
    try? fileManager.removeItem(atPath: tempConceptPbm)
    
    // -------------------------------------------------------------
    // Advanced Creature Isolation using Downsampled Morphology
    // -------------------------------------------------------------
    let dw = width / 4
    let dh = height / 4
    var down = [[Bool]](repeating: [Bool](repeating: false, count: dw), count: dh)
    for dy in 0..<dh {
        for dx in 0..<dw {
            if pixels[dy * 4][dx * 4] < 190 {
                down[dy][dx] = true
            }
        }
    }
    
    // Clear OCR text regions in downsampled map
    for obs in request.results ?? [] {
        let b = obs.boundingBox
        let topY = max(0, Int((1.0 - (b.origin.y + b.size.height) - 0.015) * CGFloat(height)) / 4)
        let botY = min(dh - 1, Int((1.0 - b.origin.y + 0.015) * CGFloat(height)) / 4)
        let leftX = max(0, Int((b.origin.x - 0.015) * CGFloat(width)) / 4)
        let rightX = min(dw - 1, Int((b.origin.x + b.size.width + 0.015) * CGFloat(width)) / 4)
        for y in topY...botY {
            for x in leftX...rightX { down[y][x] = false }
        }
    }
    
    // Clear margins in downsampled
    for dy in 0..<dh {
        for dx in 0..<dw {
            if dy < Int(Double(dh) * 0.08) || dy > Int(Double(dh) * 0.90) || dx < Int(Double(dw) * 0.06) || dx > Int(Double(dw) * 0.94) {
                down[dy][dx] = false
            }
        }
    }
    
    // Morphological dilation (r=3) to merge creature strokes
    var dilated = down
    for dy in 2..<dh-2 {
        for dx in 2..<dw-2 {
            if down[dy][dx] {
                for ny in (dy-2)...(dy+2) {
                    for nx in (dx-2)...(dx+2) {
                        dilated[ny][nx] = true
                    }
                }
            }
        }
    }
    
    // Connected components on dilated map
    var compVisited = [[Bool]](repeating: [Bool](repeating: false, count: dw), count: dh)
    struct DComp {
        var count = 0
        var minX = 9999, maxX = 0, minY = 9999, maxY = 0
    }
    var comps: [DComp] = []
    
    for dy in 0..<dh {
        for dx in 0..<dw {
            if dilated[dy][dx] && !compVisited[dy][dx] {
                var c = DComp()
                var q = [(dx, dy)]
                compVisited[dy][dx] = true
                var qH = 0
                while qH < q.count {
                    let (cx, cy) = q[qH]
                    qH += 1
                    c.count += 1
                    c.minX = min(c.minX, cx); c.maxX = max(c.maxX, cx)
                    c.minY = min(c.minY, cy); c.maxY = max(c.maxY, cy)
                    let nbs = [(cx+1, cy), (cx-1, cy), (cx, cy+1), (cx, cy-1)]
                    for (nx, ny) in nbs {
                        guard nx >= 0, nx < dw, ny >= 0, ny < dh else { continue }
                        if dilated[ny][nx] && !compVisited[ny][nx] {
                            compVisited[ny][nx] = true
                            q.append((nx, ny))
                        }
                    }
                }
                comps.append(c)
            }
        }
    }
    
    var creatureSvgContent = ""
    var creatureViewBox = "0 0 100 100"
    let creatureSvgPath = "vectors/creatures/\(idStr)_\(safeName)_creature.svg"
    
    if let bestComp = comps.sorted(by: { $0.count > $1.count }).first, bestComp.count > 10 {
        let pad = 35
        let minX = max(0, bestComp.minX * 4 - pad)
        let maxX = min(width - 1, bestComp.maxX * 4 + pad)
        let minY = max(0, bestComp.minY * 4 - pad)
        let maxY = min(height - 1, bestComp.maxY * 4 + pad)
        
        let cW = maxX - minX + 1
        let cH = maxY - minY + 1
        let cBytesPerRow = (cW + 7) / 8
        var pbmCreature = "P4\n\(cW) \(cH)\n".data(using: .ascii)!
        var pbmCreatureBytes = [UInt8](repeating: 0, count: cBytesPerRow * cH)
        
        // Also mask text from creature pixels
        var cPixels = pixels
        for obs in request.results ?? [] {
            let b = obs.boundingBox
            let topY = max(0, Int((1.0 - (b.origin.y + b.size.height) - 0.015) * CGFloat(height)))
            let botY = min(height - 1, Int((1.0 - b.origin.y + 0.015) * CGFloat(height)))
            let leftX = max(0, Int((b.origin.x - 0.015) * CGFloat(width)))
            let rightX = min(width - 1, Int((b.origin.x + b.size.width + 0.015) * CGFloat(width)))
            for y in topY...botY {
                for x in leftX...rightX { cPixels[y][x] = 255 }
            }
        }
        
        for y in 0..<cH {
            let sy = minY + y
            for x in 0..<cW {
                let sx = minX + x
                if cPixels[sy][sx] < 190 {
                    let bIdx = y * cBytesPerRow + (x / 8)
                    let bitIdx = 7 - (x % 8)
                    pbmCreatureBytes[bIdx] |= (1 << bitIdx)
                }
            }
        }
        pbmCreature.append(contentsOf: pbmCreatureBytes)
        let tempCreaturePbm = "/tmp/creature_\(idStr).pbm"
        try? pbmCreature.write(to: URL(fileURLWithPath: tempCreaturePbm))
        potrace(inputPbm: tempCreaturePbm, outputSvg: creatureSvgPath, turdsize: 10)
        try? fileManager.removeItem(atPath: tempCreaturePbm)
        
        if let rawSvg = try? String(contentsOf: URL(fileURLWithPath: creatureSvgPath), encoding: .utf8) {
            if let vbMatch = rawSvg.range(of: "viewBox=\"([^\"]+)\"", options: .regularExpression) {
                let fullMatch = String(rawSvg[vbMatch])
                creatureViewBox = fullMatch.replacingOccurrences(of: "viewBox=\"", with: "").replacingOccurrences(of: "\"", with: "")
            }
            if let gStart = rawSvg.range(of: "<g "), let gEnd = rawSvg.range(of: "</svg>") {
                creatureSvgContent = String(rawSvg[gStart.lowerBound..<gEnd.lowerBound])
            }
        }
    } else {
        try? fileManager.copyItem(atPath: conceptSvgPath, toPath: creatureSvgPath)
    }
    
    // -------------------------------------------------------------
    // Pokémon Trading Card SVG Generation
    // -------------------------------------------------------------
    let colors = typeColors[primaryType] ?? ("#9E9E9E", "#F5F5F5", "#424242")
    let secColor = secondaryType != nil ? (typeColors[secondaryType!]?.primary ?? "#78909C") : nil
    
    let stageText = "Basic Pokémon"
    var evolvesTo = ""
    if let e1 = ev1, !e1.isEmpty {
        evolvesTo = "Evolves into: \(e1)"
        if let e2 = ev2, !e2.isEmpty {
            evolvesTo += " → \(e2)"
        }
    } else {
        evolvesTo = "Single Stage Pokémon"
    }
    
    let hp = 60 + (id % 7) * 10
    
    let cardSvg = """
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 850" width="600" height="850">
      <defs>
        <linearGradient id="cardBg" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stop-color="\(colors.light)" />
          <stop offset="50%" stop-color="#FFFFFF" />
          <stop offset="100%" stop-color="\(colors.light)" />
        </linearGradient>
        <linearGradient id="foilBorder" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stop-color="\(colors.accent)" />
          <stop offset="30%" stop-color="\(colors.primary)" />
          <stop offset="70%" stop-color="#FFD700" />
          <stop offset="100%" stop-color="\(colors.primary)" />
        </linearGradient>
        <linearGradient id="bannerGrad" x1="0%" y1="0%" x2="100%" y2="0%">
          <stop offset="0%" stop-color="\(colors.primary)" />
          <stop offset="100%" stop-color="\(colors.accent)" />
        </linearGradient>
        <filter id="cardShadow" x="-5%" y="-5%" width="110%" height="110%">
          <feDropShadow dx="0" dy="8" stdDeviation="12" flood-opacity="0.25" flood-color="#000000" />
        </filter>
        <filter id="artShadow" x="-5%" y="-5%" width="110%" height="110%">
          <feDropShadow dx="0" dy="2" stdDeviation="4" flood-opacity="0.15" />
        </filter>
      </defs>

      <!-- Card Base -->
      <rect x="15" y="15" width="570" height="820" rx="28" fill="url(#foilBorder)" filter="url(#cardShadow)" />
      <rect x="25" y="25" width="550" height="800" rx="22" fill="url(#cardBg)" />
      <rect x="32" y="32" width="536" height="786" rx="18" fill="none" stroke="\(colors.primary)" stroke-width="2" opacity="0.4" />

      <!-- Top Header Bar -->
      <g transform="translate(45, 45)">
        <text x="0" y="22" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif" font-size="12" font-weight="700" fill="\(colors.accent)" letter-spacing="1">\(stageText.uppercased())</text>
        <text x="0" y="52" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif" font-size="28" font-weight="900" fill="#212121">\(name)</text>
        
        <!-- HP -->
        <text x="440" y="48" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif" font-size="14" font-weight="800" fill="\(colors.accent)">HP</text>
        <text x="465" y="50" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif" font-size="24" font-weight="900" fill="#212121">\(hp)</text>
      </g>

      <!-- Type Badges -->
      <g transform="translate(45, 105)">
        <rect x="0" y="0" width="\(secondaryType != nil ? 80 : 95)" height="24" rx="12" fill="\(colors.primary)" />
        <text x="\(secondaryType != nil ? 40 : 47.5)" y="16" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="11" font-weight="800" fill="#FFFFFF" text-anchor="middle">\(primaryType.uppercased())</text>
        
        \(secondaryType != nil ? """
        <rect x="90" y="0" width="80" height="24" rx="12" fill="\(secColor!)" />
        <text x="130" y="16" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="11" font-weight="800" fill="#FFFFFF" text-anchor="middle">\(secondaryType!.uppercased())</text>
        """ : "")
        
        <text x="510" y="16" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="12" font-weight="700" fill="#757575" text-anchor="end">NO. \(idStr) / 42</text>
      </g>

      <!-- Illustration Frame -->
      <g transform="translate(45, 140)">
        <rect x="0" y="0" width="510" height="340" rx="16" fill="#FFFFFF" stroke="\(colors.accent)" stroke-width="3" filter="url(#artShadow)" />
        <rect x="6" y="6" width="498" height="328" rx="12" fill="\(colors.light)" opacity="0.3" />
        <circle cx="255" cy="170" r="130" fill="\(colors.light)" opacity="0.5" />
        
        <!-- Embedded Traced Creature SVG -->
        <svg x="20" y="15" width="470" height="310" viewBox="\(creatureViewBox)" preserveAspectRatio="xMidYMid meet">
          \(creatureSvgContent)
        </svg>
      </g>

      <!-- Evolution Banner -->
      <g transform="translate(45, 495)">
        <rect x="0" y="0" width="510" height="28" rx="6" fill="#F0F0F0" />
        <text x="15" y="18" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="11" font-weight="700" fill="#616161">\(evolvesTo)</text>
      </g>

      <!-- Moves & Concept Abilities -->
      <g transform="translate(45, 540)">
        <!-- Concept Attack 1 -->
        <circle cx="16" cy="16" r="14" fill="\(colors.primary)" />
        <circle cx="16" cy="16" r="6" fill="#FFFFFF" />
        <text x="40" y="21" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="18" font-weight="800" fill="#212121">Original Concept</text>
        <text x="510" y="21" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="18" font-weight="800" fill="#212121" text-anchor="end">40+</text>
        <text x="40" y="42" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="12" font-weight="500" fill="#616161">Hand-drawn authentic archive concept. Traced as scalable vector.</text>
        
        <line x1="0" y1="58" x2="510" y2="58" stroke="#E0E0E0" stroke-width="1" />

        <!-- Move 2 -->
        <circle cx="16" cy="85" r="14" fill="\(colors.primary)" />
        <circle cx="48" cy="85" r="14" fill="\(secColor ?? colors.accent)" />
        <text x="75" y="90" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="18" font-weight="800" fill="#212121">\(name) Surge</text>
        <text x="510" y="90" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="18" font-weight="800" fill="#212121" text-anchor="end">80</text>
        <text x="75" y="110" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="12" font-style="italic" fill="#616161">\(notes.isEmpty ? "A rare concept monster from the original sketchbook archive." : notes)</text>
      </g>

      <!-- Bottom Stats / Footer -->
      <g transform="translate(45, 720)">
        <line x1="0" y1="0" x2="510" y2="0" stroke="\(colors.primary)" stroke-width="2" opacity="0.3" />
        
        <text x="30" y="22" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="10" font-weight="700" fill="#757575">WEAKNESS</text>
        <text x="210" y="22" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="10" font-weight="700" fill="#757575">RESISTANCE</text>
        <text x="400" y="22" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="10" font-weight="700" fill="#757575">RETREAT</text>

        <circle cx="30" cy="40" r="10" fill="#EF5350" />
        <text x="46" y="44" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="12" font-weight="800" fill="#212121">×2</text>

        <circle cx="210" cy="40" r="10" fill="#78909C" />
        <text x="226" y="44" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="12" font-weight="800" fill="#212121">-20</text>

        <circle cx="400" cy="40" r="10" fill="#BDBDBD" />
        <circle cx="425" cy="40" r="10" fill="#BDBDBD" />

        <text x="255" y="78" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="10" font-weight="700" fill="#9E9E9E" text-anchor="middle">© Pocket Monster Concepts Archive • Vector Edition 2026</text>
      </g>
    </svg>
    """
    
    let cardSvgPath = "vectors/cards/\(idStr)_\(safeName)_card.svg"
    try? cardSvg.write(to: URL(fileURLWithPath: cardSvgPath), atomically: true, encoding: .utf8)
    
    print("[\(idStr)/42] Refined vector set for: \(name)")
}

print("All 42 Pokémon vector sets regenerated with morphology refinement!")
EOF