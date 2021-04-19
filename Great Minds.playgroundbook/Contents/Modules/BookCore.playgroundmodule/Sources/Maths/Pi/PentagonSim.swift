//
//  PentagonSim.swift
//  BookCore
//
//  Created by Niall Kehoe on 30/03/2021.
//
//

import SwiftUI

/// Pentagon Example Sim
struct PentagonSim: View {
    
    let colorScheme: ColorScheme
    
    private static let coefficientOfPentagon : CGFloat = 0.97           /// decimal percentage of square
    
    @State private var TriangleOffset : Point = Point(x: 0, y: 0)       /// offset of Triangle Collection
    @State private var numberOfTriangles = 1                            /// number of Pentagon Triangles
    @State private var TriangleOffsetsx : [CGFloat] = [0,0,0,0,0]       /// x offset of Triangles
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ZStack {
                    Polygon(corners: 5, pentagon: true)
                        .stroke(Color.blue,lineWidth: 3)
                        .frame(width: geometry.size.height*PentagonSim.coefficientOfPentagon, height: geometry.size.height*PentagonSim.coefficientOfPentagon)
                        
                    CText(text: "1", font: Font.custom("GeezaPro-Bold", size: 15), weight: .bold, foregroundColor: .blue)
                        .offset(x: -10, y: -geometry.size.height*PentagonSim.coefficientOfPentagon/4)
                        
                    ZStack {
                        ForEach((0..<numberOfTriangles), id: \.self) { indx in
                            TriangleofPentagon(geometry: geometry).offset(x: TriangleOffsetsx[indx])
                        }
                    }
                    .offset(x: TriangleOffset.x, y: TriangleOffset.y)
                }.offset(x: (-1.9 * geometry.size.height*PentagonSim.coefficientOfPentagon))
                    
                VStack {
                    Spacer().frame(height: geometry.size.height*PentagonSim.coefficientOfPentagon/2)
                    HStack {
                        Spacer().frame(width: geometry.size.height*PentagonSim.coefficientOfPentagon + 12)
                                
                        CImageColoured(name: "trianglearea", size: CGSize(width: (geometry.size.width - (geometry.size.height*PentagonSim.coefficientOfPentagon))*0.45, height: (geometry.size.width - (geometry.size.height*PentagonSim.coefficientOfPentagon))*0.45*257/1327), col: darkColourModifier(colorScheme: colorScheme))
                                
                        Spacer()
                                
                        CImageColoured(name: "pentagonarea", size: CGSize(width: (geometry.size.width - (geometry.size.height*PentagonSim.coefficientOfPentagon))*0.45, height: (geometry.size.width - (geometry.size.height*PentagonSim.coefficientOfPentagon))*0.45*257/1349), col: darkColourModifier(colorScheme: colorScheme))
                                
                        Spacer()
                    }
                }
            }
            .onAppear {
                NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "isFullScreen"), object: nil, queue: nil) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeInOut(duration: 1.5)) {
                            TriangleOffset.x = geometry.size.height*PentagonSim.coefficientOfPentagon
                            TriangleOffset.y = -geometry.size.height/2
                        }
                    }
                            
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { (timer) in
                            if numberOfTriangles == 4 {
                                timer.invalidate()
                            }
                            withAnimation(Animation.easeInOut(duration: 0.5)) {
                                numberOfTriangles += 1
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.easeInOut(duration: 1)) {
                                    TriangleOffsetsx[numberOfTriangles-1] = CGFloat(numberOfTriangles-1) * geometry.size.height * PentagonSim.coefficientOfPentagon * CGFloat(sin(degrees: 36))
                                }
                            }
                                
                        }
                    }
                }
            }
        }
    }
}

