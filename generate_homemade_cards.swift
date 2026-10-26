import Foundation
import Cocoa
import PDFKit

let pdfPath = "Homemade Pokemon Cards Scan Jan 1, 2020 at 6.12 PM.pdf"
guard let pdfDoc = PDFDocument(url: URL(fileURLWithPath: pdfPath)) else {
    print("Cannot open \(pdfPath)")
    exit(1)
}

let fileManager = FileManager.default
let conceptsDir = URL(fileURLWithPath: "vectors/concepts")
let creaturesDir = URL(fileURLWithPath: "vectors/creatures")
let cardsDir = URL(fileURLWithPath: "vectors/cards")

try? fileManager.createDirectory(at: conceptsDir, withIntermediateDirectories: true)
try? fileManager.createDirectory(at: creaturesDir, withIntermediateDirectories: true)
try? fileManager.createDirectory(at: cardsDir, withIntermediateDirectories: true)

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

func potrace(inputPbm: String, outputSvg: String, turdsize: Int = 12) {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/Users/mabino/.homebrew/bin/potrace")
    task.arguments = ["-s", "-o", outputSvg, "--turdsize", "\(turdsize)", inputPbm]
    try? task.run()
    task.waitUntilExit()
}

struct Attack {
    let name: String
    let damage: String
    let description: String
}

struct CardDef {
    let id: Int
    let name: String
    let pageIndex: Int
    let primaryType: String
    let secondaryType: String?
    let hp: Int
    let stage: String
    let attack1: Attack
    let attack2: Attack
    let weakness: (type: String, val: String)
    let resistance: (type: String, val: String)?
    let retreatCount: Int
    let notes: String
    let baseCrop: CGRect
    let creatureSubCrop: CGRect
    let conceptSubCrop: CGRect
    let turdsize: Int
    let isPixelStroke: (Double, Double, Double, Double, Int, Int) -> Bool
}

