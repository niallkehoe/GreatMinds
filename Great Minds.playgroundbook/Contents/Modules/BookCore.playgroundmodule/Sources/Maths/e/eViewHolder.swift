//
//  eViewHolder.swift
//  BookCore
//
//  Created by Niall Kehoe on 31/03/2021.
//

import SwiftUI

/// e Solutions Carousel
fileprivate struct eSolutionsPicker: View {
    @Binding var selection: Int              /// selection of e Option
    let colorScheme: ColorScheme
    let geometry: GeometryProxy
    
    var body: some View {
        VStack {
            Carousel(carouselLocation: $selection, width: geometry.size.width/6.5,itemHeight: geometry.size.width/6.5*0.5, views: [
                AnyView(MenuItem(indx: 1, colorScheme: colorScheme)),
                AnyView(CalculusIcon()),
                AnyView(MenuItem(indx: 2, colorScheme: colorScheme)),
                ]).frame(width: geometry.size.width - 20, height: (geometry.size.width-20)/6.5*0.5)
        }.frame(height: (geometry.size.width-20)/6.5*0.5*1.15)
    }
}

/// e Holder View
struct eViewHolder: View {
    let colorScheme: ColorScheme
    @State private var selection: Int = 0    /// selection of e Option
    var body: some View {
        GeometryReader { geometry in
            VStack {
                eSolutionsPicker(selection: $selection, colorScheme: colorScheme, geometry: geometry)
                    .padding(insets: [-15,10,0,-10])
                Group {
                    if selection % 3 == 0 {
                        eView(colorScheme: colorScheme)
                    } else if abs(selection % 3) == (selection % 3 < 0 ? 2:1) {
                        Calculuse(colorScheme: colorScheme)
                    } else if abs(selection % 3) == (selection % 3 < 0 ? 1:2) {
                        eViewCompound(colorScheme: colorScheme)
                    }
                }.frame(width: geometry.size.width-20, height: geometry.size.height)
            }
        }
    }
}

fileprivate struct MenuItem: View {
    var indx: Int                       /// index of image
    let colorScheme: ColorScheme
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer().frame(height: 5)
                
                CImageColoured(name: "eformula\(indx)", size: CGSize(width: geometry.size.width, height: geometry.size.width*227/773), col: [#colorLiteral(red: 0, green: 0.481585443, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.08589003235, blue: 0.2781683207, alpha: 1), #colorLiteral(red: 0, green: 0.8321763873, blue: 0.4148214161, alpha: 1)][indx].suColor)
                
                CText(text: indx == 1 ? "Factorial": "Interest", font: .title3, weight: .bold)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(darkColourModifier(colorScheme: colorScheme))
        }
    }
}
fileprivate struct CalculusIcon: View {
    var body: some View {
        GeometryReader { geometry in
            CImage(name: "eformula3", size: CGSize(width: geometry.size.height, height: geometry.size.height))
        }
    }
}

