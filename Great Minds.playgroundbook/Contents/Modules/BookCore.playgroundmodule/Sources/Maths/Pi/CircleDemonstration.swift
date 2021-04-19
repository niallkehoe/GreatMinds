//
//  CircleDemonstration.swift
//  BookCore
//
//  Created by Niall Kehoe on 31/03/2021.
//

import SwiftUI

/// Circle Animation Demonstration
struct CircleDemonstration: View {
    
    var geometry: GeometryProxy
    var sizeOfCircles: CGFloat                                                  /// size Of Circles
    var circleStep : Int                                                        /// step of Demonstration
    
    private static let noOfSides: Int = 60
    
    @State private var degrees : Double = 3                                     /// angle between vertices
    @State private var sideLengths: CGFloat = 23                                /// length of Sides
    
    @State private var moveAnim = false                                         /// has Semi-Circle Moved
    @State private var showDot = false                                          /// should circle Dot be Shown
    @State private var circlexoffset : CGFloat = 0                              /// x Offset of Circle
    @State private var circleRotation : Double = 0                              /// rotation of Circle
    @State private var initialradiusxOffset : [CGFloat] = [0,0,0,0]             /// x offset of Bars
    @State private var initialradiusyOffset : [CGFloat] = [0,0,0,0]             /// y offset of Bars
    @State private var showIntialRadiuses = [false, false, false, false]        /// show Bar Array
    private static let colours = [#colorLiteral(red: 0.2062557936, green: 0.7799046636, blue: 0.3489115834, alpha: 1), #colorLiteral(red: 1, green: 0.6758682132, blue: 0.1125759259, alpha: 1), #colorLiteral(red: 1, green: 0, blue: 0.4707108736, alpha: 1), #colorLiteral(red: 0.6224979758, green: 0.2854187489, blue: 1, alpha: 1)]                               /// colours of Bars
    
    @State private var animationInProgress = false                              /// is Animation in Progress
    @State private var size : CGFloat = 100                                     /// updated size of Circles
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ZStack(alignment: Alignment.center) {
                    CircleDesign(sizeOfCircles: sizeOfCircles, circleRotation: circleRotation, showDot: showDot)
                        .offset(x: circlexoffset)
                        
                    Group {
                        ForEach([true,false], id: \.self) { i in
                            HemiSphere(degrees: degrees, isTop: i, noOfSides: CircleDemonstration.noOfSides)
                                .stroke(Color.blue, lineWidth: 5)
                                .offset(x: moveAnim ? (i ? 1:-1)*(CGFloat(CircleDemonstration.noOfSides)*sideLengths/4):0, y: moveAnim && i ? sizeOfCircles:0)
                        }
                    }.frame(width: sizeOfCircles, height: sizeOfCircles)
                    
                    ForEach(0..<4) { item in
                        Line().stroke(CircleDemonstration.colours[item].suColor,lineWidth: 5)
                            .transition(.scale)
                            .offset(x: initialradiusxOffset[item], y: initialradiusyOffset[item])
                            .frame(width: item == 3 ? sizeOfCircles * 0.141592 : sizeOfCircles, height: 5)
                            .opacity(showIntialRadiuses[item] ? 1.0 : 0)
                    }
                }
                Spacer()
            }
            Spacer().frame(height: 16)
        }
        .onAppear {
            size = sizeOfCircles
            degrees = 3
            
            calcAngle(isInitial: true)
                
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                if !animationInProgress {
                    self.calcAngle()
                } else {
                    timer.invalidate()
                }
            }
        }
        .onChange(of: circleStep) { (cnt) in
            nextStep()
        }
        .onChange(of: sizeOfCircles) { (sze) in
            size = sze
        }
    }
    
    /// Play Btn Clicked
    private func nextStep() {
        if circleStep == 1 {
            withAnimation(.easeInOut(duration: 3)) {
                degrees = 0
                moveAnim.toggle()
            }
        } else if circleStep == 2 {
            animationInProgress = true
            withAnimation(.easeInOut(duration: 3)) {
                circlexoffset = -(CGFloat(CircleDemonstration.noOfSides)*sideLengths/2)
                circleRotation = -180
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                showDot = true
            }
            show(no: 0, delay: 3)
            nextBar(no: 0, time: 3.6)
            show(no: 1, delay: 4.8)
            nextBar(no: 1, time: 5.4)
            show(no: 2, delay: 6.6)
            nextBar(no: 2, time: 7.2)
            show(no: 3, delay: 8.4)
            nextBar(no: 3, time: 9)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                startRotateAnim()
            }
        }
    }
    
    /// Rocking Animation Started
    private func startRotateAnim() {
        rotateCircle()
        Timer.scheduledTimer(withTimeInterval: 7, repeats: true) { (timer) in
            rotateCircle()
        }
    }
    /// show Bar #x
    private func show(no: Int, delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showIntialRadiuses[no] = true
            }
        }
    }
    /// move Bar to Location
    private func nextBar(no: Int, time: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            withAnimation(.easeInOut(duration: 1.2)) {
                initialradiusxOffset[no] = no == 0 ? -((CGFloat(CircleDemonstration.noOfSides)*sideLengths/2)-(sizeOfCircles/2)) : (initialradiusxOffset[no-1] + (sizeOfCircles * (no == 3 ? 0.57079631: 1)))
                initialradiusyOffset[no] = (sizeOfCircles/2) + 10
            }
        }
    }
    /// Rotate Circle
    private func rotateCircle() {
        move()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
            move(multiplier: -1)
        }
    }
    private func move(multiplier: CGFloat = 1) {
        withAnimation(.easeInOut(duration: 3)) {
            circlexoffset = multiplier * (CGFloat(CircleDemonstration.noOfSides)*sideLengths/2)
            circleRotation += 360 * Double(multiplier)
        }
    }
    
    private func calcAngle(isInitial: Bool = false) {
        /// alpha =  (180-6 degrees) / 2
        sideLengths = 0.05233595624*size // sin(3 degrees) * size
        
        initialradiusxOffset[0] = -(CGFloat(CircleDemonstration.noOfSides)*sideLengths/2)
        initialradiusxOffset[1] = -((CGFloat(CircleDemonstration.noOfSides)*sideLengths/2)-(size/2))
        initialradiusxOffset[2] = initialradiusxOffset[1]+size
        initialradiusxOffset[3] = initialradiusxOffset[2]+(size*0.64159262)
        for i in 1...3 {
            initialradiusyOffset[i] = (size/2) + 10
        }
    }
    
}
