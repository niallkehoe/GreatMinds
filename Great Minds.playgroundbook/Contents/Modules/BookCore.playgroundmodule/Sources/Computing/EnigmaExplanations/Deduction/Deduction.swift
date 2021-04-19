//
//  Deduction.swift
//  BookCore
//
//  Created by Niall Kehoe on 03/04/2021.
//

import SwiftUI

/// Explanation of Deciphiring Engima
struct Deduction: View {

    //MARK: - Semi-Static Animation Variables
    static internal let sizeOfKeys : CGFloat = 35                               /// size of Rotor Keys
    @State internal var keyDuration = 0.75                                      /// Rotor Keys Animation Time

    //MARK: - Intercept Variables
    @State private var interceptOffset = 0                                      /// letter offset of Intercept

    //MARK: - Key Variables
    @State internal var keys = ["w", "questionmark", "questionmark", "b"]       /// rotor keys
    @State internal var rotationValue: [Double] = [0,0,0,0]                     /// rotation of rotor keys
    @State internal var fadeOut = [false, false, false , false]                 /// rotor keys are shown
    @State private var nextBtnScaling: Bool = true                              /// next Btn Scaling Animation

    //MARK: - Animation Variables
    @State internal var step = 0                                                /// stage of Process
    @State private var explanationText = "We can guess that W is connected to A. If the rotors are set to (AAA), when W is pressed, A is inputted into  the rotors. We know from the rotor settings that A will become C. If our encrypted output should be B, we can conclude that B must be connected to C on the plugboard if this setting is correct."            /// explanation

    //MARK: - Connections Variables
    @State internal var connections = [Connection]()                            /// proposed connections

    //MARK: - Button Variables
    @State internal var buttonStep = 0                                          /// button Presses -> 3D Flip
    @State internal var buttonName = " Guess Plugboard Setting "                /// text of next btn
    @State private var buttonDeactvated = false                                 /// touch of button blocked

    //MARK: - Rotor Variables
    @State internal var rotorPositions = [0, 0, 0]                              /// positions of rotors
    static let map = Mappings()                                                 /// virtual Enigma Wirings

    //MARK: - Loop Variables
    @State private var isActivityIndicatorRotating = false                      /// is Loading Animation rotating
    @State private var solutionFound = false                                    /// has correct configuration been found
    @State private var increaseAmmount = 1                                      /// Process rotor increase ammount

