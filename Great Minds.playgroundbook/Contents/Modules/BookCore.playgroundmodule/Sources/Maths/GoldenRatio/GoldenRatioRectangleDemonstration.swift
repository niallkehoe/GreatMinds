//
//  GoldenRatioRectangleDemonstration.swift
//  BookCore
//
//  Created by Niall Kehoe on 01/04/2021.
//

import SwiftUI

/// Golden Ratio Rectangle Animated View
struct GoldenRatioRectangleDemonstration: View {
    
    static fileprivate let numberOfStops : CGFloat = 20
    
    @State private var state : Int = 0
    
    @State private var boxwidth: CGFloat = 0
    @State private var boxheight: CGFloat = 0
    @State private var squareSideLength: CGFloat = 0
    @State private var smallLength: CGFloat = 0
    
    var body: some View {
        GeometryReader { (geometry) in
            ZStack {
                RatioRectangleDiagram(geometryWidth: Double(geometry.size.width), state: state)
                    .stroke(Color.blue, lineWidth: 5)
                    .layoutPriority(1)
                    .frame(width: geometry.size.width, height: (geometry.size.width - 20) * (1/1.6180339887))
                
                ZStack(alignment: .topLeading) {
                    if state > Int(GoldenRatioRectangleDemonstration.numberOfStops * 2)  {
                        DiagramText(text: "a")
                            .offset(x: -14 - (boxwidth/2))
                        DiagramText(text: "a")
                            .offset(x: (squareSideLength/2) - (boxwidth/2), y: -12 - boxheight/2)
                        DiagramText(text: "a")
                            .offset(x: -14 + squareSideLength - (boxwidth/2))
                    }
                    if state > Int(GoldenRatioRectangleDemonstration.numberOfStops  * 2.6) {
                        DiagramText(text: "b")
                            .offset(x: squareSideLength + (smallLength/2) - (boxwidth/2), y: -12 - boxheight/2)
                    }
                }.frame(width: geometry.size.width, height: (geometry.size.width - 20) * (1/1.6180339887))
            }
            .frame(width: geometry.size.width - 20, height: (geometry.size.width - 20) * (1/1.6180339887))
            .background(Color.green.opacity(0.2))
            .padding(insets: [20,20,0,0])
            .onAppear {
                boxwidth = geometry.size.width - 40
                boxheight = boxwidth * (1/1.6180339887)
                squareSideLength = boxwidth / CGFloat(1.6180339887)
                
                smallLength = boxwidth - squareSideLength
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    runTimer(with: GoldenRatioRectangleDemonstration.numberOfStops)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.3) {
                    runTimer(with: (GoldenRatioRectangleDemonstration.numberOfStops*2))
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 7.6) {
                    runTimer(with: (GoldenRatioRectangleDemonstration.numberOfStops*2.6))
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 9.4) {
                    runTimer(with: (GoldenRatioRectangleDemonstration.numberOfStops*3.1))
                }
            }
        }
    }
    
    private func runTimer(with limit: CGFloat) {
        Timer.scheduledTimer(withTimeInterval: (3/Double(GoldenRatioRectangleDemonstration.numberOfStops)), repeats: true) { (timer) in
            if state >= Int(limit) {
                timer.invalidate()
            }
            state += 1
        }
    }
}

fileprivate struct RatioRectangleDiagram: Shape {
    var geometryWidth: Double
    var state: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let pt = CGPoint(x: 20, y: 10)
        
        let boxwidth = CGFloat(geometryWidth) - (pt.x*2)
        let squareSideLength = boxwidth / CGFloat(1.6180339887)
        
        let smallLength = boxwidth - squareSideLength
        
        if state >= 1 {
            path.move(to: pt)
            path.addLine(to: CGPoint(x: pt.x + (squareSideLength * min(CGFloat(state),GoldenRatioRectangleDemonstration.numberOfStops) / GoldenRatioRectangleDemonstration.numberOfStops), y: pt.y))

            path.move(to: pt)
            path.addLine(to: CGPoint(x: pt.x, y: pt.y + (squareSideLength * min(CGFloat(state),GoldenRatioRectangleDemonstration.numberOfStops) / GoldenRatioRectangleDemonstration.numberOfStops)))
        }
        if state >= Int(GoldenRatioRectangleDemonstration.numberOfStops) {
            path.move(to: CGPoint(x: pt.x + squareSideLength, y: pt.y))
            path.addLine(to: CGPoint(x: pt.x + squareSideLength, y: pt.y + (squareSideLength * min(CGFloat(state)-GoldenRatioRectangleDemonstration.numberOfStops,GoldenRatioRectangleDemonstration.numberOfStops) / GoldenRatioRectangleDemonstration.numberOfStops)))
            path.move(to: CGPoint(x: pt.x, y: pt.y + squareSideLength))
            path.addLine(to: CGPoint(x: pt.x + (squareSideLength * min(CGFloat(state)-GoldenRatioRectangleDemonstration.numberOfStops,GoldenRatioRectangleDemonstration.numberOfStops) / GoldenRatioRectangleDemonstration.numberOfStops), y: pt.y + squareSideLength))
        }
        if state >= Int(GoldenRatioRectangleDemonstration.numberOfStops) * 2 {
            path.move(to: CGPoint(x: pt.x + squareSideLength, y: pt.y))
            path.addLine(to: CGPoint(x: pt.x + squareSideLength + (smallLength * min(CGFloat(state)-(GoldenRatioRectangleDemonstration.numberOfStops * 2),(6/10*GoldenRatioRectangleDemonstration.numberOfStops)) / (6/10*GoldenRatioRectangleDemonstration.numberOfStops)), y: pt.y))
            
            path.move(to: CGPoint(x: pt.x + squareSideLength, y: pt.y + squareSideLength))
            path.addLine(to: CGPoint(x: pt.x + squareSideLength + (smallLength * min(CGFloat(state)-(GoldenRatioRectangleDemonstration.numberOfStops * 2),(6/10*GoldenRatioRectangleDemonstration.numberOfStops)) / (6/10*GoldenRatioRectangleDemonstration.numberOfStops)), y: pt.y + squareSideLength))
        }
        if state >= Int(GoldenRatioRectangleDemonstration.numberOfStops * 2.6)  {
            path.move(to: CGPoint(x: pt.x + squareSideLength + smallLength, y: pt.y))
            path.addLine(to: CGPoint(x: pt.x + squareSideLength + smallLength, y: pt.y + (squareSideLength/2 * min(CGFloat(state)-(GoldenRatioRectangleDemonstration.numberOfStops * 2.6), (GoldenRatioRectangleDemonstration.numberOfStops/2)) / (GoldenRatioRectangleDemonstration.numberOfStops/2))))
            
            path.move(to: CGPoint(x: pt.x + squareSideLength + smallLength, y: pt.y + squareSideLength))
            path.addLine(to: CGPoint(x: pt.x + squareSideLength + smallLength, y: pt.y + (squareSideLength - (squareSideLength/2 * min(CGFloat(state)-(GoldenRatioRectangleDemonstration.numberOfStops * 2.6), (GoldenRatioRectangleDemonstration.numberOfStops/2)) / (GoldenRatioRectangleDemonstration.numberOfStops/2)))))
        }
        
        return path
    }
    
}
