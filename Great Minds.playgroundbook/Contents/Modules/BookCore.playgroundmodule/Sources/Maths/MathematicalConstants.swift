//
//  ContentView.swift
//  Mathematical Constants
//
//  Created by Niall Kehoe on 30/03/2021.
//

import SwiftUI

/// Mathematical Constants View
public struct MathematicalConstants: View {

    @State private var mathSelection: String = "π"
    
    public init() { }
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var isFullScreen = false
    @State private var halfSizes = CGSize(width: 0, height: 0)
    @State private var secondWidthTaken = false
    @State private var currentWidth: CGFloat!
    
    private let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    HStack() {
                        Picker(selection: $mathSelection, label: Text("")) {
                            ForEach(["π","℮","ϕ"], id: \.self) { elem in
                                Text(elem).tag(elem)
                            }
                        }.pickerStyle(SegmentedPickerStyle())
                    }.padding()

                    if mathSelection == "π" {
                        PiHolder(colorScheme: colorScheme)
                    } else if mathSelection == "℮" {
                        eViewHolder(colorScheme: colorScheme)
                    } else {
                        GoldenRatio(colorScheme: colorScheme)
                    }
                    Spacer()
                }.padding()
                
                if !isFullScreen {
                    VisualEffectView(effect: UIBlurEffect(style: .dark))
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                        
                    VStack {
                        CText(text: "Full Screen", font: .largeTitle, weight: .bold, foregroundColor: #colorLiteral(red: 0, green: 0.4485880136, blue: 1, alpha: 1).suColor)
                        CText(text: "Please open the page in Full Screen in order to continue.", font: .headline, weight: .medium, foregroundColor: #colorLiteral(red: 0.06894329935, green: 0.06896290928, blue: 0.06894072145, alpha: 1).suColor)
                    }
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
                    .frame(width: geometry.size.width * 0.6).padding()
                    .background(CRectangle(cornerRadius: 15, foregroundColor: .white))
                }
            }.onAppear {
                halfSizes = CGSize(width: geometry.size.width, height: geometry.size.height)
                currentWidth = halfSizes.width
            }
            .onReceive(timer) { input in
                withAnimation(.easeInOut(duration: 1)) {
                    if currentWidth != geometry.size.width && !secondWidthTaken { /// change in size and both sides not tried
                        if geometry.size.width < halfSizes.width { /// Started in full screen -> Needs to flip
                            halfSizes = geometry.size
                        }
                        secondWidthTaken = true
                        
                    }
                    isFullScreen = geometry.size.width != halfSizes.width ? true:false
                    
                }
            }
            .onChange(of: isFullScreen, perform: { value in
                if value {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "isFullScreen"), object: nil)
                }
            })
        }
        
    }
}