    @State internal var outKeyIndex = 0.0                                                /// number of rotor settings checked
    private static var outKeyCypher = ["c","d","o","q","k","r","j","n","y","i","t","p","w","l","g","b","f","a","x","v","u","m","e","z","s","h"] /// example cypher for message

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(alignment: .center) {
                    Group {
                        DeductionTopBar(parent: self)
                        DeductionIntercepts(count: interceptOffset)

                        DeductionKeys(parent: self)

                        Spacer().frame(height: 20)

                        Group {
                            NextButton(parent: self)
                        }.scaleEffect(nextBtnScaling ? 1.15 : 1)
                    }
     
                    Group {
                        if [1,3,5,6,9].contains(step) {
                            CText(text: explanationText, font: .body, weight: .bold, foregroundColor: .blue)
                                .padding(insets: [5,20,5,20])
                        }

                        if step < 10 {
                            DeductionConnections(parent: self)
                        }
                        if step == 6 {
                            CText(text: "Since an Enigma plugboard can only have one connection between two letters, we can eliminate the setting of B-Q and B-C", font: .body, weight: .bold, foregroundColor: .red)
                        }
                    }
                    .multilineTextAlignment(.center)
                    Group {
                        if [10,11,12].contains(step) {
                            DeductionProgressView(parent: self)
                                .padding(insets: [-5,30,0,30])
                                .opacity(step == 9 ? 0 : step == 13 ? 0: 1)
                        }
                        if [10,12].contains(step) {
                           ActivityIndicator(isAnimating: $isActivityIndicatorRotating)
                                .padding(insets: [10,0,0,0])
                        }
                        if step == 11 {
                            CText(text: "All possible connections for the rotor setting (AAA) have been run. Unfortunately, all had contradictions, therefore we move to the next rotor setting (AAB) and repeat the process.", font: .body, weight: .bold, foregroundColor: .blue)
                                .multilineTextAlignment(.center)
                                .frame(height: 150)
                                .padding(insets: [5,30,0,30])
                        }
                        if step == 13 {
                            Checkmark(correctSolution: solutionFound)

                            CText(text: "After looping through the possible rotor settings, we've found a solution! It just so happens that the Rotor Settings are AMT, Turing's initials.", font: .body, weight: .bold, foregroundColor: .green)
                                .padding(insets: [0,30,0,30])
                                .multilineTextAlignment(.center)
                                .transition(.scale)

                            HStack {
                                CImage(name: "alanturing", size: CGSize(width: 90, height: 90))

                                CText(text: "Alan Mathison Turing", font: .title2, weight: .bold)
                                    .padding(insets: [5,30,0,30])
                            }.transition(.scale)
                        }
                        if step == 15 {
                            CText(text: "Since all the rotor and plugboard settings have been deduced, all of that days intercepted messages can be deciphered.", font: .body, weight: .bold, foregroundColor: .blue)
                                .multilineTextAlignment(.center)
                                .padding(insets: [5,30,0,30])
                        }
                    }
                    
                    Spacer()
                    
                    Plugboard()
                        .frame(width: 405, height: 165)
                        .ignoresSafeArea(/*@START_MENU_TOKEN@*/.keyboard/*@END_MENU_TOKEN@*/, edges: /*@START_MENU_TOKEN@*/.bottom/*@END_MENU_TOKEN@*/)
                        .offset(y: 10)
                    
                }.onAppear {
                    withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(1), {
                        self.nextBtnScaling.toggle()
                    })
                }
                
                ConfettiCelebrationView()
            }
        }
    }

    internal func handlePress() {
        if buttonDeactvated == true { return }
        buttonDeactvated = true
        playSound("Whoosh")
        if step == 0 {
            Step0()
        } else if step == 1 {
            Step1()
        } else if step == 3 {
            Step3()
        } else if step == 6 {
            Step4()
        } else if step == 9 {
            Step5()
        } else if step == 11 {
            Step6()
        } else if step == 13 {
            Step7()
        } else if step == 15 {
            executeButtonStep()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "dismissModal"), object: nil)
            }
        }
    }
}

extension Deduction {
    //MARK: - Fade Keys
    
