//
//  Triangles.swift
//  BookCore
//
//  Created by Niall Kehoe on 30/03/2021.
//

import SwiftUI

/// Pentagon's Traingle View
struct TriangleofPentagon: View {
    var geometry: GeometryProxy
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Polygon(corners: 3, triangle: true)
            .stroke(Color.green,lineWidth: 4)
            .frame(width: geometry.size.height*0.97, height: geometry.size.height*0.97)
            .offset(y: geometry.size.height*0.97/2)
            .scaleEffect(x: 0.68, y: 0.54)
            
        Group {
            VStack(spacing: 0) {
                CText(text: "360°", font: .system(size: 6, design: .default), weight: .bold, foregroundColor: darkColourModifier(colorScheme: colorScheme))
                Line().stroke(darkColourModifier(colorScheme: colorScheme), lineWidth: 1)
                    .frame(height: 1)
                    .cornerRadius(1)
                CText(text: "n", font: .system(size: 9, design: .default), weight: .bold, foregroundColor: darkColourModifier(colorScheme: colorScheme))
            }.multilineTextAlignment(.center)
        }
        .frame(width: geometry.size.height*0.97*0.16, height: geometry.size.height*0.97*0.16*226/220)
        .offset(y: geometry.size.height*0.97*0.19)
    }
}
