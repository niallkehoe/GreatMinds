//
//  AproximationView.swift
//  BookCore
//
//  Created by Niall Kehoe on 30/03/2021.
//

import SwiftUI

/// Aproximation View
struct AproximationView: View {
    var n: Int                          /// number of vertices of polygon
    var colorScheme: ColorScheme
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                Text("π ≈ ")
                VStack(spacing: 0) {
                    Text("\(n)")
                    Line()
                        .stroke(Color.white,lineWidth: 1.5)
                        .frame(width: CGFloat(("\(n)".count))*12, height: 2)
                    Text("2")
                }.font(.headline)
                CText(text: " · sin(", font: .title, foregroundColor: .white)
                VStack(spacing: 0) {
                    CText(text: "360°", font: .body, weight: .semibold, foregroundColor: .white)
                    Line()
                        .stroke(Color.white,lineWidth: 1.5)
                        .frame(width: 40, height: 2)
                    Text("\(n)").font(.headline)
                }
                Text(")").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            }.foregroundColor(.white)
        }
    }
}