let cardDefs: [CardDef] = [
    CardDef(
        id: 43, name: "Freshtin", pageIndex: 0,
        primaryType: "Steel", secondaryType: nil, hp: 80, stage: "Basic Pokémon",
        attack1: Attack(name: "Nibble", damage: "40+", description: "Flip a coin. If heads, opponent takes 30 more damage."),
        attack2: Attack(name: "Quick Wit", damage: "40", description: "Flip a coin. If heads, the Defending Pokémon is now Paralyzed."),
        weakness: ("Fire", "×2"), resistance: ("Psychic", "-20"), retreatCount: 1,
        notes: "Quick-witted loaf creature with playful antennae and segmented body",
        baseCrop: CGRect(x: 100, y: 170, width: 996, height: 630),
        creatureSubCrop: CGRect(x: 30, y: 10, width: 936, height: 475),
        conceptSubCrop: CGRect(x: 20, y: 10, width: 956, height: 610),
        turdsize: 25,
        isPixelStroke: { r, g, b, bri, x, y in
            return (b - r > 0.07 && bri < 0.80) || bri < 0.52
        }
    ),
    CardDef(
        id: 44, name: "Tridog", pageIndex: 1,
        primaryType: "Normal", secondaryType: nil, hp: 90, stage: "Basic Pokémon",
        attack1: Attack(name: "Three ears", damage: "30+", description: "Flip a coin. If heads add 10 damage to this attack."),
        attack2: Attack(name: "Dog food", damage: "Heal 10", description: "Heal 10 damage from this Pokémon."),
        weakness: ("Fire", "×2"), resistance: nil, retreatCount: 1,
        notes: "Playful triple-eared hound with high spirits and a healthy appetite",
        baseCrop: CGRect(x: 90, y: 170, width: 1006, height: 630),
        creatureSubCrop: CGRect(x: 60, y: 10, width: 896, height: 600),
        conceptSubCrop: CGRect(x: 50, y: 10, width: 916, height: 610),
        turdsize: 16,
        isPixelStroke: { r, g, b, bri, x, y in
            return bri < 0.72 || (r - b > 0.08 && bri < 0.88)
        }
    ),
    CardDef(
        id: 45, name: "Rokoot", pageIndex: 2,
        primaryType: "Steel", secondaryType: nil, hp: 200, stage: "Basic Pokémon",
        attack1: Attack(name: "Lazer", damage: "80+", description: "Flip a coin. If heads add 10 damage to this attack."),
        attack2: Attack(name: "Drilling", damage: "120", description: "Powerful spiral drill attack that pierces through defense."),
        weakness: ("Fighting", "×2"), resistance: ("Psychic", "-20"), retreatCount: 1,
        notes: "Avian automaton with high-powered laser optic and heavy spiral drill arm",
        baseCrop: CGRect(x: 80, y: 170, width: 1016, height: 630),
        creatureSubCrop: CGRect(x: 40, y: 10, width: 936, height: 610),
        conceptSubCrop: CGRect(x: 30, y: 10, width: 956, height: 610),
        turdsize: 12,
        isPixelStroke: { r, g, b, bri, x, y in
            return (r - b > 0.10 && bri < 0.90) || (g - b > 0.08 && bri < 0.85) || bri < 0.60
        }
    ),
    CardDef(
        id: 46, name: "Squigglebug", pageIndex: 5,
        primaryType: "Bug", secondaryType: "Grass", hp: 50, stage: "Basic Pokémon",
        attack1: Attack(name: "Poison", damage: "20", description: "Your opponent's active Pokémon is now poisoned."),
        attack2: Attack(name: "Disasteris Squiggles", damage: "200", description: "Unleashes an overwhelming swarm of chaotic squiggles."),
        weakness: ("Fire", "×2"), resistance: nil, retreatCount: 1,
        notes: "Mischievous squiggling insect whose chaotic movements confound opponents",
        baseCrop: CGRect(x: 90, y: 170, width: 1006, height: 630),
        creatureSubCrop: CGRect(x: 230, y: 10, width: 720, height: 610),
        conceptSubCrop: CGRect(x: 210, y: 10, width: 750, height: 610),
        turdsize: 15,
        isPixelStroke: { r, g, b, bri, x, y in
            return (r - b > 0.08 && bri < 0.90) || bri < 0.65
        }
    ),
    CardDef(
        id: 47, name: "Grallaper", pageIndex: 6,
        primaryType: "Psychic", secondaryType: nil, hp: 80, stage: "Base Pokémon",
        attack1: Attack(name: "Bone Stomp", damage: "50", description: "The Pokémon uses its full body weight to crush the opponent."),
        attack2: Attack(name: "Rattling Leap", damage: "10", description: "Damage and skip opponent's turn if they have under 50 health left."),
        weakness: ("Dark", "×2"), resistance: ("Fighting", "-40"), retreatCount: 1,
        notes: "Geometric skeleton quadruped capable of heavy crushing stomps and staggering leaps",
        baseCrop: CGRect(x: 80, y: 195, width: 1016, height: 615),
        creatureSubCrop: CGRect(x: 40, y: 15, width: 936, height: 485),
        conceptSubCrop: CGRect(x: 20, y: 15, width: 976, height: 600),
        turdsize: 12,
        isPixelStroke: { r, g, b, bri, x, y in
            return bri < 0.70 || (b - r > 0.05 && bri < 0.88)
        }
    ),
    CardDef(
        id: 48, name: "Rangoph", pageIndex: 8,
        primaryType: "Grass", secondaryType: "Ground", hp: 70, stage: "Basic Pokémon",
        attack1: Attack(name: "Wood Tooth", damage: "60", description: "Ineffective if the opponent does not have a solid body."),
        attack2: Attack(name: "Fenced In", damage: "10×", description: "Pokémon builds a structure and launches attacks from higher ground."),
        weakness: ("Fire", "×2"), resistance: ("Water", "-20"), retreatCount: 1,
        notes: "Timber-chewing architect beast that constructs defensive wooden barricades",
        baseCrop: CGRect(x: 90, y: 170, width: 1006, height: 630),
        creatureSubCrop: CGRect(x: 40, y: 20, width: 926, height: 590),
        conceptSubCrop: CGRect(x: 30, y: 10, width: 946, height: 610),
        turdsize: 12,
        isPixelStroke: { r, g, b, bri, x, y in
            return bri < 0.70 || (b - r > 0.05 && bri < 0.85)
        }
    ),
    CardDef(
        id: 49, name: "Notsakiat", pageIndex: 9,
        primaryType: "Electric", secondaryType: nil, hp: 80, stage: "Basic Pokémon",
        attack1: Attack(name: "Static Tangle", damage: "50", description: "Opponent is paralyzed 2 turns if leading digit of remaining HP is odd."),
        attack2: Attack(name: "Knot Strike", damage: "30", description: "Lashes out with high-voltage coiled knot tail."),
        weakness: ("Grass", "×2"), resistance: nil, retreatCount: 2,
        notes: "Feline static generator with an intricate conductive knot tail",
        baseCrop: CGRect(x: 90, y: 170, width: 1006, height: 630),
        creatureSubCrop: CGRect(x: 40, y: 10, width: 926, height: 610),
        conceptSubCrop: CGRect(x: 30, y: 10, width: 946, height: 610),
        turdsize: 12,
        isPixelStroke: { r, g, b, bri, x, y in
            return (r - b > 0.08 && bri < 0.88) || bri < 0.65
        }
    ),
    CardDef(
        id: 50, name: "Ebo", pageIndex: 11,
        primaryType: "Fairy", secondaryType: nil, hp: 110, stage: "Basic Pokémon",
        attack1: Attack(name: "Magic Sneeze", damage: "70", description: "Flip coin. If heads, opponent's last chosen attack is deactivated &amp; reflected."),
        attack2: Attack(name: "Dusty Mess", damage: "10", description: "The opponent is dirtied for one turn."),
        weakness: ("Steel", "×2"), resistance: ("Dark", "-20"), retreatCount: 1,
        notes: "Whimsical tiny fairy sprite whose sneezing discharges unpredictable reversal magic",
        baseCrop: CGRect(x: 90, y: 170, width: 1006, height: 630),
        creatureSubCrop: CGRect(x: 370, y: 230, width: 230, height: 230),
        conceptSubCrop: CGRect(x: 280, y: 220, width: 440, height: 390),
        turdsize: 4,
        isPixelStroke: { r, g, b, bri, x, y in
            return bri < 0.90 || (r - b > 0.03 && bri < 0.95)
        }
    ),
    CardDef(
        id: 51, name: "Wattery", pageIndex: 12,
        primaryType: "Water", secondaryType: nil, hp: 60, stage: "Base Pokémon",
        attack1: Attack(name: "Body Splash", damage: "60", description: "2x against a fire type. The opponent is dirtied for one turn."),
        attack2: Attack(name: "Droplet Dash", damage: "20", description: "Quick splash tackle using floating auxiliary droplets."),
        weakness: ("Electric", "×2"), resistance: ("Fire", "-20"), retreatCount: 1,
        notes: "Expressive sentient water droplet surrounded by floating auxiliary splash orbs",
        baseCrop: CGRect(x: 80, y: 170, width: 1016, height: 630),
        creatureSubCrop: CGRect(x: 40, y: 95, width: 936, height: 410),
        conceptSubCrop: CGRect(x: 30, y: 90, width: 956, height: 490),
        turdsize: 10,
        isPixelStroke: { r, g, b, bri, x, y in
            return (b - r > 0.04 && bri < 0.92) || bri < 0.65
        }
    ),
    CardDef(
        id: 52, name: "Vibrastalk", pageIndex: 14,
        primaryType: "Grass", secondaryType: nil, hp: 90, stage: "Base Pokémon",
        attack1: Attack(name: "Quiverquake", damage: "80", description: "Inflicts 10 damage on the Pokémon with each use."),
        attack2: Attack(name: "Poke", damage: "20", description: "A sharp vibrational jab delivered at resonant frequency."),
        weakness: ("Fire", "×2"), resistance: ("Water", "-20"), retreatCount: 1,
        notes: "Resonant flora tuning fork that vibrates to produce disorienting acoustic waves",
        baseCrop: CGRect(x: 80, y: 170, width: 1016, height: 630),
        creatureSubCrop: CGRect(x: 50, y: 55, width: 916, height: 440),
        conceptSubCrop: CGRect(x: 40, y: 50, width: 936, height: 530),
        turdsize: 10,
        isPixelStroke: { r, g, b, bri, x, y in
            return (b - r > 0.04 && bri < 0.92) || bri < 0.65
        }
    )
]

