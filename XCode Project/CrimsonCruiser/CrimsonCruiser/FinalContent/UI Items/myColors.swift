
//  myColors.swift
//  █▄ ▄█ ▀▄▀ ▄▀▀ █ █ ▄▀▀ ▀█▀ ▄▀▄ █▄ ▄█ ▄▀▀
//  █ ▀ █  █  ▀▄▄ ▀▄█ ▄██  █  ▀▄▀ █ ▀ █ ▄██
//  Created by Konstantin Freiherr von Stein

import Foundation
import SwiftUI

struct myColors {
    enum colorType: Int, Codable, CaseIterable {
        case background = 0
        case primary = 1
        case red = 2
        case pink = 3
        case purple = 4
        case blue = 5
        case green = 6
        case yellow = 7
        case orange = 8
        case white = 9
        case gray = 10
        case black = 11
        
    }
}

func myColorProvider(localColor: myColors.colorType) -> Color {
    switch localColor {
        #if os(macOS)
    case .background: return Color(nsColor: .windowBackgroundColor)
        #elseif os(iOS)
    case .background: return Color(uiColor: .systemBackground)
        #endif
    case .primary: return .primary
    case .red: return .red
    case .pink: return .pink
    case .purple: return .purple
    case .blue: return .blue
    case .green: return .green
    case .yellow: return .yellow
    case .orange: return .orange
    case .white: return .white
    case .gray: return .gray
    case .black: return .black
    }
}

extension Int {
    var colorTypeConverter: myColors.colorType {
        get {
            return myColors.colorType(rawValue: self) ?? .background
        }
        set {
            self = newValue.rawValue
        }
    }
}
