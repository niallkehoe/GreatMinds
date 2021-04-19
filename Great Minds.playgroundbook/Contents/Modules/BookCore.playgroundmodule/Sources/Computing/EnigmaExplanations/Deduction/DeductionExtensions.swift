//
//  DeductionExtensions.swift
//  BookCore
//
//  Created by Niall Kehoe on 03/04/2021.
//

import SwiftUI

// MARK: - ExampleDeductionText
fileprivate struct ExampleDeductionText: View {
    var name: String /// explanation text
    var body: some View {
        CText(text: name, font: .body, weight: .medium)
            .multilineTextAlignment(.leading)
    }
}
//MARK: - Red Line
fileprivate struct RedLine: View {
    var body: some View {
        CRectangle(cornerRadius: 8, foregroundColor: #colorLiteral(red: 1, green: 0.209497124, blue: 0.3611853123, alpha: 1).suColor)
            .frame(width: 10, height: 4)
            .transition(.slide)
    }
}

extension Deduction {
    //MARK: - Deduction Top Bar
    struct DeductionTopBar: View {
        let parent: Deduction
        
        var body: some View {
            HStack {
                CText(text: "Deductions", font: .largeTitle, weight: .bold, foregroundColor: .blue)
                    .padding(insets: [0,20,0,0])
                Spacer()
                
                ZStack {
                    CRectangle(cornerRadius: 7, foregroundColor: #colorLiteral(red: 0.1259502769, green: 0.1259788871, blue: 0.125946492, alpha: 1).suColor)
                    HStack {
                        ForEach(0 ..< 3, id: \.self) { row in
                            CText(text: Deduction.map.charsToNumbers.someKey(forValue: parent.rotorPositions[row])!.uppercased(), font: .title, weight: .bold, foregroundColor: .white)
                                .rotation3DEffect(Angle(degrees: Double(parent.rotorPositions[row] * 360)), axis: (x: 1.0, y: 0.0, z: 0.0))
                        }
                    }
                }.multilineTextAlignment(.center)
                .frame(width: 80, height: 40)
                .padding(insets: [0,0,0,10])
            }
        }
    }

    //MARK: - Deduction Intercepts
    struct DeductionIntercepts: View {
        var count: Int
        @State private var letteroffset : [[CGFloat]] = [[145, 156, 166, 0, 0, 0, 0, 0], [182, 192, 199, 0, 0, 0, 0, 0]]
            
        var body: some View {
            ForEach(0...1, id: \.self) { row in
                ZStack(alignment: .leading) {
                    HStack {
                        ExampleDeductionText(name: "\(row == 0 ? "Common Word" : "Guessed Encryption"): \(row == 0 ? "Wetterbericht" : "btqbggywcryb")")
                            .padding(insets: [row == 0 ? 10 : 1,16,0,0])
                        Spacer()
                    }
                    RedLine().offset(x: count < 5 ? letteroffset[row][count]: 400, y: row == 0 ? 15: 11)
                }
            }
        }
    }

    //MARK: - Deduction Keys
    struct DeductionKeys: View {
        let parent: Deduction
        var body: some View {
            HStack {
                Icon(name: "\(parent.keys[0]).square", width: Deduction.sizeOfKeys, color: .primary)
                    .opacity(parent.fadeOut[0] ? 0 : 1)
                    .animation(.easeInOut(duration: parent.keyDuration))
                    .rotation3DEffect(Angle(degrees: parent.rotationValue[0]), axis: (x: 1, y: 0, z: 0.0))
                Icon(name: "arrow.forward", width: Deduction.sizeOfKeys, ratio: 60/76)
                Icon(name: "\(parent.keys[1]).square", width: Deduction.sizeOfKeys, color: .primary)
                    .opacity(parent.fadeOut[1] ? 0 : 1)
                    .animation(.easeInOut(duration: parent.keyDuration))
                    .rotation3DEffect(Angle(degrees: parent.rotationValue[1]), axis: (x: 1, y: 0, z: 0.0))
                Icon(name: "arrow.left.arrow.right.square.fill", width: Deduction.sizeOfKeys*1.4)
                    .background(Color.white.cornerRadius(Deduction.sizeOfKeys*0.7))
                Icon(name: "\(parent.keys[2]).square", width: Deduction.sizeOfKeys, color: .primary)
                    .opacity(parent.fadeOut[2] ? 0 : 1)
                    .animation(Animation.easeInOut(duration: parent.keyDuration).delay(0))
                    .rotation3DEffect(Angle(degrees: parent.rotationValue[2]), axis: (x: 1, y: 0, z: 0.0))
                Icon(name: "arrow.forward", width: Deduction.sizeOfKeys, ratio: 60/76)
                Icon(name: "\(parent.keys[3]).square", width: Deduction.sizeOfKeys, color: .primary)
                    .opacity(parent.fadeOut[3] ? 0 : 1)
                    .animation(Animation.easeInOut(duration: parent.keyDuration).delay(0))
                    .rotation3DEffect(Angle(degrees: parent.rotationValue[3]), axis: (x: 1, y: 0, z: 0.0))
            }
        }
    }

    //MARK: - Next Button
    struct NextButton: View {
        let parent: Deduction
        var body: some View {
            Button(action: {
                parent.handlePress()
            }, label: {
                OKButton(text: parent.buttonName)
                    .rotation3DEffect(Angle(degrees: Double(parent.buttonStep * 360)), axis: (x: 0.0, y: 1.0, z: 0.0))
                    .padding(insets: [0,0,10,0])
            })
        }
    }

    //MARK: - Deduction Connections
    struct DeductionConnections: View {
        let parent: Deduction
        
        var body: some View {
            CText(text: "Connections", font: .title, weight: .bold, foregroundColor: .blue)
                .padding(insets: [12,0,0,0])
            
            ScrollView(content: {
                GridStack(rows: Int((Double(parent.connections.count) / 2)+0.5), columns: 2) { row, col in
                    if ((row * 2)+col) > parent.connections.count-1 {
                        ConnectionRow(parent: parent, indx: (row*2), hidden: true)
                        // Empty 2nd column
                    } else {
                        ConnectionRow(parent: parent, indx: (row * 2 + col))
                    }
                }
            })
        }
    }

    //MARK: - Deduction ProgressView
    struct DeductionProgressView: View {
        let parent: Deduction
        
        var body: some View {
            ProgressView("Trying \(parent.step < 11 ? "plugboard": "rotor") settings (\(Int(parent.outKeyIndex)+1)/\(parent.step < 11 ? "26" : "26³"))", value: parent.outKeyIndex, total: parent.step >= 11 ? 17576.0 : 25.0)
                .transition(.slide)
                .animation(Animation.easeOut(duration: 1.5))
        }
    }

}

//MARK: - Connection Row
fileprivate struct ConnectionRow: View {
    let parent: Deduction
    var indx: Int
    var hidden = false
    
    var body: some View {
        HStack {
            Icon(name: "\(indx+1).circle", width: Deduction.sizeOfKeys*3/4, color: parent.connections[indx].isCorrupted ? .red: .primary)
            Icon(name: "\(parent.connections[indx].letter1).square", width: Deduction.sizeOfKeys, color: parent.connections[indx].isCorrupted ? .red: .primary)
            Icon(name: "arrow.forward", width: Deduction.sizeOfKeys, ratio: 60/76)
            Icon(name: "\(parent.connections[indx].letter2).square", width: Deduction.sizeOfKeys, color: parent.connections[indx].isCorrupted ? .red: .primary)
        }.frame(width: 180, height: 35)
        .opacity(hidden ? 0: 1)
    }
}

//MARK: Connection Grid Stack
fileprivate struct GridStack<Content: View>: View {
    let rows: Int
    let columns: Int
    let content: (Int, Int) -> Content

    var body: some View {
        VStack {
            ForEach(0 ..< rows, id: \.self) { row in
                HStack {
                    ForEach(0 ..< self.columns, id: \.self) { column in
                        self.content(row, column)
                    }
                }
            }
        }
    }

    init(rows: Int, columns: Int, @ViewBuilder content: @escaping (Int, Int) -> Content) {
        self.rows = rows
        self.columns = columns
        self.content = content
    }
}


//MARK: - Activity Indicator
struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: .large)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
