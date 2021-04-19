//
//  eViewCompound.swift
//  BookCore
//
//  Created by Niall Kehoe on 31/03/2021.
//

import SwiftUI

/// e Compound Interest Calculation View
struct eViewCompound: View {
    let colorScheme: ColorScheme
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .center) {
                    LinearGradient(gradient: Gradient(colors: [#colorLiteral(red: 1, green: 0.02420676313, blue: 0.3114617169, alpha: 1).suColor, #colorLiteral(red: 0, green: 0.613132596, blue: 1, alpha: 1).suColor]), startPoint: .leading, endPoint: .trailing)
                        .mask(
                            CText(text: "Jacob Bernoulli examined what would happen if a loan of $1 with a 100% interest rate / year, was increasingly credited, meaning the loan's collection period was progressively shortened.", font: .system(size: 20, design: .rounded), weight: .semibold).padding(insets: [0,10,0,5])
                    ).frame(height: 80)
                    
                    LinearGradient(gradient: Gradient(colors: [#colorLiteral(red: 0, green: 0.613132596, blue: 1, alpha: 1).suColor, #colorLiteral(red: 0, green: 1, blue: 0.5059723854, alpha: 1).suColor]), startPoint: .leading, endPoint: .trailing)
                        .mask(
                            CText(text: "The total amount paid can be modelled by the equation:", font: .system(size: 20, design: .rounded), weight: .semibold).padding(insets: [0,10,0,5])
                        ).frame(height: 40)
                    
                    CImageColoured(name: "financialmaths", size: CGSize(width: 65*1573/266, height: 65), col: lightColourModifier(colorScheme: colorScheme))
                    
                    CImage(name: "ecompound", size: CGSize(width: geometry.size.width*0.9, height: geometry.size.width*0.9*1593/2560))
                    
                    CText(text: "The effect of earning 20% annual interest on an initial investment at various compounding frequencies.", font: .system(size: 18, design: .rounded), weight: .light).padding(insets: [0,10,0,5])
                        .frame(width: geometry.size.width*0.86, height: 60)
                    
                    HStack(alignment: .top) {
                        CImageColoured(name: "ecompoundtable", size: CGSize(width: geometry.size.width*0.4, height: geometry.size.width*0.4*836/1346), col: lightColourModifier(colorScheme: colorScheme))
                        
                        CText(text: "Here the 1/n represents the 100% annual rate divided by the number of collections per year.", font: .system(size: 22, design: .rounded), weight: .semibold).frame(width: geometry.size.width*0.4).padding(5)
                    }
                }
            }
        }
        
    }
}