    /// Fade Key
    /// - Parameters:
    ///   - indx: Key #
    ///   - text: New Letter of Key
    ///   - startupTime: time for animation to start
    ///   - delay: aditional delay
    ///   - delaytoShow: length of Animation
    private func fadeKey(_ indx: Int, text: String, startupTime: Double = 0, delay: Double = 0, delaytoShow: Double = 0.85) {
        DispatchQueue.main.asyncAfter(deadline: .now() + startupTime + delay) {
            self.fadeOut[indx].toggle()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delaytoShow) {
                self.keys[indx] = text
                self.fadeOut[indx].toggle()
            }
        }
    }
    
    /// Fade All Keys to specific strings
    /// - Parameters:
    ///   - str1: letter for Key #1
    ///   - str2: letter for Key #2
    ///   - str3: letter for Key #3
    ///   - str4: letter for Key #4
    private func fadeKeysGroup(_ str1: String, _ str2: String, _ str3: String, _ str4: String) {
        fadeKey(0, text: str1)
        fadeKey(1, text: str2)
        fadeKey(2, text: str3)
        fadeKey(3, text: str4)
    }

    //MARK: - Animation Functions
    /// Next Step
    /// - Parameters:
    ///   - duration: duration of animation
    ///   - delay: delay until step animation
    private func executeStep(duration: Double = 1.5, delay: Double = 0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeInOut(duration: 1.5)) {
                step += 1
            }
        }
    }
    /// Next Button Step
    /// - Parameters:
    ///   - duration: duration of animation
    ///   - delay: delay until step animation
    private func executeButtonStep(duration: Double = 1, delay: Double = 0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeInOut(duration: 1.5)) {
                buttonStep += 1
            }
        }
    }
    /// Move to next letter of intercept
    /// - Parameters:
    ///   - duration: duration of animation
    ///   - delay: delay until step animation
    private func executeCount(duration: Double = 1, delay: Double = 0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeInOut(duration: 1.5)) {
                interceptOffset += 1
            }
        }
    }
    
    /// Reactivate Next Step Button
    /// - Parameter delay: delay until button is reacitvated
    private func reactiveButton(delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { self.buttonDeactvated = false; outKeyIndex = 1; Manager.player?.stop(); }
    }
    //MARK: - Solution Loops
    
    /// Rotate Right most Rotor to Specific Position
    /// - Parameter str: new rotor position
    private func rotateRightRotorToPosition(str: String) {
        withAnimation(.easeInOut(duration: 1.5)) {
            rotorPositions[2] = Deduction.map.charsToNumbers[str]!
        }
    }
    
    /// AA_ Loop Possibilities Animation (Check Plugboard Wiring)
    /// - Parameter delay: delay for timer
    private func speedUpKeyLoop(delay: Double) {
        Timer.scheduledTimer(withTimeInterval: delay, repeats: true) { (timer) in
            if outKeyIndex == 24 {
                timer.invalidate()
                //Final done
                isActivityIndicatorRotating = false
                executeStep()
            }
            if outKeyIndex == 5 || outKeyIndex == 15 {
                timer.invalidate()
                speedUpKeyLoop(delay: outKeyIndex == 5 ? 0.5 : 0.3)
            }
            loopKeys()
        }
    }
    
    /// Check Plugboard Wiring
    private func loopKeys() {
        outKeyIndex += 1
        fadeKey(1, text: Deduction.map.charsToNumbers.someKey(forValue: Int(outKeyIndex))!, delaytoShow: 0)
        fadeKey(2, text: Deduction.outKeyCypher[Int(outKeyIndex)], delaytoShow: 0)
    }
    /// Animate Check of Rotor Setting
    private func addCheckofPossibilities() {
        outKeyIndex += Double(increaseAmmount)
        rotateSetting(number: 2) /// number 2 -> Right most Rotor
    }
    /// Rotate Rotors -> Right Most ++, if Right most > 25 -> rotate middle rotor
    private func rotateSetting(number: Int) {
        var increase = rotorPositions[number] + increaseAmmount
        if increase >= 25 {
            rotorPositions[number] = 0
            if number == 0 { return }
            rotateSetting(number: number-1) // Turn over adjacent
        } else {
            if number == 2 {
                if (increase) > 25 { increase -= 25 }
                rotorPositions[number] = increase
            } else {
                rotorPositions[number] = rotorPositions[number] + 1
            }
        }
    }
    /// Loop Possibilities
    private func speedUpPossiblities(delay: Double) {
        Timer.scheduledTimer(withTimeInterval: delay, repeats: true) { (timer) in
            if outKeyIndex >= 30 { increaseAmmount = 2 }
            addCheckofPossibilities()
            if outKeyIndex == 5 || outKeyIndex == 10 || outKeyIndex == 15 {
                timer.invalidate()
                speedUpPossiblities(delay: outKeyIndex == 5 ? 0.5 : outKeyIndex == 10 ? 0.3: 0.15)
                increaseAmmount = outKeyIndex == 15 ? 2 : 1
            }

            if outKeyIndex >= 329 {
                timer.invalidate()
                //Solution found
                isActivityIndicatorRotating = false
                outKeyIndex = 332
                rotateRightRotorToPosition(str: "t")
                correctSolutionLines()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(.easeInOut(duration: 1.5)) {
                        executeStep()
                        isActivityIndicatorRotating = false
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    solutionFound = true
                    reactiveButton(delay: 0)
                    Manager.player?.stop()
                }
                
                fadeKeysGroup("w", "s", "b", "b")
                
                NotificationCenter.default.post(name: Notification.Name.playConfettiCelebration, object: Bool.self)
            }
        }
    }

    /// Plugboard Wiring for Correct Solution
    private func correctSolutionLines() {
        let inputs =  ["n","a","k","h","s","v","p","q","x","j"]
        let outputs = ["i","l","e","o","w","u","r","m","g","f"]
        for i in 0..<10 {
            createLine(from: inputs[i], to: outputs[i])
        }
    }

    //MARK: - Lines

    /// Adds a Connection and Wires the SKScene Plugboard
    private func createLineOverall(from: String, to: String, corrupted: Bool = false) {
        connections.append(Connection(letter1: from, letter2: to, corrupted: corrupted))
        createLine(from: from, to: to)
    }
    /// Wires the SKScene Plugboard
    private func createLine(from: String, to: String) {
        NotificationCenter.default.post(name: Plugboard.notificationName, object: nil, userInfo:["id": "\(from)-\(to)"])
    }
    /// Change corruption of specific connection
    private func changeCorruption(from: String, to: String) {
        for connection in connections {
            if connection.letter1 == from && connection.letter2 == to {
                connection.isCorrupted = true
            }
        }
    }
    /// Remove all Plugboard Wires
    private func removeLines() {
        NotificationCenter.default.post(name: Plugboard.removeNotification, object: nil, userInfo:["id": true])
    }
    //MARK: - Steps for Process

    private func Step0() {
        fadeKey(1, text: "a")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            createLineOverall(from: "w", to: "a")

            fadeKey(2, text: "c")
            executeButtonStep()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                self.buttonName = " Next Step "
            }

            createLineOverall(from: "c", to: "b")//"b", to: "c")

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeInOut(duration: 2)) {
                    step += 1
                }
            }
            reactiveButton(delay: 2.2)
        }
    }

    private func Step1() {
        executeButtonStep()

        fadeKey(0, text: "e")
        fadeKey(3, text: "t", delay: 0.5)
        executeStep(duration: 1, delay: 1)

        fadeKey(1, text: "g", startupTime: 1.7)
        fadeKey(2, text: "f", startupTime: 1.7, delay: 0.5)
        executeCount(delay: 0.1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeInOut(duration: 1.5)) {
                explanationText = "We can then examine the next letter. Just like before we can deduce that E is connected to G and F is connected to T."
                step += 1
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            withAnimation(.easeInOut(duration: 1.5)) {
                createLineOverall(from: "e", to: "g")
                createLineOverall(from: "f", to: "t")
            }
        }
        reactiveButton(delay: 5.5)
    }

    private func Step3() {
        executeButtonStep()

        executeStep(duration: 1)
        executeCount(delay: 1.2)
        
        fadeKey(0, text: "t", startupTime: 1.2)
        fadeKey(3, text: "q", startupTime: 1.2, delay: 0.5)
        fadeKey(1, text: "f", startupTime: 3)
        fadeKey(2, text: "b", startupTime: 3, delay: 0.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeInOut(duration: 1.5)) {
                explanationText = "We can then examine the next letter. Just like before we can deduce that B is connected to Q. However, this is a problem since we already established that B is connected to C."
                step += 1
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            withAnimation(.easeInOut(duration: 1.5)) {
                createLineOverall(from: "b", to: "q", corrupted: true)
                changeCorruption(from: "b", to: "c")
                step += 1
            }
        }
        reactiveButton(delay: 5.5)
    }

    private func Step4() {
        executeButtonStep()

        executeStep()
        executeStep(delay: 1.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeInOut(duration: 2)) {
                //Corrupt
                executeStep()
                explanationText = "Since this setting was incorrect, we try the next one (AAB). But we now know that W-A, C-B, E-G, F-T and B-Q are not any of the plugboard's settings; as Fruit of the Poisonous Tree we can rule any setting out which involves these settings."
                for connection in connections {
                    connection.isCorrupted = true
                }
            }
        }
        reactiveButton(delay: 3.8)
    }

    private func Step5() {
        playSound("Computers")
        
        executeButtonStep()

        fadeKeysGroup("w", "questionmark", "questionmark", "b")
        executeStep()
        withAnimation(.easeInOut(duration: 1.5)) {
            interceptOffset = 0
        }
        removeLines()
        isActivityIndicatorRotating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            connections.removeAll()
            keyDuration = 0.0
            speedUpKeyLoop(delay: 1)
        }
        reactiveButton(delay: 16.0)
    }

    private func Step6() {
        playSound("Computers")
        
        executeButtonStep()

        isActivityIndicatorRotating = true
        executeStep()
        outKeyIndex = 1
        speedUpPossiblities(delay: 0.7)
        
        for i in 0...3 {
            fadeKey(i, text: "questionmark")
            rotateKey(index: Double(i))
        }
    }
    
    /// 3D rotate Key of
    /// - Parameter index: Key Index
    private func rotateKey(index: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + (1.5*index)) {
            withAnimation(.linear(duration: 1.5 * (22-index))) { /// 32 seconds / 1.5 seconds per rotation = 22 rotations
                rotationValue[Int(index)] += 360 * (22-index)
            }
        }
    }

    private func Step7() {
        executeButtonStep()

        executeStep()
        executeStep(delay: 1.5)
        reactiveButton(delay: 1.5)
    }
}