/// e Calculus  Calculation View
fileprivate struct Calculuse: View {
    @State private var showArea = false         /// show slanted shaded background
    let colorScheme: ColorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    HStack(alignment: .top) {
                        VStack {
                            LinearGradient(gradient: Gradient(colors: [#colorLiteral(red: 1, green: 0.02420676313, blue: 0.3114617169, alpha: 1).suColor, #colorLiteral(red: 0, green: 0.613132596, blue: 1, alpha: 1).suColor]), startPoint: .leading, endPoint: .trailing)
                                .mask(
                                    VStack {
                                        CText(text: "Calculus", font: .largeTitle, weight: .heavy)
                                            .padding()
                                        
                                        CText(text: "e is the only number where the slope of eˣ is equal to the value of eˣ at every given point. \n\n It is also the only number where the area under the curve of eˣ is equal to the value of eˣ.", font: .callout, weight: .bold)
                                                .padding()
                                    }
                                )
                                .frame(height: geometry.size.width*0.42*1404/1715*0.7)
                            
                            CImageColoured(name: "ecalc", size: CGSize(width: geometry.size.width*0.35, height: geometry.size.width*0.35*260/1300), col: lightColourModifier(colorScheme: colorScheme))
                            Spacer()
                        }.frame(width: geometry.size.width*0.57, height: geometry.size.width*0.42*1404/1715)
                        
                        ZStack {
                            CImage(name: "underlay", size: CGSize(width: geometry.size.width*0.42*0.75, height: geometry.size.width*0.42*0.75))
                                .offset(x: -geometry.size.width*0.42*0.125)
                                .opacity(showArea ? 1:0)
                            
                            Image("etox").resizable().frame(width: geometry.size.width*0.42, height: geometry.size.width*0.42*1404/1715).padding(insets: [0,0,0,0]).cornerRadius(20)
                        }
                        .padding(insets: [0,0,0,-10])
                        .frame(width: geometry.size.width*0.42, height: geometry.size.width*0.42*1404/1715)
                    }
                    
                    CText(text: "eˣ @ x=1", font: .system(.title, design: .rounded))
                    
                    Group {
                        CImageColoured(name: "ecalc2", size: CGSize(width: geometry.size.width*0.8, height: geometry.size.width*0.8*255/2236), col: Color.white)
                    }
                    .frame(width: geometry.size.width*0.85, height: geometry.size.width*0.85*255/2236)
                    .background(RoundedRectangle(cornerRadius: 20).fill(LinearGradient(gradient: Gradient(colors: [#colorLiteral(red: 0, green: 0.5134851336, blue: 0.9067854285, alpha: 0.8987921911).suColor, #colorLiteral(red: 0, green: 0.9603566527, blue: 0.4399383366, alpha: 1).suColor]), startPoint: .leading, endPoint: .trailing)))
                }.onAppear {
                    withAnimation(Animation.easeInOut(duration: 1).delay(1).repeatForever(autoreverses: true)) {
                        self.showArea.toggle()
                    }
                }
            }
        }
    }
}

fileprivate enum DragState {
    case inactive
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
}

/// Carousel View
fileprivate struct Carousel: View {
    
    @GestureState private var dragState = DragState.inactive
    @Binding var carouselLocation : Int                             /// Carousel Index
    
    var width: CGFloat
    var itemHeight: CGFloat
    var views: [AnyView]
    
    private func onDragEnded(drag: DragGesture.Value) {
        if drag.predictedEndTranslation.width > 175 || drag.translation.width > 175 {
            carouselLocation =  carouselLocation - 1
        } else if (drag.predictedEndTranslation.width) < -175 || (drag.translation.width) < -175 {
            carouselLocation =  carouselLocation + 1
        }
    }
    
    var body: some View {
        VStack{
            ZStack{
                ForEach(0..<views.count){ i in
                    VStack{
                        Spacer()
                        self.views[i].frame(width: i == 1 ? itemHeight*1.05: (width * (i == relativeLoc() ? 1: 0.9)), height: i == 1 ? itemHeight*1.05: (i == relativeLoc() ? 1:0.9)*itemHeight)
                            .animation(.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0))
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .offset(x: self.getOffset(i))
                            .animation(.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0))
                            .onTapGesture {
                                carouselLocation = i
                            }
                        Spacer()
                    }
                }
            }
            .gesture(
                DragGesture()
                    .updating($dragState) { drag, state, transaction in
                        state = .dragging(translation: drag.translation)
                    }
                    .onEnded(onDragEnded)
            )
            .onChange(of: carouselLocation, perform: { value in
                playSound("Slide")
            })
            
            Spacer()
        }
    }
    
    private func relativeLoc() -> Int {
        return ((views.count * 10000) + carouselLocation) % views.count
    }
    
    private func getOffset(_ i:Int) -> CGFloat {
        if (i) == relativeLoc()  {
            return self.dragState.translation.width
        } else if (i) == relativeLoc() + 1 || (relativeLoc() == views.count - 1 && i == 0) {
            return self.dragState.translation.width + (300 + 20)
        } else if (i) == relativeLoc() - 1 || (relativeLoc() == 0 && (i) == views.count - 1) {
            return self.dragState.translation.width - (300 + 20)
        } else {
            return 100
        }
    }
}
