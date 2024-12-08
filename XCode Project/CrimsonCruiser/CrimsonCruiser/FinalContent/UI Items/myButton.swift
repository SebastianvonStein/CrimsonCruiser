//
//  myButton.swift
//  █▄ ▄█ ▀▄▀ ▄▀▀ █ █ ▄▀▀ ▀█▀ ▄▀▄ █▄ ▄█ ▄▀▀
//  █ ▀ █  █  ▀▄▄ ▀▄█ ▄██  █  ▀▄▀ █ ▀ █ ▄██
//  Created by Konstantin Freiherr von Stein

import SwiftUI

import Foundation
import SwiftUI

struct MyButton<Overlay: View, Trigger: Equatable>: View {
    let overlay: () -> Overlay
    let action: () -> Void
    let colorType: myColors.colorType
    let fontType: myFonts.fontType
    let observeVariable: Trigger
    let onWhenVarEquals: Trigger
    
    @State private var hovering: Bool = false

    var body: some View {
        Button(action: action) {
            overlay()
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .modifier(myFonts(customFontStyle: fontType, fontSize: 20, fontWeight: .light))
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(
                        observeVariable == onWhenVarEquals
                        ? AnyShapeStyle(myColorProvider(localColor: colorType).opacity( hovering ? 0.35 : 0.25))
                        : //AnyShapeStyle(.thinMaterial)
                        AnyShapeStyle(myColorProvider(localColor: colorType).opacity( hovering ? 0.2 : 0.1))
                        
                    )
                )
                .foregroundStyle(
                    observeVariable == onWhenVarEquals
                    ? myColorProvider(localColor: .primary)
                    : myColorProvider(localColor: .primary)
                )
                .onHover { hover in
                    hovering = hover
                }
                .animation(.snappy(duration: 0.3, extraBounce: 0.2), value: hovering)
                .animation(.snappy(duration: 0.4, extraBounce: 0.2), value: observeVariable)
        }
        .buttonStyle(.plain)
    }
}

// Usage Example
func createMyButton<Overlay: View, Trigger: Equatable>(
    overlay: @escaping () -> Overlay,
    action: @escaping () -> Void,
    colorType: myColors.colorType,
    fontType: myFonts.fontType = .standard,
    observeVariable: Trigger,
    onWhenVarEquals: Trigger
) -> MyButton<Overlay, Trigger> {
    return MyButton(
        overlay: overlay,
        action: action,
        colorType: colorType,
        fontType: fontType,
        observeVariable: observeVariable,
        onWhenVarEquals: onWhenVarEquals
    )
}

#Preview {
    createMyButton(overlay: {Text("Hello")}, action: {}, colorType: .pink, observeVariable: "hi", onWhenVarEquals: "hi")
    
    createMyButton(overlay: {Text("Hello")}, action: {}, colorType: .pink, observeVariable: "hi", onWhenVarEquals: "bye")
}
