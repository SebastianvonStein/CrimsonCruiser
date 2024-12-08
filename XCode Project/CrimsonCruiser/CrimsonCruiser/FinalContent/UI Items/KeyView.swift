//
//  KeyView.swift
//  CrimsonCruiser
//
//  Created by Konstantin Freiherr von Stein on 12/6/24.
//

import SwiftUI

struct KeyView: View {
    
    @Binding var pressed: Bool
    var key: String = "W"
    var description: String = "Accelerate"
    
    var body: some View {
        ZStack() {
            VStack() {
                ZStack() {
                    
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(.primary, lineWidth: 3)
                        .background(pressed ? .white.opacity(0.4) : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    
                    Text(key)
                        .font(.system(size: 25, weight: pressed ? .bold : .medium, design: .rounded))
                        .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 2)
                        
                }
                .frame(width: 55, height: 55)
                
                Text(description)
                    .font(.system(size: 10, weight: .light, design: .default))
                    .padding(.vertical, 4)
                
            }
        }
        .frame(width: 60)
    }
}

#Preview {
    HStack(spacing: 15) {
        KeyView(pressed: .constant(true), key: "W", description: "Accelerate")
        KeyView(pressed: .constant(false), key: "W", description: "Accelerate")
        
    }
    .padding(20)
}