//MARK: - Connections

internal final class Connection: NSObject {
    var letter1: String
    var letter2: String
    var isCorrupted: Bool

    init(letter1: String, letter2: String, corrupted: Bool = false) {
        self.letter1 = letter1
        self.letter2 = letter2
        self.isCorrupted = corrupted
    }
}

// MARK: - Confetti

fileprivate struct ConfettiCelebrationView: View {
    @State private var timer = Timer.publish(every: 0.0, on: .main, in: .common).autoconnect()
    @State private var isShowingConfetti = false

    var body: some View {

        let confetti = ConfettiView( confetti: [
            .init(text: "🎉"),
            .init(text: "🥳"),
            .init(text: "🤩"),
            .init(text: "✌🏾"),
            .init(text: "✌🏼"),
            .init(text: "🥇"),
            .init(text: "😙")
        ]).transition(.slowFadeOut).transition(.slowFadeIn)

        return ZStack {
            if isShowingConfetti { confetti } else { EmptyView() }
        }.onReceive(timer) { time in
            self.timer.upstream.connect().cancel()
            self.isShowingConfetti = false
        }.onReceive(NotificationCenter.default.publisher(for: Notification.Name.playConfettiCelebration)) { _ in
            timer = Timer.publish(every: 5.0, on: .main, in: .common).autoconnect()
            isShowingConfetti = true
        }
    }
}

