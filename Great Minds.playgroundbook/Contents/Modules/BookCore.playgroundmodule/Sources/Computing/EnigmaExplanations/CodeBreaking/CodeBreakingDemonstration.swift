//
//  CodeBreakingDemonstration.swift
//  BookCore
//
//  Created by Niall Kehoe on 03/04/2021.
//

import SwiftUI
import UIKit

struct CodeBreakingDemonstration: View {
    
    private static let interecept1 = "jxbtqbggywcryb"                   /// Sample encryption message
    
    @State private var interceptedMessagetxt = ""                       /// Intercept Message
    @State private var index = 0                                        /// Index of Intercept

    @State private var interceptOffset : CGFloat = 0                    /// Intercept Letter Offset
    @State private var showErrors = false                               /// Show Errors

    @State private var errorAlertScaling = false                        /// Error Message Scale Animation Begun
    @State private var showHelpAlert = false                            /// Help Alert Shown

    @Environment(\.viewController) private var viewControllerHolder: UIViewController?      /// VC for Presenting Swift UI View Full Screen

    @State private var buttonCount : Int = 0                            /// Stage of Scene

    var body: some View {
        GeometryReader { geom in
            ZStack {
                VStack {
                    Spacer().frame(height: 10)
                    
                    HStack {
                        Spacer().frame(width: 25)
                        
                        SignalTower()

                        InterceptedMessage(intereceptedMessage: interceptedMessagetxt)

                        Icon(name: "questionmark.circle", width: 38)
                            .offset(x: -25, y: -5)
                            .onTapGesture { helpPressed() }
                    }.frame(height: 65)

                    Spacer().frame(height: 12)
                    ExplanationText()

                    Spacer().frame(height:10)

                    //Errors label

                    ErrorAlert(correctSolution: buttonCount == 2 ? true:false, showErrors: showErrors, animating: errorAlertScaling)

                    ZStack {
                        VStack {
                            MessageField(text: "Wetterbericht")
                                .offset(x: 7.5, y: buttonCount == 2 ? -85 : 0)

                            MessageField(text: interceptedMessagetxt)
                                .transition(.move(edge: .leading))
                                .offset(x: !errorAlertScaling ? -(UIScreen.screenWidth) : interceptOffset, y: buttonCount == 2 ? -85 : 0)
                                .frame(width: UIScreen.screenWidth*1.3)
                                .ignoresSafeArea()
                            
                            Spacer().frame(height: 20)

                            SuccessEncryption(correctSolution: buttonCount == 2 ? true:false)

                            Spacer().frame(height: 10)
                        }
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.red, lineWidth: 4)
                            .frame(width: 20, height: 65)
                            .animation(Animation.easeInOut(duration: 2).delay(1))
                            .offset(x: interceptOffset == 36 ? -70: -92, y: -82)
                            .opacity(showErrors ? 1 : 0)
                    }
                    
                    ErrorMessage(showErrors: showErrors).frame(height: 80)

                    Button(action: {
                        if showErrors == true { showErrors = false }
                        
                        playSound("Swoosh")
                        withAnimation(.easeInOut(duration: 1)) {
                            buttonCount += 1
                            if interceptOffset == 36 {
                                showErrors = true
                                self.interceptOffset -= 22
                                playSoundwithDelay("Error")
                            } else if interceptOffset == 14 {
                                self.interceptOffset -= 23
                                showErrors = false
                                
                                playSoundwithDelay("Correct")
                            } else {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    //Line removed due to crash alterations for extension referenced
                                    self.viewControllerHolder?.present() { Deduction() }
                                }
                            }
                        }
                    }, label: {
                        Icon(name: "circle.dashed.inset.fill", width: 50)
                    })
                    .rotationEffect(.radians(Double(buttonCount) * .pi))
                    .animation(Animation.easeInOut(duration: 1.5))
                    .opacity(showErrors || buttonCount == 2 ? 1 : 0)
                    
                    Spacer().frame(height: 15)

                }.onAppear {
                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
                        if !errorAlertScaling {
                            let interceptarr = CodeBreakingDemonstration.interecept1.map(String.init)
                            withAnimation() {
                                self.interceptedMessagetxt = interceptedMessagetxt + "\(interceptarr[index])"
                            }
                            index += 1
                            if index == interceptarr.count {
                                displayInterceptCall()
                                timer.invalidate()
                            }
                        }
                    }
                }.frame(width: geom.size.width, height: geom.size.height)

                VisualEffectView(effect: UIBlurEffect(style: .dark)).edgesIgnoringSafeArea(.all).opacity(showHelpAlert ? 1:0)

                Help(showAlert: $showHelpAlert)
                    .clipped()
                    .frame(width: 250, height: 260)
                    .opacity(showHelpAlert ? 1 : 0)
            }
            .frame(width: geom.size.width, height: geom.size.height)
            .clipped()
        }
    }

    private func displayInterceptCall() {
        playSoundwithDelay("Error")
        withAnimation(.easeIn(duration: 2)) {
            errorAlertScaling = true
            showErrors = true
            interceptOffset = 36 ///  Stide * 2 = offset
        }
    }

    private func helpPressed() {
        withAnimation(.easeInOut(duration: 1)) {
            showHelpAlert = true
        }
    }
    
}

fileprivate struct ViewControllerHolder {
    weak var value: UIViewController?
}

fileprivate struct ViewControllerKey: EnvironmentKey {
    static var defaultValue: ViewControllerHolder {
        return ViewControllerHolder(value: globalView)
    }
}

fileprivate extension EnvironmentValues {
    var viewController: UIViewController? {
        get { return self[ViewControllerKey.self].value }
        set { self[ViewControllerKey.self].value = newValue }
    }
}
fileprivate extension UIViewController {
    /// Present Swift UI View
    /// - Parameters:
    ///   - builder: Desired Swift UI View
    func present<Content: View>(@ViewBuilder builder: () -> Content) {
        let toPresent = UIHostingController(rootView: AnyView(EmptyView()))
        toPresent.modalPresentationStyle = .fullScreen

        toPresent.rootView = AnyView(
            builder()
                .environment(\.viewController, toPresent)
        )
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "dismissModal"), object: nil, queue: nil) { [weak toPresent] _ in
            toPresent?.dismiss(animated: true, completion: nil)
        }
        self.present(toPresent, animated: true, completion: nil)
    }
}
