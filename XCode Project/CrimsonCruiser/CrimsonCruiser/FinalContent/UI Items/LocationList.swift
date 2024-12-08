//
//  LocationList.swift
//  CrimsonCruiser
//
//  Created by Konstantin Freiherr von Stein on 11/22/24.
//

/*
 ▄▀▀ █▀▄ █ █▄ ▄█ ▄▀▀ ▄▀▄ █▄ █
 ▀▄▄ █▀▄ █ █ ▀ █ ▄██ ▀▄▀ █ ▀█
 
 ▄▀▀ █▀▄ █ █ █ ▄▀▀ ██▀ █▀▄
 ▀▄▄ █▀▄ ▀▄█ █ ▄██ █▄▄ █▀▄
 */

import SwiftUI

/// This view is an interactive button/hoverable that expands and shows users the list of all possible departure and destination locations!
///
/// It contains custom interactions for iOS & MacOS, and returns the selected location through an @Binding variable
/// - Parameters:
///   - selectedNode: The starting `WebNode` for the path.
///   - selectedLocation: The destination `WebNode` for the path.
struct LocationList: View {
    
    @Binding var selectedNode: String
    @Binding var selectedLocation: String
    var descirption: String = "placeholder"
    @State var hovering: Bool = false
    
    // locationNode_32
    var body: some View {
        VStack() {
            
            Spacer()
            
            VStack() {
                
                HStack() {
                    Spacer()
                    VStack(spacing: 4) {
                        Text(descirption)
                        
                        Text(selectedLocation)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                    }
                    Spacer()
                }
                .padding(.vertical)
                
                if hovering {
                    
                    ScrollView() {
                        VStack(alignment: .center) {
                            
                            button(name: "Holworthy", node: "_50")
                            button(name: "Phillips Brooks", node: "_21")
                            button(name: "Mower", node: "_48")
                            button(name: "Stoughton", node: "_49")
                            button(name: "Holden Chapel", node: "_45")
                            button(name: "Lionel", node: "_20")
                            button(name: "Harvard Hall", node: "_18")
                            button(name: "Hollis", node: "_19")
                            button(name: "Mass Hall", node: "_17") // DONE
                            button(name: "Matthews - E", node: "_37")
                            button(name: "Matthews - W", node: "_36")
                            button(name: "Straus", node: "_38")
                            button(name: "Lehman", node: "_13")
                            button(name: "Grays - N", node: "_39")
                            button(name: "Grays - S", node: "_15")
                            button(name: "Weld - E", node: "_6")
                            button(name: "Weld - W", node: "_7")
                            button(name: "Boylston", node: "_12")
                            button(name: "Wiggelsworth A-D", node: "_46")
                            button(name: "Wiggelsworth I-E", node: "_41")
                            button(name: "University Hall - NE", node: "_3")
                            button(name: "University Hall - SE", node: "_5")
                            button(name: "University Hall - S", node: "_54")
                            button(name: "University Hall - W", node: "_4")
                            button(name: "Thayer - North", node: "_53")
                            button(name: "Thayer - East", node: "_23")
                            button(name: "Thayer - South", node: "_52")
                            button(name: "Thayer - West", node: "_22")
                            button(name: "Canaday A", node: "_27")
                            button(name: "Canaday B", node: "_29")
                            button(name: "Canaday C-D", node: "_28")
                            button(name: "Canaday E-G", node: "_30")
                            button(name: "Memorial Church - NE", node: "_25")
                            button(name: "Memorial Church - NW", node: "_26")
                            button(name: "Memorial Church - W", node: "_24")
                            button(name: "Memorial Church - S", node: "_1")
                            button(name: "Memorial Church - SE", node: "_51")
                            button(name: "Sever - E", node: "_33")
                            button(name: "Sever - W", node: "_2")
                            button(name: "Widner Library - N", node: "")
                            button(name: "Widner Library - E", node: "_56")
                            button(name: "Widner Library - S", node: "_11")
                            button(name: "Widner Library - W", node: "_55")
                            button(name: "Houghton", node: "_9")
                            button(name: "Emerson - W", node: "_8")
                            button(name: "Emerson - N", node: "_34")
                            button(name: "Robinson - S", node: "_32")
                            button(name: "Robinson - W", node: "_31")
                            
                            Spacer()
                                .frame(width: 10, height: 15)
                        }
                    }
                    .scrollIndicators(.never)
                    
                }
                
                
            }
            .onHover() { hover in
#if os(macOS)
                hovering = hover
#endif
            }
            .padding(.horizontal)
            .foregroundStyle(.white)
            .clipped()
            .background(RoundedRectangle(cornerRadius: 15).foregroundStyle(Color(hue: 0.3, saturation: 0.15, brightness: 0.60)))
            .animation(.snappy, value: hovering)
            .shadow(radius: 20)
            .onTapGesture {
                hovering.toggle()
            }
        }
        
    }
    
    func button(name: String, node: String) -> some View {
        createMyButton(overlay: {Text(name)}, action: {
            selectedLocation = name
            selectedNode = node
        }, colorType: .white, observeVariable: selectedNode, onWhenVarEquals: node)
    }
}

#Preview {
    
    VStack() {
        LocationList(selectedNode: .constant("location"), selectedLocation: .constant("Memorial Church - NWW"))
            .frame(width: 250, height: 300)
            .padding(20)
    }
    .background(.red)
        
}



