//
//  ViewExtensions.swift
//  CrimsonCruiser
//
//  Created by Konstantin Freiherr von Stein on 11/16/24.
//

import Foundation
import SwiftUI

// █▀█ ▄▀▄ █▄ █ █▀▄ ▄▀▄ █▄ ▄█     ▄▀▀ ▀█▀ █ █ █▀▀ █▀▀
// █▀▄ █▀█ █ ▀█ █▄▀ ▀▄▀ █ ▀ █     ▄██  █  █▄█ █▀▀ █▀▀

/*
 These are a bunch of random code snippits...
 Almost all of them are used for the DebugNodeGraph view and not for the final project...
 */


struct basicButtonModifier: ViewModifier {
    @State var ishovering: Bool = false
    @State var tapped: Bool = false
    func body(content: Content) -> some View {
        content
            .padding(ishovering ? 8 : 4)
            .foregroundStyle(.black)
            .background(Circle())
            .onHover() { hover in
                ishovering = hover
            }
            .animation(.snappy(duration: 0.35, extraBounce: 0.45), value: ishovering)
            .padding(ishovering ? 4 : 8)
    }
}


extension View {
    func basicButton() -> some View {
        self.modifier(basicButtonModifier())
        }
    }


struct locationButtonModifier: ViewModifier {
    @State var ishovering: Bool = false
    @State var tapped: Bool = false
    func body(content: Content) -> some View {
        HStack() {
            Spacer()
            content
            Spacer()
        }
            .buttonStyle(.plain)
            .padding(7)
            .background(.white.opacity( ishovering ? 0.2 : 0.1))
            .onHover(perform: { hover in
                ishovering = hover
            })
            .animation(.snappy(duration: 0.2), value: ishovering)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        
        
    }
}


extension View {
    func locationButton() -> some View {
        self.modifier(locationButtonModifier())
        }
    }

// MARK: DEBUG -

struct debugButtonviewModifier: ViewModifier {
    @State var hovering: Bool = false
    func body(content: Content) -> some View {
        content
            .buttonStyle(.plain)
            .padding(8)
            .background(.thinMaterial)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .onHover() { hover in
                hovering = hover
            }
            .shadow(color: hovering ? .black.opacity(0.2) : .clear, radius: 5, x: 0, y: 4)
            .animation(.snappy, value: hovering)
            
        }
    }

struct debugButtonviewModifierShort: ViewModifier {
    @State var hovering: Bool = false
    func body(content: Content) -> some View {
        content
            .buttonStyle(.plain)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.thinMaterial)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .onHover() { hover in
                hovering = hover
            }
            .shadow(color: hovering ? .black.opacity(0.2) : .clear, radius: 5, x: 0, y: 4)
            .animation(.snappy, value: hovering)
        }
    }


struct debugBGviewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(8)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding()
        }
    }


extension View {
    func debugButtonStyle(tall: Bool = true) -> some View {
        Group {
            if tall {
                self.modifier(debugButtonviewModifier())
            } else {
                self.modifier(debugButtonviewModifierShort())
            }
        }
    }
}

extension View {
    func debugBGStyle(active: Bool = true) -> some View {
        Group {
            if active {
                self.modifier(debugBGviewModifier())
            } else {
                self
            }
        }
    }
}

#Preview() {
    VStack() {
        VStack() {
            Button("Hello"){
                print("Hello")
            }.debugButtonStyle()
            
            Button("Hello"){
                print("Hello")
            }.debugButtonStyle(tall: false)
            
            Image(systemName: "map")
                .frame(width: 30, height: 30)
                .font(.system(size: 20, weight: .bold, design: .default))
                .basicButton()
            
            
            Button("Weidner Library") {}
                .locationButton()
            
        }
        .debugBGStyle()
    }
    .padding(50)
    .background(.gray)
}
