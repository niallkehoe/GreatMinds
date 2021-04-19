//
//  PiExtensions.swift
//  Mathematical Constants
//
//  Created by Niall Kehoe
//

import SwiftUI

/// Circle Design View
struct CircleDesign: View {
    var sizeOfCircles: CGFloat          /// size of circles
    var circleRotation: Double          /// rotation of circle
    var showDot: Bool                   /// should circle Dot be Shown
    var showUnderLabel: Bool = true     /// should bottom label be shown
    
    var body: some View {
        ZStack {
            Circle().foregroundColor(#colorLiteral(red: 1, green: 0, blue: 0.3930231929, alpha: 1).suColor)
                .frame(width: sizeOfCircles, height: sizeOfCircles)
            if showDot == true {
                Circle().foregroundColor(Color.green)
                    .frame(width: sizeOfCircles/20, height: sizeOfCircles/20)
                    .offset(y: -sizeOfCircles*0.475)
                    .transition(.scale)
            }
            Diameter_Text()
            
            if showUnderLabel {
                Diameter_Text().rotationEffect(.degrees(180))
            }
            
            Group {
                Line().stroke(Color.black,lineWidth: 3)
                    .transition(.scale)
            }.frame(width: sizeOfCircles, height: sizeOfCircles)
        }
        .rotationEffect(.degrees(circleRotation))
    }
}

fileprivate struct Diameter_Text: View {
    var body: some View {
        CText(text: "diameter", font: .headline, weight: .semibold,foregroundColor: .black).offset(y: -13)
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.size.height/2))
        path.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height/2))
        return path
    }
}

/// HemiSphere Custom Shape
struct HemiSphere: Shape {
    
    var degrees: Double                                        /// Degrees between vertices
    let isTop: Bool                                            ///  Top Circle / Bottom Circle Choice
    var noOfSides: Int                                         /// number of Sides of Entire Circle
    
    private static let adjustment : Double = 1.9               /// custom Adjusment
    
    var animatableData: Double {
        get { degrees }
        set { degrees = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        let thetaangle = 360 / Double(noOfSides)
        let sideLengths = sin(degrees: (thetaangle / 2)) * Double(rect.size.height)
        
        let m = degrees * HemiSphere.adjustment
        
        var path = Path()
        
        let pt = CGPoint(x: rect.size.width / 2, y: (isTop ? 0: rect.size.height))
        
        performSides(path: &path, sides: noOfSides, m: m, sideLengths: sideLengths, pt: pt)
        performSides(path: &path, sides: noOfSides, m: m, sideLengths: sideLengths, sidePrecursor: -1, pt: pt)
        
        return path
    }
    
    /**
     Draw a quarter-sphere
     - Parameter path: path of shape
     - Parameter sides: number of vertices of entire circle
     - Parameter m: adjustment
     - Parameter sideLengths: adjustment
     - Parameter sidePrecursor: adjustment
     - Parameter pt: origin of hemisphere
     */
    private func performSides(path: inout Path, sides: Int, m: Double, sideLengths: Double, sidePrecursor: CGFloat = 1, pt: CGPoint) {
        var xvalue : CGFloat = 0
        var yvalue : CGFloat = 0
        
        for i in 0...Int(sides/4) {
            if i == 0 {
                path.move(to: pt)
            } else {
                xvalue -= sidePrecursor*(CGFloat(cos(degrees : (Double(i)*m))) * CGFloat(sideLengths))
                yvalue += (isTop ? 1 : -1) * (CGFloat(sin(degrees: (Double(i)*m))) * CGFloat(sideLengths))
                
                path.addLine(to: CGPoint(x: pt.x+xvalue, y: pt.y+yvalue))
            }
        }
    }
}

/// Polygon Drawn with x number of sides
struct Polygon: InsettableShape {
    var corners: Int
    var pentagon: Bool = false
    var triangle: Bool = false

    var animatableData: CGFloat {
        get { CGFloat(corners) }
        set { self.corners = Int(newValue) }
    }

    func path(in rect: CGRect) -> Path {
        guard corners >= 2 else { return Path() }
        
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        var currentAngle = -CGFloat.pi / 2
        let angleAdjustment = .pi * 2 / CGFloat(corners)
        
        var path = Path()

        path.move(to: CGPoint(x: center.x * cos(currentAngle), y: center.y * sin(currentAngle)))

        var bottomEdge: CGFloat = 0
        var vertex: [CGPoint] = []

        for _ in 0...corners {
            let cosAngle = cos(currentAngle)
            let bottom: CGFloat = center.y * sin(currentAngle)

            path.addLine(to: CGPoint(x: center.x * cosAngle, y: bottom))
            vertex.append(CGPoint(x: center.x * cosAngle, y: bottom))
            if bottom > bottomEdge {
                bottomEdge = bottom
            }

            currentAngle += angleAdjustment
        }

        var unusedSpace = (rect.height / 2 - bottomEdge) / 2
        if corners % 2 != 0 { unusedSpace = 0 }
        
        /// One class handles a number of uses -> extra  functionality needed
        if pentagon {
            for i in 0...4 {
                path.move(to: vertex[i])
                path.addLine(to: CGPoint(x: 0, y: 0))
            }
        }
        if triangle {
            path.move(to: CGPoint(x: 0, y: -rect.size.width/2))
            path.addArc(center: CGPoint(x: 0, y: -rect.size.width*0.48), radius: rect.size.width*0.48, startAngle: Angle(degrees: 59), endAngle: Angle(degrees: 121), clockwise: false)
            
            path.closeSubpath()
        }
        
        let transform = CGAffineTransform(translationX: center.x, y: center.y + unusedSpace)
        return path.applying(transform)
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        return self
    }
}
