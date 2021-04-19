//
//  PiExplanationHolder.swift
//  BookCore
//
//  Created by Niall Kehoe on 30/03/2021.
//
//

import SwiftUI

/// Pi Holder View
struct PiHolder: View {
    let colorScheme: ColorScheme
    
    var body: some View {
        GeometryReader { (geometry) in
            HStack {
                Spacer()
                
                PiSimulation(colorScheme: colorScheme)
                    .frame(width: geometry.size.width * 0.35)
                    .background(colorScheme == .dark ? #colorLiteral(red: 0.2119959295, green: 0.2193228304, blue: 0.2281849384, alpha: 0.7139836494).suColor: #colorLiteral(red: 0.2119959295, green: 0.2193228304, blue: 0.2281849384, alpha: 0.9147620801).suColor)
                    .cornerRadius(15)
                PiExplanation(geometry: geometry, colorScheme: colorScheme).frame(width: (geometry.size.width * 0.63))
                Spacer()
            }.frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
