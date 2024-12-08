//
//  KeyViewCollection.swift
//  CrimsonCruiser
//
//  Created by Konstantin Freiherr von Stein on 12/6/24.
//

import SwiftUI

struct KeyViewCollection: View {
    
    @Binding var pressedKeys: [Bool]
    @Binding var startedDriving: Bool
    @Binding var distance: CGFloat
    
    var body: some View {
        // Dirinvg Overlay
        VStack() {
            HStack() {
                HStack() {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 23, weight: .bold, design: .default))
                        .symbolRenderingMode(.multicolor)
                        .padding(.horizontal, 3)
                    VStack(alignment: .leading) {
                        Text("Driving works but is unfortunatley not very polished... ")
                        Text("Sorry if you experience issues. Press R to Reset.")
                    }
                    .padding(.trailing, 3)
                }
                .padding(7)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(8)
            }
            
            Text("Distance to Destination: \(String(format: "%.0f", distance))")
                .padding(8)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(8)
                .padding(.top, -18)
                .font(.system(size: 17, weight: .medium, design: .rounded))
            
            Spacer()
            HStack() {
                HStack() {
                    KeyView(pressed: $pressedKeys[0], key: "W", description: "Accelerate")
                    KeyView(pressed: $pressedKeys[1], key: "A", description: "Steer Left")
                    KeyView(pressed: $pressedKeys[3], key: "D", description: "Steer Right")
                    KeyView(pressed: $pressedKeys[2], key: "S", description: "Brake")
                    KeyView(pressed: $pressedKeys[4], key: "X", description: "Backwards")
                    
                }
                .padding(7)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .padding(8)
                
                Spacer()
                
                HStack() {
                    KeyView(pressed: .constant(false), key: "R", description: "Reset")
                    KeyView(pressed: .constant(false), key: "Q", description: "Leave Drive")
                }
                .padding(7)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .padding(8)
            }
        }
        .opacity(startedDriving == true ? 1 : 0)
    }
}

#Preview {
    KeyViewCollection(pressedKeys: .constant([true, true, true, true, true, true,]), startedDriving: .constant(true), distance: .constant(22.55))
        .background(.white)
}
