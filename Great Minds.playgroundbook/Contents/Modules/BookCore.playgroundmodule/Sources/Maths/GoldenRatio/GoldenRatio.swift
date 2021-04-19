//
//  GoldenRatio.swift
//  BookCore
//
//  Created by Niall Kehoe on 01/04/2021.
//

import SwiftUI

/// Golden Ratio View
struct GoldenRatio: View {
    
    let colorScheme: ColorScheme
    
    private static let goldenRatio = 1.6180339887
    
    @State private var BtnScaleAnimation: Bool = true                       /// Start Graphing Btn Scale Effect
    @State var NestedFractiondata: [Point] = [.init(x: 0, y: 10)]
    @State var Squaresdata: [Point] = [.init(x: 0, y: 10)]
    static fileprivate let goldenRatioRatios : [Int:CGFloat] = [1: 220/770,2: 270/1338,3: 233/575,4:153/612,5: 175/759,6: 238/1044,7: 226/609,8: 333/684,9: 492/1149,10: 153/612,11: 261/1704]                       /// height ratios
    
    var body: some View {
        GeometryReader { (geometry) in
            VStack {
                ScrollView {
                    VStack {
                        HStack {
                            CText(text: "Golden Ratio (ϕ)", font: .title, weight: .bold).padding(insets: [10,30,0,0])
                            Spacer()
                        }
                        
                        HStack(alignment: .top) {
                            GoldenRatioRectangleDemonstration().frame(width: geometry.size.width * 0.36)
                            Spacer().frame(width: 30)
                            VStack(alignment: .leading, spacing: 2) {
                                CImageColoured(name: "goldenratioformula1", size: CGSize(width: geometry.size.width * 0.26, height: geometry.size.width * 0.26 * GoldenRatio.goldenRatioRatios[1]!), col: equationColourModifier(colorScheme: colorScheme))
                                HStack {
                                    CImageColoured(name: "goldenratioformula2", size: CGSize(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4 * GoldenRatio.goldenRatioRatios[2]!), col: equationColourModifier(colorScheme: colorScheme))
                                    Spacer()
                                    
                                    CText(text: "∵", font: .largeTitle, weight: .heavy)
                                    CText(text: "ϕ = a/b, ϕ⁻¹=b/a", font: .title2)
                                    
                                    Spacer().frame(width: 20)
                                }.multilineTextAlignment(.center)
                                
                                CImageColoured(name: "goldenratioformula3", size: CGSize(width: CGFloat(((geometry.size.width * 0.36 - 20) * CGFloat(1/GoldenRatio.goldenRatio)) - CGFloat(geometry.size.width * 0.22 * 220/770) - CGFloat(geometry.size.width * 0.4 * 270/1338)) * 1.1 * 575/233, height: CGFloat((((geometry.size.width * 0.36 - 20) * CGFloat(1/GoldenRatio.goldenRatio)) - CGFloat(geometry.size.width * 0.22 * 220/770) - CGFloat(geometry.size.width * 0.4 * 270/1338))*1.1)), col: equationColourModifier(colorScheme: colorScheme))
                                    .padding(0)
                               
                            }
                            Spacer()
                        }.frame(height: geometry.size.width * 0.36 * CGFloat(1/GoldenRatio.goldenRatio))
                        .padding(insets: [2,30,10,30])
                        
                        HStack(alignment: .top) {
                            Spacer().frame(width: 40)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                
                                CText(text: "Two lengths are in a golden proportion when their ratio is equal to the ratio of their sum in relation to the larger length. Therefore, \n (a+b)/a = (a/b). \n Using some algebraic manipulation, we can construct a quadratic equation which we can solve using the quadratic formula.", font: .headline, weight: .semibold).padding()
                            }.frame(width: abs((geometry.size.width - 80) * 0.36))
                            
                            //Second VStack
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    GoldenRatioEquations(item: 4, geometry: geometry, colorScheme: colorScheme)
                                    GoldenRatioEquations(item: 5, geometry: geometry, colorScheme: colorScheme)
                                }
                                HStack {
                                    GoldenRatioEquations(item: 6, geometry: geometry, colorScheme: colorScheme)
                                    
                                    CText(text: "=", font: .title2, weight: .medium, foregroundColor: equationColourModifier(colorScheme: colorScheme))
                                    
                                    Spacer()
                                    
                                    GoldenRatioEquations(item: 7, geometry: geometry, colorScheme: colorScheme)
                                }
                                HStack {
                                    SolutionText(name: "ϕ = 1.6180339887...", geometry: geometry)
                                    
                                    CText(text: "or", font: .title2, weight: .medium, foregroundColor: equationColourModifier(colorScheme: colorScheme))

                                    SolutionText(name: "ϕ = -0.6180339887...", geometry: geometry)
                                }
                            }.frame(width: abs(geometry.size.width - 80) * 0.64, height: abs(geometry.size.height * 0.09 * 3) + 20)
                        }.frame(width: abs(geometry.size.width - 80))
                        
                        Spacer().frame(height: 20)
                        
                        CText(text: "Alternative solutions", font: .title, weight: .semibold)
                        
                        Group {
                            AlternativeSolution(parent: self, geometry: geometry, nestedFraction: true, animating: BtnScaleAnimation)
                                .background(Color.blue.opacity(colorScheme == .light ? 0.2: 0.9))
                            Spacer().frame(height: 10)
                            AlternativeSolution(parent: self, geometry: geometry, nestedFraction: false, animating: BtnScaleAnimation)
                                .background(Color.green.opacity(colorScheme == .light ? 0.2: 0.9))
                        }.frame(width: abs(geometry.size.width - 80)).cornerRadius(10)
                    }
                }
            }.onAppear {
                withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(1), {
                    self.BtnScaleAnimation.toggle()
                })
            }
        }
    }
}

