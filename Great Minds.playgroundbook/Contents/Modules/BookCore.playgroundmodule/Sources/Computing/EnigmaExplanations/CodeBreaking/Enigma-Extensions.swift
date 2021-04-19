//
//  Extensions.swift
//  BookCore
//
//  Created by Niall Kehoe on 30/03/2021.
//

import SwiftUI

// MARK: - Icon
struct Icon: View {
    var name: String ///  system image name
    var width: CGFloat /// width of image
    var ratio: CGFloat = 1 /// ratio of image
    var color: Color = .blue /// tint of image
    
    var body: some View {
        Image(systemName: name)
            .colourImage(color)
            .frame(width: width, height: width * ratio)
    }
}

// MARK: - OKButton
struct OKButton: View {
    var text: String = " OK " /// text of button
    
    var body: some View {
        HStack {
            CText(text: text, font: .title2, weight: .bold, foregroundColor: .white)
        }
        .frame(height: 50)
        .background(Color.blue)
        .cornerRadius(10)
    }
}

struct Checkmark: View {
    var correctSolution : Bool
    
    var body: some View {
        Icon(name: "checkmark.seal.fill", width: 45, color: .green)//􀇻
            .rotation3DEffect(Angle.degrees(correctSolution ? 360 : 0), axis: (x: 0, y: 1, z: 0))
            .animation(Animation.easeInOut(duration: 1).delay(1.5).repeatForever(autoreverses: false))
            .padding(0)
    }
}

internal extension CodeBreakingDemonstration {
    // MARK: - ExplanationText
    struct ExplanationText: View {
        var body: some View {
            HStack {
                Spacer().frame(width: 10)
                
                CText(text: "Turing recognised that commonly used words like 'Weather Report' appeared every day and these known words could be leveraged to eliminate possibilities of states of the Enigma machine.", font: .footnote, weight: .medium, foregroundColor: .secondary)
                    .multilineTextAlignment(.leading)
                    .padding(insets: [5,20,5,20])
                Spacer().frame(width: 10)
            }
        }
    }

    // MARK: - MessageField
    struct MessageField: View {
        var text: String /// text of message

        var body: some View {
            Text(text)
                .tracking(15)
                .font(/*@START_MENU_TOKEN@*/.title3/*@END_MENU_TOKEN@*/)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
        }
    }

    //MARK: - Error Alert (􀇿 Animation)
    struct ErrorAlert: View {
        var correctSolution: Bool
        var showErrors: Bool
        var animating: Bool
        
        var body: some View {
            Group {
                Group {
                    Icon(name: "exclamationmark.triangle.fill", width: 35, color: .red)//􀇿
                        .scaleEffect(self.animating ? 1.3 : 1)
                        .animation(Animation.linear(duration: 1).repeatForever().delay(1))

                    CText(text: "Error Detected", font: .title3, weight: .bold, foregroundColor: .red)
                        .multilineTextAlignment(.center)
                }
                .opacity(showErrors ? 1 : 0)
                .animation(Animation.easeIn(duration: 1).delay(2))
                .padding(insets: [0,0,10,0])
            }
            .opacity(correctSolution ? 0 : 1)
            .animation(Animation.easeIn(duration: 1))
        }
    }

    //MARK: - Error Message
    struct ErrorMessage: View {
        var showErrors: Bool
        
        var body: some View {
            CText(text: "Since an Enigma machine could not encode a letter as itself, this state of the machine can be eliminated.", font: .headline, weight: .bold, foregroundColor: .red)
                .multilineTextAlignment(.center)
                .animation(Animation.easeIn(duration: 1).delay(2))
                .padding(insets: [10,10,5,10])
                .offset(y: -150)
                .opacity(showErrors ? 1 : 0)
        }
    }

    //MARK: - Success Message
    struct SuccessEncryption: View {
        var correctSolution : Bool
        
        var body: some View {
            Group {
                Checkmark(correctSolution: correctSolution).offset(y: 20)

                CText(text: "No errors! This could be the correct encryption.", font: .body, weight: .bold, foregroundColor: .green)
                    .multilineTextAlignment(.center)
                    .padding(0)
                    .frame(width: UIScreen.screenWidth * 0.9, height: 80)
            }.opacity(correctSolution ? 1 : 0)
        }
    }

}
