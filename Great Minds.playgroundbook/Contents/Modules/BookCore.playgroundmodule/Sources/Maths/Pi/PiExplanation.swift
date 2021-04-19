//
//  PiExplanation.swift
//  BookCore
//
//  Created by Niall Kehoe on 30/03/2021.
//

import SwiftUI

/// Pi Explanation View
struct PiExplanation: View {
    
    var geometry: GeometryProxy
    let colorScheme: ColorScheme
    
    @State private var circleRotation : Double = 0      /// Rotation of circle
    @State private var circleSimulationStep = 0         /// Circle Simulation Step
    @State private var viewDidAppear = false            /// whether View has Appeared
    
    var body: some View {
        ZStack {
            if viewDidAppear {
                CRectangle(cornerRadius: 15, foregroundColor: lightColourModifier(colorScheme: colorScheme))
                    .frame(width: (geometry.size.width * 0.63) - 60)
                ScrollView {
                    VStack{
                        CText(text: "π", font: .largeTitle, weight: .bold, foregroundColor: darkColourModifier(colorScheme: colorScheme))
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        HStack {
                            PiInfo(text: "π is a mathematical constant, defined as the ratio between the diameter of a circle and its circumference. It is also known as Archimedes constant.", colorScheme: colorScheme)
                            CircleDesign(sizeOfCircles: 85, circleRotation: circleRotation, showDot: false, showUnderLabel: false)
                            Spacer().frame(width: 5)
                        }
                        
                        HStack {
                            Spacer().frame(width: 5)
                            
                            PiInfo(text: "It is believed that π has no finite decimal representation and does not have a repetitive pattern. Many civilisations have approximated this constant over time including the Greeks, Egyptians and Babylonians. The invention of calculus allowed hundreds of digits of π to be calculated. With the latest supercomputers, trillions of digits of π can be calculated.", colorScheme: colorScheme)
                        }
                        
                        PentagonSim(colorScheme: colorScheme).frame(width: (geometry.size.width * 0.63) - 60, height: (geometry.size.height * 0.22))
                            
                        HStack {
                            Spacer().frame(width: 12)
                                
                            CImageColoured(name: "circlearea", size: CGSize(width: CGFloat(((geometry.size.width * 0.63) - 60) - (geometry.size.height * 0.3 * 0.75))*0.63, height: CGFloat(((geometry.size.width * 0.63) - 60) - (geometry.size.height * 0.3 * 0.75))*0.63*257/1610), col: darkColourModifier(colorScheme: colorScheme))
                        }
                        HStack {
                            ZStack {
                                CircleDemonstration(geometry: geometry, sizeOfCircles: min((((geometry.size.width * 0.63) - 60)/6), (geometry.size.height*0.3)), circleStep: circleSimulationStep)
                                    .frame(height: min((((geometry.size.width * 0.63) - 60)/6), (geometry.size.height*0.3)) + 30)
                            }.frame(width: ((geometry.size.width * 0.63) - 60) * 0.7)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(darkColourModifier(colorScheme: colorScheme), lineWidth: 4))
                            .padding()
                                
                            Spacer()
                                    
                            Button(action: {
                                playSound("Pop")
                                circleSimulationStep += 1
                                if circleSimulationStep == 1 {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        circleSimulationStep += 1
                                    }
                                }
                            }, label: {
                                Icon(name: "play.circle", width: 80, color: darkColourModifier(colorScheme: colorScheme))
                            })
                                    
                            Spacer()
                        }
                    }.frame(width: (geometry.size.width * 0.6) - 60)
                }.frame(width: (geometry.size.width * 0.6) - 60)
            }
        }
        .clipped()
        .frame(width: abs((geometry.size.width * 0.6) - 60))
        .onAppear {
            startRockingAnim()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeIn(duration: 1)) {
                    viewDidAppear = true
                }
            }
        }
        .transition(.move(edge: .trailing))
    }
    
    /// Start Rocking Animation
    private func startRockingAnim() {
        rotateCircle()
        Timer.scheduledTimer(withTimeInterval: 6.4, repeats: true) { (timer) in
            rotateCircle()
        }
    }
    
    /// Rocking motion of Circle
    private func rotateCircle() {
        rotateTo(15)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            rotateTo(-15)
        }
    }
    /// Rotation of Circle
    private func rotateTo(_ value: Double) {
        withAnimation(.easeInOut(duration: 3)) {
            circleRotation = value
        }
    }
}

/// Pi Info
fileprivate struct PiInfo: View {
    let text: String
    let colorScheme: ColorScheme
    
    var body: some View {
        CText(text: text, font: .callout, foregroundColor: darkColourModifier(colorScheme: colorScheme))
            .multilineTextAlignment(.leading)
            .padding()
    }
}