fileprivate struct MathArrow: View {
    let geometry: GeometryProxy
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        CImageColoured(name: "matharrow", size: CGSize(width: abs(geometry.size.width - 80) * 0.05, height: abs(geometry.size.width - 80) * 0.05), col: lightColourModifier(colorScheme: colorScheme))
    }
}
fileprivate struct GoldenRatioImg: View {
    let geometry: GeometryProxy
    let no: Int
    let ratio: CGFloat                  /// h/w ratio
    var multiplier: CGFloat = 0.25
    
    var body: some View {
        Spacer()
        CImage(name: "goldenratioformula\(no)", size: CGSize(width: abs(geometry.size.width - 80) * multiplier, height: abs(geometry.size.width - 80) * multiplier * ratio)).padding(0)
        Spacer()
    }
}
fileprivate struct GoldenRatioEquations: View {
    let item: Int
    let geometry: GeometryProxy
    let colorScheme: ColorScheme
    
    var body: some View {
        CImageColoured(name: "goldenratioformula\(item)", size: CGSize(width: geometry.size.height * 0.09 * (1/GoldenRatio.goldenRatioRatios[item]!), height: geometry.size.height * 0.09), col: equationColourModifier(colorScheme: colorScheme))
            .padding(insets: [0,25,0,0])
        Spacer()
    }
}

fileprivate struct AlternativeSolution: View {
    let parent: GoldenRatio
    var geometry: GeometryProxy
    let nestedFraction: Bool
    var animating: Bool
    
    @State private var previousValue : Double = 1
    @State private var no = 0
    
    var body: some View {
        HStack {
            ForEach(nestedFraction ? [3,8,9] : [3,4,10,11], id: \.self) { elem in
                GoldenRatioImg(geometry: geometry,no: elem, ratio: GoldenRatio.goldenRatioRatios[elem]!, multiplier: nestedFraction ? 0.2: 0.17)
                
                if elem != (nestedFraction ? 9:11) {
                    MathArrow(geometry: geometry)
                    Spacer()
                }
            }
        }.frame(width: abs(geometry.size.width - 80)).padding()
        
        HStack(alignment: .top) {
            CText(text: nestedFraction ? "It's very easy to see the irrationality of this value as the denominator is an infinite Nested Fraction. While each additional denominator makes a smaller difference to the value, as the numerator is 1, it still makes a substantial alteration." : "The irrationality of this infinite Nested Square Root is also very clear. While each additional square root makes a smaller difference to the value, it still makes a substantial change to the value.", font: .title3, weight: .semibold)
                .padding()
            
            Spacer()
            //Aproximation Nested Fraction
            VStack {
                Text("No. of \(nestedFraction ? "Denominators" : "Square Roots"): \(no)")
                
                Text("ϕ Aproximation: \(previousValue.trailingsRemoved)")
                
                if no == 0 {
                    Button(action: {
                        playSound("Pop")
                        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
                            if no >= 20 { timer.invalidate(); Manager.player?.stop(); return; }
                            playSound("Snap")
                            previousValue = 1
                            no += 1
                            if nestedFraction {
                                Aproximation(denom: true)
                            } else {
                                Aproximation(denom: false)
                            }
                        }
                    }, label: {
                        OKButton(text: "Start ϕ Calculation")
                            .padding()
                    })
                    .scaleEffect(animating ? 1.15 : 1)
                    .padding(insets: [20,0,0,0])
                    .transition(.scale)
                }
                
                //MARK: NEEDED: ACTivity Indicator
            }.padding()
            
            LineGraph(data: nestedFraction ? parent.NestedFractiondata : parent.Squaresdata, maxXValue: CGFloat(min((nestedFraction ? parent.NestedFractiondata : parent.Squaresdata).count, 20)))
                .frame(width: 400, height: 300)
                .clipped()
            
            Spacer()
        }
        .onDisappear {
            no = 21
        }
    }
    
    private func Aproximation(denom: Bool) {
        for _ in 1...no {
            if denom {
                previousValue = 1 + (1/previousValue)
            } else {
                previousValue = sqrt(1 + previousValue)
            }
        }
        if denom {
            parent.NestedFractiondata.append(Point(x: CGFloat(no), y: CGFloat(previousValue)))
        } else {
            parent.Squaresdata.append(Point(x: CGFloat(no), y: CGFloat(previousValue)))
        }
    }
}
