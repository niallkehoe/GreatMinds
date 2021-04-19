//
//  TopBar.swift
//  BookCore
//
//  Created by Niall Kehoe on 03/04/2021.
//

import SwiftUI

//MARK: - Tower
struct SignalTower: View {
    var body: some View {
        ZStack {
            CImage(name: "tower", size: CGSize(width: 65, height : 65), backgroundColor: .white, cornerRadius: 8)
            VStack {
                Loading()
            }.offset(y: -18)
        }
    }
}

//MARK: - Pinging Animation
fileprivate struct Loading : View {
    @State private var waves = [false, false]
    
    var body: some View {
        ZStack {
            ForEach(0..<2, id: \.self) { elem in
                Circle().stroke(lineWidth: 5)
                    .frame(width: 10, height: 10)
                    .foregroundColor(.red)
                    .scaleEffect(waves[elem] ? 4 : 1)
                    .opacity(waves[elem] ? 0 : 0.7)
                    .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: false).speed(0.5))
                    .onAppear {
                        waves[elem].toggle()
                    }
            }
        }
    }
}

//MARK: - Intercepted Message
struct InterceptedMessage: View {
    var intereceptedMessage: String
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                CText(text: "Intercepted Message:", font: .caption, weight: .bold, foregroundColor: .blue)
                    .multilineTextAlignment(.leading)
                    .padding(insets: [0,0,2,0])
                
                ChatBubble() {
                    Text("\(intereceptedMessage)").foregroundColor(Color.white)
                        .padding(insets: [0,17,7,8])
                        .background(Color.blue)
                        .opacity(intereceptedMessage == "" ? 0 : 1)
                        .offset(y: 3)
                }
            }
        }
    }
}

//MARK: - Chat Bubble
fileprivate struct ChatBubble<Content>: View where Content: View {
    let content: () -> Content
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        HStack {
            content().clipShape(ChatBubbleShape())
            Spacer()
        }.padding([.leading, .top, .bottom], 0)
        .padding(.trailing, 50)
    }
}

fileprivate struct ChatBubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let path = Path { p in
            p.move(to: CGPoint(x: 25, y: height))
            p.addLine(to: CGPoint(x: width - 20, y: height))
            p.addCurve(to: CGPoint(x: width, y: height - 20), control1: CGPoint(x: width - 8, y: height), control2: CGPoint(x: width, y: height - 8))
            p.addLine(to: CGPoint(x: width, y: 20))
            p.addCurve(to: CGPoint(x: width - 20, y: 0), control1: CGPoint(x: width, y: 8), control2: CGPoint(x: width - 8, y: 0))
            p.addLine(to: CGPoint(x: 21, y: 0))
            p.addCurve(to: CGPoint(x: 4, y: 20), control1: CGPoint(x: 12, y: 0), control2: CGPoint(x: 4, y: 8))
            p.addLine(to: CGPoint(x: 4, y: height - 11))
            p.addCurve(to: CGPoint(x: 0, y: height), control1: CGPoint(x: 4, y: height - 1), control2: CGPoint(x: 0, y: height))
            p.addLine(to: CGPoint(x: -0.05, y: height - 0.01))
            p.addCurve(to: CGPoint(x: 11.0, y: height - 4.0), control1: CGPoint(x: 4.0, y: height + 0.5), control2: CGPoint(x: 8, y: height - 1))
            p.addCurve(to: CGPoint(x: 25, y: height), control1: CGPoint(x: 16, y: height), control2: CGPoint(x: 20, y: height))
            
        }
        return path
    }
}