fileprivate extension Notification.Name {
    static let playConfettiCelebration = Notification.Name("play_confetti_celebration")
}

fileprivate extension AnyTransition {
    static var slowFadeOut: AnyTransition {
        let insertion = AnyTransition.opacity
        let removal = AnyTransition.opacity.animation(.easeOut(duration: 1.5))
        return .asymmetric(insertion: insertion, removal: removal)
    }

    static var slowFadeIn: AnyTransition {
        let insertion = AnyTransition.opacity.animation(.easeIn(duration: 1.5))
        let removal = AnyTransition.opacity
        return .asymmetric(insertion: insertion, removal: removal)
    }
}

fileprivate struct ConfettiView: UIViewRepresentable {
    private var confetti = [Confetti]()

    public init(confetti: [Confetti]) {
        self.confetti = confetti
    }
    public func makeUIView(context: Context) -> UIConfettiView {
        return UIConfettiView()
    }
    public func updateUIView(_ uiView: UIConfettiView, context: Context) {
        uiView.emit(with: confetti)
    }
}

fileprivate struct Confetti {
    var text: String

    var image: UIImage {
        let defaultAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 16.0)]
        return NSAttributedString(string: "\(text)", attributes: defaultAttributes).image()
    }
}

fileprivate final class UIConfettiView: UIView {
    internal func emit(with contents: [Confetti]) {
        let layer = Layer()
        layer.configure(with: contents)
        layer.frame = self.bounds
        layer.needsDisplayOnBoundsChange = true
        layer.position = CGPoint(x: UIScreen.main.bounds.width / 2 , y: -UIScreen.main.bounds.height)
        layer.emitterShape = .line
        self.layer.addSublayer(layer)
    }
}

fileprivate final class Layer: CAEmitterLayer {
     internal func configure(with contents: [Confetti]) {
        emitterCells = contents.map { content in
            let cell = CAEmitterCell()

            cell.birthRate = 13.0
            cell.lifetime = 8.0
            cell.velocity = CGFloat(cell.birthRate * cell.lifetime)
            cell.velocityRange = cell.velocity / 2
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 4
            cell.spinRange = .pi * 8
            cell.scaleRange = 0.25
            cell.scale = 1.0 - cell.scaleRange
            cell.contents = content.image.cgImage

            return cell
        }
    }
}

fileprivate extension NSAttributedString {
    func image() -> UIImage {
        return UIGraphicsImageRenderer(size: size()).image { _ in
            self.draw(at: .zero)
        }
    }
}
