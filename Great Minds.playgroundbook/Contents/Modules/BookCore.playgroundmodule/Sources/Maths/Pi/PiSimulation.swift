//
//  PiSimulation.swift
//  BookCore
//
//  Created by Niall Kehoe on 30/03/2021.
//

import SwiftUI
import Combine

/// Pi Calculation Simulation
struct PiSimulation: View {
    let colorScheme: ColorScheme
    
    @State private var piapprox = "0"       /// Pi Approximation
    @State private var n = 2                /// Number of Vertices of Polygon
    @State private var rotation = 0.0       /// Rotation of Infinity Btn

    @State private var size: CGFloat = 0.8  /// Scale of Infinity Btn
    private let blinkPublisher = PassthroughSubject<Void, Never>()  /// Blur animation for aproximation number
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ZStack {
                        Circle().strokeBorder(Color.blue,lineWidth: 5)
                            .background(Circle().foregroundColor(Color.clear))
                            .frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.9)

                        if n > 2 {
                            Polygon(corners: min(50, n))
                                .strokeBorder(Color.green,lineWidth: 5)
                                .frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.9)
                                .transition(.scale)
                        }
                        
                        Button(action: {
                            self.blinkPublisher.send()
                            loopAnim()
                            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { (timer) in
                                self.loopAnim()
                            }
                            launchTimer(with: 0.2)
                        }, label: {
                            if n > 4 {
                                Group {
                                    Icon(name: "infinity.circle.fill", width: rotation > 0 ? 45 : 80)
                                        .rotationEffect(Angle.degrees(rotation))
                                        .background(Color.white).cornerRadius(40)
                                        .scaleEffect(size)
                                        .onAppear() {
                                            withAnimation(Animation.easeInOut(duration: 2).repeatForever()) {
                                                self.size = 1.2
                                            }
                                        }
                                }
                                .offset(x: rotation > 0 ? (geometry.size.width*0.5)-(45*0.8):0, y: rotation > 0 ? -(geometry.size.width*0.5)+(45*0.6):0)
                            }
                        }).frame(width: 80, height: 80)
                    }
                    Spacer()
                }

                CText(text: n > 2 ? "No. of sides of the polygon: \(n)": "No. of sides of the polygon", font: .headline, weight: .semibold, foregroundColor: .white).padding(insets: [10,0,0,0])
                
                VStack {
                    Spacer()
                    Stepper("", onIncrement: {
                        VertexChange(number: n+1)
                    }, onDecrement: {
                        if n > 2 {
                            VertexChange(number: n-1)
                        }
                    })
                    .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 50)
                    .offset(x: -4)
                    .background(CRectangle(cornerRadius: 10, foregroundColor: colorScheme == .light ? .white: .clear).frame(width: 96, height: 33))

                    Spacer()
                }
                
                AproximationView(n: self.n, colorScheme: colorScheme)
                    .opacity(n >= 3 ? 1: 0)
                    .addOpacityBlinker(subscribedTo: blinkPublisher)

                CText(text: "π Approximation:", font: .title2, weight: .semibold, foregroundColor: .blue)

                CText(text: "\(piapprox)", font: .title, weight: .bold, foregroundColor: .white)
                    .opacity(n > 2 ? 1.0 : 0)
                    .addOpacityBlinker(subscribedTo: blinkPublisher)

                Spacer()
            }.padding()
            .onAppear {
                NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "isFullScreen"), object: nil, queue: nil) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        VertexChange(number: 3)
                    }
                }
            }
        }
    }
    
    /// Adjusts Polygon to new number of vertices
    private func VertexChange(number: Int) {
        self.blinkPublisher.send()
        playSound("Pop")
        withAnimation() {
            self.n = number
        }
        calcPiAproximation()
    }
    
    /// Inifinity Timer Calculation Loop
    private func launchTimer(with delay: Double) {
        Timer.scheduledTimer(withTimeInterval: delay, repeats: true) { (timer) in
            let nextStop = (delay == 0.4 ? 30 : delay == 0.2 ? 50 : 5000)
            
            if n < nextStop {
                n += delay == 0.12 ? 50: 1
            } else {
                timer.invalidate()
                if nextStop < 5000 {
                    launchTimer(with: (delay == 0.4 ? 0.2 : 0.12))
                } else {
                    n = 5000
                }
            }
            calcPiAproximation()
        }
    }
    /// Updates Pi Aproximation
    private func calcPiAproximation() {
        let answer = Double(n)/2 * sin(degrees: 360 / Double(n))
        piapprox = "\(answer.trailingsRemoved)\(n >= 2500 ? "2...":"")"
    }
    /// Loop Rotation for Inifinity Btn
    private func loopAnim() {
        withAnimation(.linear(duration: 3)) {
            self.rotation += 360
        }
    }
}


//MARK: - 3rd Party Blur Animation
fileprivate extension View {
    func addOpacityBlinker<T: Publisher>(subscribedTo publisher: T) -> some View where T.Output == Void, T.Failure == Never {
        self.modifier(OpacityBlinker(subscribedTo: publisher.eraseToAnyPublisher()))
    }
}
fileprivate struct OpacityBlinker: ViewModifier {
    @State private var isBlurred = false
    private var publisher: AnyPublisher<Void, Never>
    private static let duration = 0.8

    init(subscribedTo publisher: AnyPublisher<Void, Never>) {
        self.publisher = publisher
    }

    func body(content: Content) -> some View {
        content
            .blur(radius: isBlurred ? 10 : 0)
            .onReceive(publisher) { _ in
                withAnimation(.linear(duration: OpacityBlinker.duration / 2)) {
                    self.isBlurred = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + OpacityBlinker.duration / 2) {
                        withAnimation(.linear(duration: OpacityBlinker.duration / 2)) {
                            self.isBlurred = false
                        }
                    }
                }
            }
    }
}

