//
//  GoldenRatioExtensions.swift
//  BookCore
//
//  Created by Niall Kehoe on 01/04/2021.
//

import SwiftUI

struct DiagramText: View {
    let text: String
    
    var body: some View {
        CText(text: text, font: .title2, weight: .bold, foregroundColor: .blue)
    }
}

struct SolutionText: View {
    let name: String
    let geometry: GeometryProxy
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        Spacer()
        CText(text: name, font: .title2, weight: .semibold, foregroundColor: equationColourModifier(colorScheme: colorScheme)).multilineTextAlignment(.center)
            .frame(width: geometry.size.height * 0.09 * 1044/238 * 1.1, height: geometry.size.height * 0.09)
            .padding(insets: [0,25,0,0])
            .background(Color.orange.opacity(0.3).cornerRadius(5))
        Spacer()
    }
}

/// Line Graph Class
struct LineGraph: View {
    let data: [Point]
    var maxXValue: CGFloat = 8                                  /// max X Value
    
    private static let widthOfCircle : CGFloat = 10             /// width of Dot
    private static let maxYValue: CGFloat = 2                   /// max Y Value
    private static let yStepsCount: Int = 10                    
    
    private var xStepsCount: Int { Int(self.maxXValue / 1) }
    
    var body: some View {
        HStack {
            VStack {
                ForEach(0...5, id: \.self) { number in
                    Text("\((1.5 + (Double(5-number)/10)).trailingsRemoved)")
                    if number != 8 {
                        Spacer()
                    }
                }
            }
            VStack {
                ZStack {
                    grid
                    chart
                    circle
                }
                HStack {
                    ForEach(0...Int(maxXValue), id: \.self) { number in
                        Text("\(number)").font(maxXValue < 12 ? .body: .footnote)
                            .animation(.none)
                        if number != Int(maxXValue) {
                            Spacer()
                        }
                    }
                }
            }
        }
    }
    
    private var grid: some View {
        GeometryReader { geometry in
            Path { path in
                let xStepWidth = geometry.size.width / CGFloat(self.xStepsCount)
                let yStepWidth = geometry.size.height / CGFloat(LineGraph.yStepsCount)

                // Y axis lines
                (1...LineGraph.yStepsCount+1).forEach { index in
                    let y = CGFloat(index) * yStepWidth
                    path.move(to: .init(x: 0, y: y - yStepWidth))
                    path.addLine(to: .init(x: geometry.size.width, y: y - yStepWidth))
                }

                // X axis lines
                (1...self.xStepsCount).forEach { index in
                    let x = CGFloat(index) * xStepWidth
                    path.move(to: .init(x: x, y: 0))
                    path.addLine(to: .init(x: x, y: geometry.size.height))
                }
            }.stroke(Color.gray)
        }
    }
    
    private var chart: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: .init(x: 0, y: geometry.size.height))
                var previousPoint = Point(x: 0, y: geometry.size.height)

                self.data.forEach { point in
                    let x = (point.x / self.maxXValue) * geometry.size.width
                    let y = geometry.size.height - ((point.y-1.5) / (LineGraph.maxYValue-1.5)) * geometry.size.height

                    let deltaX = x - previousPoint.x
                    let curveXOffset = deltaX * 1

                    path.addCurve(to: .init(x: x, y: y), control1: .init(x: previousPoint.x + curveXOffset, y: previousPoint.y), control2: .init(x: x - curveXOffset, y: y))
                    
                    
                    previousPoint = .init(x: x, y: y)
                }
            }
            .stroke(Color.black, style: StrokeStyle(lineWidth: 3))
        }
    }
    
    private var circle: some View {
        GeometryReader { geometry in
            ForEach(data, id: \.self) { point in
                let x = (point.x / self.maxXValue) * geometry.size.width
                let y = geometry.size.height - ((point.y-1.5) / (LineGraph.maxYValue-1.5)) * geometry.size.height

                Circle().strokeBorder(Color.black,lineWidth: 2)
                    .background(Circle().foregroundColor(Color.white))
                    .frame(width: LineGraph.widthOfCircle, height: LineGraph.widthOfCircle)
                    .animation(.none).offset(x: x - (LineGraph.widthOfCircle/2), y: y - (LineGraph.widthOfCircle/2))
            }
        }
    }
}
