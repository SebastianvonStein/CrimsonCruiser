//
//  mainButton.swift
//  CrimsonCruiser
//
//  Created by Konstantin Freiherr von Stein on 11/23/24.
//

/*
 ▄▀▀ █▀▄ █ █▄ ▄█ ▄▀▀ ▄▀▄ █▄ █
 ▀▄▄ █▀▄ █ █ ▀ █ ▄██ ▀▄▀ █ ▀█
 
 ▄▀▀ █▀▄ █ █ █ ▄▀▀ ██▀ █▀▄
 ▀▄▄ █▀▄ ▀▄█ █ ▄██ █▄▄ █▀▄
 */

import SwiftUI

// Litteraly just a custom button consoledated into its own view for code cleanliness and simplicity!
// Is used in the Main ContentView to start driving :)
struct mainButton: View {
    
    let _action: () -> Void
    @State var hovering: Bool = false
    
    var body: some View {
        
        Button(action: _action) {
            HStack() {
                Spacer()
                Text("Start Driving!")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                Spacer()
            }
            .frame(height: hovering ?  82 : 72)
            .foregroundStyle(.white)
            .clipped()
            .background(RoundedRectangle(cornerRadius: 15).foregroundStyle(Color(hue: 0.3, saturation: 0.15, brightness: 0.60)))
            .shadow(radius: 20)
            .onHover() { hover in
                hovering = hover
            }
            .animation(.snappy(duration: 0.3, extraBounce: 0.2), value: hovering)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack() {
        mainButton() {}
    }
    .frame(height: 100)
    .padding(20)
}
