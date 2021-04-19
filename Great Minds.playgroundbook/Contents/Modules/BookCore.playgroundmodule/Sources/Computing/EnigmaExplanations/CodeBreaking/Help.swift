//
//  Help.swift
//  BookCore
//
//  Created by Niall Kehoe on 03/04/2021.
//

import SwiftUI

/// Help View for CodeBreaking Page
struct Help: View {
    @Binding var showAlert: Bool                            /// dismiss Help Alert
    
    var body: some View {
        ZStack {
            CRectangle(cornerRadius: 25, foregroundColor: .white)
                .opacity(showAlert ? 1 : 0)
            
            VStack {
                CText(text: "Help", font: .system(size: 38), weight: .bold, foregroundColor: .black)
                    .multilineTextAlignment(.center)
                    .padding()
                    
                HelpTitleText(text: "Wetterbericht")
                
                Icon(name: "arrow.up.arrow.down.circle.fill", width: 35)
                
                HelpTitleText(text: "Weather Report")
                
                Button(action: {
                    playSound("Pop")
                    withAnimation(.easeInOut(duration: 1)) {
                        showAlert = false
                    }
                }, label: {
                    OKButton().padding()
                })
                .frame(height: 80)
            }
        }
    }
}

// MARK: - HelpTitleText
fileprivate struct HelpTitleText: View {
    let text: String /// help title
    
    var body: some View {
        CText(text: text,font: .title2, weight: .medium)
            .multilineTextAlignment(.center)
    }
}
