//
//  eView.swift
//  BookCore
//
//  Created by Niall Kehoe on 31/03/2021.
//

import SwiftUI

/// e Factorial View
struct eView: View {
    let colorScheme: ColorScheme

    private static let colorGradient = [#colorLiteral(red: 1, green: 0.02096056566, blue: 0.2765471637, alpha: 1), #colorLiteral(red: 0.2361083627, green: 0.6610188484, blue: 0.9785813689, alpha: 1), #colorLiteral(red: 0.1816139221, green: 0.7918078303, blue: 0.7684832215, alpha: 1), #colorLiteral(red: 0.1835989952, green: 0.8826959729, blue: 0.5833058357, alpha: 1), #colorLiteral(red: 0.9840231538, green: 0.7870325446, blue: 0.4575131536, alpha: 1)]                                     /// colours of boxes
    private static let fonts : [Font] = [.title, .title, .title, .headline, .body]              /// fonts of box labels
    fileprivate static let facanswers = ["1" , "¹/₂", "¹/₆", "¹/₂₄", "¹/₁₂₀"]                   /// factorial texts

    @State private var cornerRadiuses : [CGFloat] = [10, 10, 7, 5, 3]                           /// cornerRadiuses of boxes
    @State private var positions : [CGFloat] = [0, 0, 0, 0, 0]                                  /// x Position of box labels
    @State private var widthOfDemonstration : CGFloat = UIScreen.screenWidth * 0.3              /// width of boxes
    @State private var heightOfDemonstration : CGFloat = 100                                    /// height of boxes

    @State private var offsetarry : [CGFloat] = [0, 100, 200, 300, 400]                         /// y offset of boxes
    @State private var offsetarrx : [CGFloat] = [0, 0, 0, 0, 0]                                 /// x offset of boxes

    @State private var firstoffset : Point = Point(x: 0, y: 0)                                  /// offsets of First Box
    @State private var eCalculation : Double = 0                                                /// Aproximation of e
    @State private var mathIndex = 0                                                            /// index of math Sum View
    @State private var additionanimationoffset : [CGFloat] = [0, 0, 0, 0, 0, 0, 0, 0]           /// x offsets of sliding marker

    /// Public Variables
    @State fileprivate var rotation3DValue: Double = 7                                          /// 3D rotation Effect
    @State fileprivate var btnRotation = 0.0                                                    ///  btn Rotation
    @State fileprivate var stage = 0
    
    fileprivate let timer = Timer.publish(every: 4.5, on: .main, in: .common).autoconnect()     /// rotational Timer

    var body: some View {
        GeometryReader { (geometry) in
            VStack {
                HStack {
                    if stage == 2 {
                        Spacer().frame(width: 40)
                    }
                    ZStack {
                        ForEach((0..<5), id: \.self) { indx in
                            CRectangle(cornerRadius: cornerRadiuses[indx], foregroundColor: eView.colorGradient[indx].suColor).frame(width: widthOfDemonstration, height: heightOfDemonstration*(1/CGFloat((Int(indx+1).factorial))))
                                .opacity(0.85)
                                .offset(x: offsetarrx[indx] + CGFloat((stage == 0 ? indx: 0) * 20), y: offsetarry[indx])
                        }
                        ForEach((0..<5), id: \.self) { indx in
                            CText(text: stage == 2 ? "\(eView.facanswers[indx])":"1/\(indx+1)!", font: eView.fonts[indx], weight: .semibold, foregroundColor: .white)
                                .offset(x: offsetarrx[indx] + CGFloat((stage == 0 ? indx: 0) * 20), y: positions[indx])
                        }

                        CRectangle(foregroundColor: eView.colorGradient[0].suColor).frame(width: widthOfDemonstration, height: heightOfDemonstration)
                            .opacity(stage == 2 ? 0.85 : 0.0)
                            .offset(x: firstoffset.x, y: firstoffset.y)
                            .transition(.slide)
                            
                        CText(text: "1", font: eView.fonts[0], weight: .semibold, foregroundColor: .white)
                            .opacity(stage == 2 ? 1 : 0.0)
                            .offset(x: firstoffset.x,y: positions[0])
                    }
                    .rotation3DEffect(Angle(degrees: rotation3DValue), axis: (x: 0, y: 1, z: 0.0))
                    if stage == 2 {
                        Spacer().frame(width: widthOfDemonstration/2)
                    }
                }.frame(height: stage == 2 ? heightOfDemonstration*(103/60): heightOfDemonstration)

                Spacer().frame(height: 20)
                Group {
                    if stage == 1 {
                        HStack {
                            Spacer()
                            ForEach((0..<5), id: \.self) { indx in
                                Group {
                                    CImageColoured(name: "math\(indx+1)", size: CGSize(width: widthOfDemonstration * 0.25, height: widthOfDemonstration * 0.25*199/94), col: equationColourModifier(colorScheme: colorScheme))
                                        .padding(0)

                                    if indx != 4 {
                                        CText(text: "+", font: .largeTitle, weight: .bold, foregroundColor: equationColourModifier(colorScheme: colorScheme))
                                            .frame(width: widthOfDemonstration * 0.25, height: widthOfDemonstration * 0.25)
                                            .padding(insets: [0,(widthOfDemonstration*0.25),0,(widthOfDemonstration*0.25)])
                                    }
                                }
                            }
                            Spacer()
                        }
                    } else if stage == 2 {
                        MathSumView(widthOfDemonstration: widthOfDemonstration, geometry: geometry, additionanimationoffset: additionanimationoffset, count: mathIndex)
                        HStack {
                            CImageColoured(name: "eformula", size: CGSize(width: 90*597/201, height: 90), col: equationColourModifier(colorScheme: colorScheme))
                                .transition(.slide)

                            Spacer().frame(width: 20)
                                
                            CText(text: mathIndex == 0 ? "" : "\(eCalculation.trailingsRemoved)", font: Font.system(size: 35.0), weight: .semibold, foregroundColor: equationColourModifier(colorScheme: colorScheme))
                                .frame(width: 220, alignment: .leading)
                                .clipped()
                        }
                    }
                    TransformBtn(parent: self, geometry: geometry).opacity(stage == 2 ? 0:1)
                }
            }.onAppear {
                heightOfDemonstration = geometry.size.height - 150
                
                let mappings : [CGFloat] = [-0.25,0.166,0.4,0.48,0.495]
                for i in 0...4 {
                    offsetarry[i] = heightOfDemonstration * (1 - (1/CGFloat((i+1).factorial))) / 2
                    positions[i] = heightOfDemonstration * mappings[i]
                }
                
                withAnimation(.easeInOut(duration: 4.5)) {
                    rotation3DValue = -7
                }
            }
        }
        .onReceive(timer) { time in
            withAnimation(.easeInOut(duration: 4.5)) {
                rotation3DValue = rotation3DValue == 7 ? -7 : 7
            }
        }
    }

    /// Seperate Objects (Step 1)
    /// - Parameter geometry: GeometryProxy of View
    fileprivate func seperateObjects(_ geometry: GeometryProxy) {
        withAnimation(.easeInOut) {
            widthOfDemonstration = (geometry.size.width / 5) - 48
            heightOfDemonstration = (7/4) * widthOfDemonstration
            
            let ymapping : [CGFloat] = [0, 0.25, 5/12, 23/48, 119/240]
            for i in -2...2 {
                offsetarrx[i+2] = (widthOfDemonstration*CGFloat(i)) + CGFloat(i*8)
                offsetarry[i+2] = heightOfDemonstration * ymapping[i+2]
            }

            positions = [0, heightOfDemonstration / 4, heightOfDemonstration * 5 / 12, heightOfDemonstration * 23 / 48, heightOfDemonstration * 119 / 240]

            withAnimation(.easeInOut(duration: 2.5)) {
                btnRotation = 360
            }
        }
    }
    
    /// Addition Scene (Step 2)
    /// - Parameter geometry: GeometryProxy of View
    fileprivate func addition(_ geometry: GeometryProxy) {
        withAnimation(.easeInOut) {
            heightOfDemonstration = (geometry.size.height * 0.25)
            widthOfDemonstration = (0.9259259259) * heightOfDemonstration

            firstoffset.x = 5 - (widthOfDemonstration / 2)

            let mappings : [CGFloat] = [-0.25,0.5,0.8333,0.9375,0.9625]
            for i in 0...4 {
                offsetarrx[i] = 5 + (widthOfDemonstration/2)
                offsetarry[i] = heightOfDemonstration * mappings[i]
                positions[i] = heightOfDemonstration * mappings[i]
                cornerRadiuses[i] = 0
            }
            firstoffset.y = -(heightOfDemonstration*0.25)

            additionanimationoffset[0] = -(geometry.size.width*1.2)
            let widthOfNumber = widthOfDemonstration * 0.45
            let widthOfAddition = widthOfDemonstration * 0.15
            let spacing = (geometry.size.width - (widthOfNumber*7) - (widthOfAddition*6)) / 14
            for i in -3...3 {
                additionanimationoffset[i+4] = (spacing*2*CGFloat(i))+(widthOfAddition*CGFloat(i))+(widthOfNumber*CGFloat(i))
            }

        }
        withAnimation(.easeInOut(duration: 2.5)) {
            btnRotation = 720
        }

        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { (timer) in
            if mathIndex < 8 { playSound("Snap") }
            withAnimation(.easeInOut(duration: 1)) {
                if mathIndex < 9 {
                    eCalculation += mathIndex == 0 ? 1 : (1/Double(mathIndex.factorial))
                } else {
                    timer.invalidate()
                }
                mathIndex += 1
            }
        }
    }
}

fileprivate struct MathSumView: View {
    var widthOfDemonstration: CGFloat
    var geometry: GeometryProxy
    var additionanimationoffset : [CGFloat]
    var count : Int

    var body: some View {
        VStack {
            HStack {
                Spacer()
                ForEach((0..<7), id: \.self) { indx in
                    CText(text: indx == 0 ? "1" : indx == 6 ? "..." : "\(eView.facanswers[indx-1])", font: Font.system(size: 35.0), weight: .medium).frame(width: widthOfDemonstration * 0.45, height: widthOfDemonstration * 0.45*1.1)
                    Spacer()
                    if indx != 6 {
                        CText(text: "+", font: .title, weight: .bold).frame(width: widthOfDemonstration * 0.15, height: widthOfDemonstration * 0.15)
                        Spacer()
                    }
                }
            }
            CRectangle(cornerRadius: 8, foregroundColor: #colorLiteral(red: 1, green: 0.209497124, blue: 0.3611853123, alpha: 1).suColor).frame(width: 20, height: 4)
                .offset(x: count == 0 ? (-geometry.size.width*0.7): count < 8 ? additionanimationoffset[count]: geometry.size.width*1.2, y: -35)
                
        }.transition(.slide)
    }
}

/// Next Step Button
fileprivate struct TransformBtn: View {
    let parent: eView
    let geometry: GeometryProxy

    var body: some View {
        HStack {
            Spacer()
            ZStack {
                LinearGradient(gradient: Gradient(colors: [#colorLiteral(red: 1, green: 0.02420676313, blue: 0.3114617169, alpha: 1).suColor, #colorLiteral(red: 0.2545037866, green: 0.525233984, blue: 1, alpha: 1).suColor]), startPoint: .leading, endPoint: .trailing)
                    .mask(Image("loop")
                    .resizable()
                    .padding()
                    .aspectRatio(contentMode: .fit))
                    .background(
                        ZStack {
                            Circle().fill(LinearGradient(gradient: Gradient(colors: [Color.red, Color.green, Color.blue]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)).frame(width: 110, height: 110)

                            Circle().foregroundColor(Color.white).frame(width: 97, height: 97)
                    })
            }
            .frame(width: 100, height: 100)
            .onTapGesture {
                playSound("Whoosh")
                if parent.stage == 0 {
                    parent.timer.upstream.connect().cancel()
                    withAnimation(.easeIn(duration: 1.2)) {
                        parent.rotation3DValue = 0
                        parent.seperateObjects(geometry)
                    }
                } else if parent.stage == 1 {
                    parent.addition(geometry)
                }
                
                withAnimation() {
                    parent.stage += 1
                }
            }
            .rotationEffect(.degrees(parent.btnRotation))

            Spacer()
        }
    }
}
