//
//  myFonts.swift
//  █▄ ▄█ ▀▄▀ ▄▀▀ █ █ ▄▀▀ ▀█▀ ▄▀▄ █▄ ▄█ ▄▀▀
//  █ ▀ █  █  ▀▄▄ ▀▄█ ▄██  █  ▀▄▀ █ ▀ █ ▄██
//  Created by Konstantin Freiherr von Stein


import Foundation
import SwiftUI

extension Int {
    var fontTypeConverter: myFonts.fontType {
        get {
            return myFonts.fontType(rawValue: self) ?? .compressed
        }
        set {
            self = newValue.rawValue
        }
    }
}
/// Quick font customization view modifier
///
/// myFonts provides a quick way to change the look & style of text based on four existing presets. \
/// 0 ❯ none, 1 ❯ compressed, 2 ❯ expanded, 3 ❯ standard, 4 ❯ rounded.
/// ## Example Use for custom case
/// ``` swift
/// Text("Hello World!")
///     .modifier(myFonts(customFontStyle: .compressed, fontSize: 40, fontWeight: .bold))
/// ```
/// ## ToDo:
/// Add enum option to modifier that indicates weather the fontSizeOffset prioritizes consistent width, height or a size that fluctuates in between.
struct myFonts: ViewModifier {
    /// fontType Enum
    ///
    /// 0 ❯ none, 1 ❯ compressed, 2 ❯ expanded, 3 ❯ standard, 4 ❯ rounded.
    enum fontType: Int, Codable, CaseIterable {
        case none = 0
        case compressed = 1
        case expanded = 2
        case standard = 3
        case rounded = 4
    }
    
    /// select .none, .standard, .expanded or .compressd
    var customFontStyle: fontType
    /// fontSize will be adjusted accordingly when fontType is not .standard
    let fontSize: CGFloat
    /// fontWeight
    let fontWeight: Font.Weight
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: fontSize + (fontAssigner()[2] as! CGFloat), weight: fontWeight, design: fontAssigner()[1] as? Font.Design))
            .fontWidth(fontAssigner()[0] as? Font.Width)
    }
    /// fontAssigner provides fontType specific information.
    ///
    /// localFontWidth  ❯ 0 \
    /// localFontDesign ❯ 1 \
    /// localFontSizeOffset ❯ 2
    func fontAssigner() -> [Any] {
        
        var localfontWidth: Font.Width = .standard
        var localfontDesign: Font.Design = .default
        var localfontSizeOffset: CGFloat = 0
        
        if customFontStyle == .compressed {
            localfontWidth = .compressed
            localfontDesign = .default
            localfontSizeOffset = (fontSize * -0.05).rounded()
        } else if customFontStyle == .expanded {
            localfontWidth = .expanded
            localfontDesign = .default
            localfontSizeOffset = (fontSize * -0.27).rounded()
        } else if customFontStyle == .standard {
            localfontWidth = .standard
            localfontDesign = .default
            localfontSizeOffset = (fontSize * -0.2).rounded()
        } else if customFontStyle == .rounded {
            localfontWidth = .standard
            localfontDesign = .rounded
            localfontSizeOffset = (fontSize * -0.2).rounded()
        } else if customFontStyle == .none {
            localfontWidth = .standard
            localfontDesign = .default
            localfontSizeOffset = (fontSize * -0.2).rounded()
        }
        
        return [localfontWidth, localfontDesign, localfontSizeOffset]
    }
}