print("Processing \(cardDefs.count) homemade cards from PDF...")

for def in cardDefs {
    let idStr = String(format: "%02d", def.id)
    let safeName = def.name.lowercased().replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: ".", with: "")
    
    guard let page = pdfDoc.page(at: def.pageIndex) else {
        print("Could not load page \(def.pageIndex)")
        continue
    }
    
    let pageBounds = page.bounds(for: .mediaBox)
    let scale: CGFloat = 2.0
    let pixelWidth = Int(pageBounds.width * scale)
    let pixelHeight = Int(pageBounds.height * scale)
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
    guard let context = CGContext(data: nil, width: pixelWidth, height: pixelHeight, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo) else { continue }
    
    context.setFillColor(CGColor.white)
    context.fill(CGRect(x: 0, y: 0, width: pixelWidth, height: pixelHeight))
    context.scaleBy(x: scale, y: scale)
    page.draw(with: .mediaBox, to: context)
    
    guard let pageCg = context.makeImage(),
          let baseCg = pageCg.cropping(to: def.baseCrop) else { continue }
    
    // 1. Concept SVG
    let conCg = baseCg.cropping(to: def.conceptSubCrop)!
    let conRep = NSBitmapImageRep(cgImage: conCg)
    let conW = conRep.pixelsWide, conH = conRep.pixelsHigh
    let conBytesPerRow = (conW + 7) / 8
    var conBytes = [UInt8](repeating: 0, count: conBytesPerRow * conH)
    for y in 0..<conH {
        for x in 0..<conW {
            if x < 4 || x > conW - 4 || y < 4 || y > conH - 4 { continue }
            let c = conRep.colorAt(x: x, y: y)!.usingColorSpace(.deviceRGB)!
            let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
            let bri = r * 0.299 + g * 0.587 + b * 0.114
            if def.isPixelStroke(r, g, b, bri, x, y) {
                let byteIdx = y * conBytesPerRow + (x / 8)
                let bitVal: UInt8 = 1 << (7 - (x % 8))
                conBytes[byteIdx] |= bitVal
            }
        }
    }
    var pbmCon = "P4\n\(conW) \(conH)\n".data(using: .ascii)!
    pbmCon.append(contentsOf: conBytes)
    let tempConPbm = "/tmp/con_\(idStr).pbm"
    let conceptSvgPath = "vectors/concepts/\(idStr)_\(safeName).svg"
    try? pbmCon.write(to: URL(fileURLWithPath: tempConPbm))
    potrace(inputPbm: tempConPbm, outputSvg: conceptSvgPath, turdsize: def.turdsize)
    try? fileManager.removeItem(atPath: tempConPbm)
    
    // 2. Creature SVG
    let cCg = baseCg.cropping(to: def.creatureSubCrop)!
    let cRep = NSBitmapImageRep(cgImage: cCg)
    let cW = cRep.pixelsWide, cH = cRep.pixelsHigh
    let cBytesPerRow = (cW + 7) / 8
    var cBytes = [UInt8](repeating: 0, count: cBytesPerRow * cH)
    for y in 0..<cH {
        for x in 0..<cW {
            if x < 4 || x > cW - 4 || y < 4 || y > cH - 4 { continue }
            let c = cRep.colorAt(x: x, y: y)!.usingColorSpace(.deviceRGB)!
            let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
            let bri = r * 0.299 + g * 0.587 + b * 0.114
            if def.isPixelStroke(r, g, b, bri, x, y) {
                let byteIdx = y * cBytesPerRow + (x / 8)
                let bitVal: UInt8 = 1 << (7 - (x % 8))
                cBytes[byteIdx] |= bitVal
            }
        }
    }
    var pbmC = "P4\n\(cW) \(cH)\n".data(using: .ascii)!
    pbmC.append(contentsOf: cBytes)
    let tempCPbm = "/tmp/creature_\(idStr).pbm"
    let creatureSvgPath = "vectors/creatures/\(idStr)_\(safeName)_creature.svg"
    try? pbmC.write(to: URL(fileURLWithPath: tempCPbm))
    potrace(inputPbm: tempCPbm, outputSvg: creatureSvgPath, turdsize: def.turdsize)
    try? fileManager.removeItem(atPath: tempCPbm)
    
    // Read creature SVG viewBox and content
    var creatureViewBox = "0 0 100 100"
    var creatureSvgContent = ""
    if let rawSvg = try? String(contentsOf: URL(fileURLWithPath: creatureSvgPath), encoding: .utf8) {
        if let vbMatch = rawSvg.range(of: "viewBox=\"([^\"]+)\"", options: .regularExpression) {
            let fullMatch = String(rawSvg[vbMatch])
            creatureViewBox = fullMatch.replacingOccurrences(of: "viewBox=\"", with: "").replacingOccurrences(of: "\"", with: "")
        }
        if let gStart = rawSvg.range(of: "<g "), let gEnd = rawSvg.range(of: "</svg>") {
            creatureSvgContent = String(rawSvg[gStart.lowerBound..<gEnd.lowerBound])
        }
    }
    
    // 3. Card SVG
    let colors = typeColors[def.primaryType] ?? ("#9E9E9E", "#F5F5F5", "#424242")
    let secColor = def.secondaryType != nil ? (typeColors[def.secondaryType!]?.primary ?? "#78909C") : nil
    let evolvesTo = "Single Stage Pokémon • Homemade Archive 2020"
    let weaknessColor = typeColors[def.weakness.type]?.primary ?? "#EF5350"
    let resistanceColor = def.resistance != nil ? (typeColors[def.resistance!.type]?.primary ?? "#78909C") : "#BDBDBD"
    
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
        <text x="0" y="22" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif" font-size="12" font-weight="700" fill="\(colors.accent)" letter-spacing="1">\(def.stage.uppercased())</text>
        <text x="0" y="52" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif" font-size="28" font-weight="900" fill="#212121">\(def.name)</text>
        
        <!-- HP -->
        <text x="440" y="48" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif" font-size="14" font-weight="800" fill="\(colors.accent)">HP</text>
        <text x="465" y="50" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif" font-size="24" font-weight="900" fill="#212121">\(def.hp)</text>
      </g>

      <!-- Type Badges -->
      <g transform="translate(45, 105)">
        <rect x="0" y="0" width="\(def.secondaryType != nil ? 80 : 95)" height="24" rx="12" fill="\(colors.primary)" />
        <text x="\(def.secondaryType != nil ? 40 : 47.5)" y="16" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="11" font-weight="800" fill="#FFFFFF" text-anchor="middle">\(def.primaryType.uppercased())</text>
        
        \(def.secondaryType != nil ? """
        <rect x="90" y="0" width="80" height="24" rx="12" fill="\(secColor!)" />
        <text x="130" y="16" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="11" font-weight="800" fill="#FFFFFF" text-anchor="middle">\(def.secondaryType!.uppercased())</text>
        """ : "")
        
        <text x="510" y="16" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="12" font-weight="700" fill="#757575" text-anchor="end">NO. \(idStr) / 52</text>
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
        <!-- Original Card Attack 1 -->
        <circle cx="16" cy="16" r="14" fill="\(colors.primary)" />
        <circle cx="16" cy="16" r="6" fill="#FFFFFF" />
        <text x="40" y="21" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="18" font-weight="800" fill="#212121">\(def.attack1.name)</text>
        <text x="510" y="21" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="18" font-weight="800" fill="#212121" text-anchor="end">\(def.attack1.damage)</text>
        <text x="40" y="42" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="12" font-weight="500" fill="#616161">\(def.attack1.description)</text>
        
        <line x1="0" y1="58" x2="510" y2="58" stroke="#E0E0E0" stroke-width="1" />

        <!-- Original Card Attack 2 -->
        <circle cx="16" cy="85" r="14" fill="\(colors.primary)" />
        <circle cx="48" cy="85" r="14" fill="\(secColor ?? colors.accent)" />
        <text x="75" y="90" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="18" font-weight="800" fill="#212121">\(def.attack2.name)</text>
        <text x="510" y="90" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="18" font-weight="800" fill="#212121" text-anchor="end">\(def.attack2.damage)</text>
        <text x="75" y="110" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="12" font-style="italic" fill="#616161">\(def.attack2.description)</text>
      </g>

      <!-- Bottom Stats / Footer -->
      <g transform="translate(45, 720)">
        <line x1="0" y1="0" x2="510" y2="0" stroke="\(colors.primary)" stroke-width="2" opacity="0.3" />
        
        <text x="30" y="22" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="10" font-weight="700" fill="#757575">WEAKNESS</text>
        <text x="210" y="22" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="10" font-weight="700" fill="#757575">RESISTANCE</text>
        <text x="400" y="22" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="10" font-weight="700" fill="#757575">RETREAT</text>

        <!-- Weakness -->
        <circle cx="30" cy="40" r="10" fill="\(weaknessColor)" />
        <text x="46" y="44" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="12" font-weight="800" fill="#212121">\(def.weakness.val)</text>

        <!-- Resistance -->
        \(def.resistance != nil ? """
        <circle cx="210" cy="40" r="10" fill="\(resistanceColor)" />
        <text x="226" y="44" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="12" font-weight="800" fill="#212121">\(def.resistance!.val)</text>
        """ : """
        <text x="210" y="44" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="12" font-weight="700" fill="#9E9E9E">—</text>
        """)

        <!-- Retreat -->
        <g transform="translate(400, 30)">
          \( (0..<def.retreatCount).map { i in "<circle cx=\"\(i * 25)\" cy=\"10\" r=\"10\" fill=\"#BDBDBD\" />" }.joined(separator: "\n          ") )
        </g>

        <text x="255" y="78" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" font-size="10" font-weight="700" fill="#9E9E9E" text-anchor="middle">© Homemade Pokémon Archive • Vector Edition 2026</text>
      </g>
    </svg>
    """
    
    let cardSvgPath = "vectors/cards/\(idStr)_\(safeName)_card.svg"
    try? cardSvg.write(to: URL(fileURLWithPath: cardSvgPath), atomically: true, encoding: .utf8)
    
    print("[\(idStr)/52] Built vector set for \(def.name)")
}

print("All homemade Pokémon vectors built successfully!")
