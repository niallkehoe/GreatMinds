//
//  Extensions.swift
//  BookCore
//
//  Created by Niall Kehoe on 30/03/2021.
//

import SwiftUI

// MARK: - Custom Extensions
struct Point : Hashable {
    var x: CGFloat
    var y: CGFloat
}

// MARK: - Trigonometric Functions
func sin(degrees: Double) -> Double {
    return __sinpi(degrees/180.0)
}
func cos(degrees: Double) -> Double {
    return __cospi(degrees/180.0)
}
func degreesToRadians(_ degrees: CGFloat) -> CGFloat {
    return degrees * CGFloat.pi / 180
}

// MARK: - Math Operations
extension Int {
    var factorial : Int { return Int((1...self).map(Double.init).reduce(1.0, *)) }
}

// MARK: - Visual Extensions
extension Double {
    var trailingsRemoved : String { return String(format: "%g", self) }
}

// MARK: - Swift UI Extensions

func lightColourModifier(colorScheme: ColorScheme) -> Color {
    return colorScheme == .dark ? .white: #colorLiteral(red: 0.1226766929, green: 0.1250133812, blue: 0.1213510707, alpha: 1).suColor
}
func darkColourModifier(colorScheme: ColorScheme) -> Color {
    return colorScheme == .light ? .white: #colorLiteral(red: 0.1226766929, green: 0.1250133812, blue: 0.1213510707, alpha: 1).suColor
}
func equationColourModifier(colorScheme: ColorScheme) -> Color {
    return colorScheme == .dark ? .white: #colorLiteral(red: 0.3450689912, green: 0.3451144099, blue: 0.3450536132, alpha: 1).suColor
}
extension UIColor {
    var suColor: Color { Color(self) }
}

extension Image {
    internal func colourImage(_ col: Color) -> some View {
        self
            .resizable()
            .renderingMode(.template)
            .foregroundColor(col)
    }
}

struct CImage: View {
    let name: String
    var size: CGSize
    var backgroundColor: Color = .clear
    var cornerRadius: CGFloat = 0
    var body: some View {
        Image(name).resizable().frame(width: size.width, height: size.height).background(backgroundColor).cornerRadius(cornerRadius)
    }
}
struct CImageColoured: View {
    var name: String
    var size: CGSize
    var col: Color
    var body: some View {
        Image(name).colourImage(col).frame(width: size.width, height: size.height)
    }
}

struct CText: View {
    let text: String
    let font: Font
    var weight: Font.Weight = .regular
    var foregroundColor: Color = .primary
    var body: some View {
        Text(text).font(font).fontWeight(weight).foregroundColor(foregroundColor)
    }
}
struct CRectangle: View {
    var cornerRadius: CGFloat = 0
    var foregroundColor: Color = .primary
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius).foregroundColor(foregroundColor)
    }
}

extension View {
    internal func padding(insets: [CGFloat]) -> some View {
        self.padding(EdgeInsets(top: insets[0], leading: insets[1], bottom: insets[2], trailing: insets[3]))
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

extension UIScreen {
   internal static let screenWidth = UIScreen.main.bounds.size.width
}

// MARK: - Sounds Extensions
import AVFoundation

struct Manager {
    static var player: AVAudioPlayer? {
        didSet {
            player?.prepareToPlay()
        }
    }
}

/**
 Plays a sound effect
 - Parameter name: The name of the mp3 file
 */
func playSound(_ name: String) {
    Manager.player?.stop()
    guard let url = Bundle.main.url(forResource: "\(name)", withExtension: "mp3") else { return }
    do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)

        try Manager.player = AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

        Manager.player?.play()
    } catch let error {
        print(error.localizedDescription)
    }
}

func playSoundwithDelay(_ name: String, delay: Double = 1.5) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        playSound(name)
    }
}
