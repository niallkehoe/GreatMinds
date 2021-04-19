//
//  LiveView.swift
//  EnigmaProject
//
//  Created by Niall Kehoe
//

import BookCore
import PlaygroundSupport
import SwiftUI
import Combine
import QuartzCore

import UIKit
import ARKit
import RealityKit
import AVFoundation
import SpriteKit

extension UIColor {
    var suColor: Color { Color(self) }
}

public struct ARPlane {
    var anchor: ARPlaneAnchor
    var anchorEntity: AnchorEntity
    var entity: ModelEntity
}

public extension float4x4 {
    func toTranslation() -> SIMD3<Float> {
        return [self[3,0], self[3,1], self[3,2]]
    }

    func toQuaternion() -> simd_quatf {
        return simd_quatf(self)
    }
}

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

extension Image {
    /**
     Modifies Tint of  Images
     - Parameter col: The desired tint color
     */
    func colourImage(col: Color) -> some View {
        self
            .resizable()
            .renderingMode(.template)
            .foregroundColor(col)
    }
}
class Lighting: Entity, HasDirectionalLight, HasAnchoring {
    required init() {
        super.init()
        self.light = DirectionalLightComponent(color: .white, intensity: 1000, isRealWorldProxy: true)
    }
}
extension ARView: ARCoachingOverlayViewDelegate {
    /**
     Adds ARCoaching to Scene
     */
    func addCoaching() {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.delegate = self
        coachingOverlay.session = self.session
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        coachingOverlay.goal = .horizontalPlane
        self.addSubview(coachingOverlay)
    }
    
    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) { }
}

public final class CoordinatorAR: NSObject, ObservableObject, ARSessionDelegate {

    weak var arView: ARView?
    var parentEnt : Entity?
    private var selectedPlane: ARPlane?
    private var planes = [ARPlane]()
    public static let current = CoordinatorAR()
    private var hasBeenReset = false
    
    /**
     Load ARScene
     */
    func loadScene() {
        guard let arView = arView, let parentEntity = parentEnt else { return } // Modification here

        if selectedPlane?.anchorEntity.parent != nil {
            selectedPlane?.anchorEntity.removeFromParent()
        }
        
        let light = Lighting()
        light.orientation = simd_quatf(angle: .pi/8, axis: [0, 1, 0])

        let directLightAnchor = AnchorEntity()
        directLightAnchor.addChild(light)

        parentEntity.addChild(directLightAnchor)
         
        let rotationEulers = self.arView?.session.currentFrame?.camera.eulerAngles
        let mirroredRotation = Transform(pitch: 0, yaw: rotationEulers!.y, roll: 0)
        arView.scene.anchors.forEach { view in
            view.orientation = mirroredRotation.rotation
        }
        
        if let plane = selectedPlane {
            plane.anchorEntity.addChild(parentEntity)
            arView.scene.addAnchor(plane.anchorEntity)
        }
    }

    /**
     Loads Reality Composer File
     */
    func loadFile() throws {
        let url = Bundle.main.url(forResource: "SpecialRelativity", withExtension: "reality")
        let specialRelativity = try! Entity.load(contentsOf: url!)
        specialRelativity.scale = SIMD3<Float>(0.8, 0.8, 0.8)
        parentEnt = specialRelativity
    }
    
    func loadProcess() {
        do {
           try loadFile()
        } catch { }
    }
    
    public override init() {
        super.init()
        loadProcess()
    }

    /**
     Touch of ARPlane
     */
    @objc func PlaneTouch() {
        Tapped()
    }
    /**
     Add Btn Pressed
     */
    @objc func Tapped() {
        guard let arView = arView else { return }

        let touchInView = CGPoint(x: arView.center.x, y: arView.center.y)
        let hitEntities = arView.entities(at: touchInView)
        guard let hitEntity = hitEntities.first, let plane = planes.first(where: { $0.entity == hitEntity }) else {
            return
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "add"), object: nil)

        /// Remove planes
        planes.forEach { plane in
            plane.entity.removeFromParent()
        }

        selectedPlane = plane
        if selectedPlane != nil {
            if hasBeenReset {
                loadProcess()
            }
            loadScene()
        }
    }

    /**
     Add Plane To Scene
     */
    func addPlane(for anchor: ARPlaneAnchor) {
        let planeEntity = addPlaneEntity(for: anchor)
        updatePlaneEntity(planeEntity.entity, for: anchor)
        let plane = ARPlane(anchor: anchor, anchorEntity: planeEntity.anchorEntity, entity: planeEntity.entity)
        planes.append(plane)
    }

    func addPlaneEntity(for anchor: ARPlaneAnchor) -> (anchorEntity: AnchorEntity, entity: ModelEntity) {
        let planeMesh = MeshResource.generatePlane(width: 0, depth: 0.0005)

        let planeEntity = ModelEntity(mesh: planeMesh)

        let material = SimpleMaterial(color: #colorLiteral(red: 0, green: 1, blue: 0.6464101672, alpha: 1).withAlphaComponent(0.4), roughness: 0.9, isMetallic: false)
        
        planeEntity.model?.materials = [material]
        planeEntity.generateCollisionShapes(recursive: true)

        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(planeEntity)
        

        arView?.scene.addAnchor(anchorEntity)
        return (anchorEntity: anchorEntity, entity: planeEntity)
    }

    private func updatePlaneEntity(_ planeEntity: ModelEntity, for anchor: ARPlaneAnchor) {
        let position = anchor.transform.toTranslation()
        let orientation = anchor.transform.toQuaternion()
        let rotatedCenter = orientation.act(anchor.center)

        planeEntity.transform.translation = position + rotatedCenter
        planeEntity.transform.rotation = orientation

        planeEntity.model?.mesh = MeshResource.generatePlane(width: anchor.extent.x, depth: anchor.extent.z)

        planeEntity.collision = nil
        planeEntity.generateCollisionShapes(recursive: true)
        
    }

    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        let planeAnchors = anchors.compactMap { $0 as? ARPlaneAnchor }
        for planeAnchor in planeAnchors {
            let extent = simd_length(planeAnchor.extent)
            guard extent > 0.5 else { continue }

            addPlane(for: planeAnchor)
        }
    }

    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        let planeAnchors = anchors.compactMap { $0 as? ARPlaneAnchor }
        for planeAnchor in planeAnchors {
            let extent = simd_length(planeAnchor.extent)
            guard extent > 0.5 else { continue }

            let existingPlanes = planes.enumerated().filter { $0.element.anchor.identifier == planeAnchor.identifier }
            if let existingPlane = existingPlanes.first {
                let entity = existingPlane.element.entity
                updatePlaneEntity(entity, for: planeAnchor)
                planes[existingPlane.offset] = ARPlane(anchor: planeAnchor, anchorEntity: existingPlane.element.anchorEntity, entity: entity)
            } else {
                addPlane(for: planeAnchor)
            }
        }
    }

    public func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        let anchorIdentifiers = anchors.map { $0.identifier }
        planes
            .filter { plane in anchorIdentifiers.contains(plane.anchor.identifier) }
            .forEach { plane in
                plane.entity.removeFromParent()
        }
        planes.removeAll { plane in anchorIdentifiers.contains(plane.anchor.identifier) }
    }
    
    /**
     Restarts Scene
     */
    @objc func resetTracking() {
        hasBeenReset = true
        
        arView?.scene.anchors.forEach { anchor in
            anchor.removeFromParent()
        }
        if let configuration = arView?.session.configuration {
            arView?.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }
    }
}

struct ARViewContainer: UIViewRepresentable {

    @ObservedObject private var engine = CoordinatorAR.current

    public func makeCoordinator() -> CoordinatorAR {
        engine
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        arView.addCoaching()
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        config.environmentTexturing = .automatic
        arView.session.run(config, options: [])
        
        arView.session.delegate = context.coordinator

        let supportedVideoFormats = ARWorldTrackingConfiguration.supportedVideoFormats
            .filter { $0.captureDevicePosition == .back }
        config.videoFormat = supportedVideoFormats.last ?? config.videoFormat
        config.providesAudioData = false
        
        let scaleFactor = arView.contentScaleFactor
        arView.contentScaleFactor = scaleFactor * 0.5

        arView.renderOptions.insert(.disableMotionBlur)
        arView.debugOptions = [ARView.DebugOptions.showFeaturePoints]

        let tapGestureRecognizer = UITapGestureRecognizer(target: engine, action: #selector(CoordinatorAR.Tapped))
        arView.addGestureRecognizer(tapGestureRecognizer)
        
        NotificationCenter.default.addObserver(engine, selector: #selector(CoordinatorAR.Tapped), name: Notification.Name(rawValue: "addPressed"), object: nil)
        NotificationCenter.default.addObserver(engine, selector: #selector(CoordinatorAR.resetTracking), name: Notification.Name(rawValue: "reset"), object: nil)

        context.coordinator.arView = arView
        return arView


    }

    func updateUIView(_ uiView: ARView, context: Context) {}

}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

struct ShakeEffect: GeometryEffect {
    var shakes: CGFloat
    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }
    init(shakes: Int) {
        self.shakes = CGFloat(shakes)
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        return ProjectionTransform(CGAffineTransform(translationX: -15 * sin(shakes * 8 * .pi), y: 0))
    }
}

struct ImgBtn: View {
    var name: String
    var body: some View {
        Image(systemName: "\(name)")
            .colourImage(col: Color.yellow)
            .frame(width: 30, height: 60)
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            .background(Color.clear)
    }
}

struct RelativityButton: View {
    var text: String = "Next"
    var font: Font = .title

    var body: some View {
        HStack {
            if text == "Lightning" {
                ImgBtn(name: "bolt.fill")
            }

            Text(text)
                .font(font)
                .fontWeight(.bold)
                .foregroundColor(text == "Lightning" ? .yellow: .white)
                .padding()

            if text == "Lightning" {
                ImgBtn(name: "bolt.fill")
            }
        }
        .frame(height: text == "Lightning" ? 75: 60)
        .background(text == "Next" ? .blue: #colorLiteral(red: 0.08348739892, green: 0.08350928873, blue: 0.0834844932, alpha: 1).suColor)
        .foregroundColor(.white)
        .cornerRadius(15)
    }
}

struct Ping: View {
    var left: Bool
    var maxDistance: Double
    var maxTime: Double = 10
    @State var animate = false
    var body: some View {
        Circle()
            .trim(from: (!animate ? 0.5: 0.625) - (left ? 0 : 0.5), to: (!animate ? 1:0.875) - (left ? 0 : 0.5))
            .stroke(Color.yellow ,style: StrokeStyle(lineWidth: 3, lineCap: .butt, dash: [5,3], dashPhase: 10))
            .frame(width: self.animate ? (CGFloat(maxDistance)*2): 0, height: self.animate ? (CGFloat(maxDistance)*2): 0)
            .rotationEffect(Angle(degrees: 90))
            .onAppear {
                withAnimation(.linear(duration: maxTime)) {
                    self.animate.toggle()
                }
            }
    }
}

final class SmokeScene : SKScene {
    override func didMove(to view: SKView) {
        self.backgroundColor = .clear
        self.view?.allowsTransparency = true
        
        if let rainParticles = SKEmitterNode(fileNamed: "TrainSmoke.sks") {
            rainParticles.position = CGPoint(x: size.width*0.85, y: 0)
            rainParticles.name = "smoke"
            rainParticles.targetNode = scene
            rainParticles.position.y = 0

            addChild(rainParticles)
        }
    }
}

struct Train: View {
    @State private var wheelRotating = false
    
    private var scene: SmokeScene {
        let scene = SmokeScene()
        scene.size = CGSize(width: 300, height: 500)
        scene.scaleMode = .fill
        scene.backgroundColor = .clear
        return scene
    }
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene, transition: nil, isPaused: false, preferredFramesPerSecond: 60, options: [.allowsTransparency], shouldRender: {_ in return true})
                .frame(width: 300, height: 500)
                .edgesIgnoringSafeArea(.all)
                .cornerRadius(10)
                .background(Color.clear)
                .offset(x: 100 * 900/602 * -0.55, y: -80 - 200)
            
            Image("train")
                .resizable()
                .frame(width: 100 * 900/602, height: 100)
            
            Group {
                ZStack {
                    Image("wheel")
                            .resizable()
                            .frame(width: 100 * 200/602, height: 100 * 200/602)
                            .rotationEffect(Angle(degrees: wheelRotating ? 360 : 180))
                        .offset(x: -13, y: 30)
                    
                    Image("wheel")
                        .resizable()
                        .frame(width: 100 * 200/602, height: 100 * 200/602)
                        .rotationEffect(Angle(degrees: wheelRotating ? 360 : 180))
                        .offset(x: -52, y: 30)
                }
            }
        }.onAppear {
            withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
                wheelRotating = true
            }
        }
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.size.height/2))
        path.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height/2))
        
        return path
    }
}

struct SRStationary: View {
    var stage : Int
    var parent: RelativityExplainationHolder
    @State private var radius : CGFloat = 10
    @State private var destinationReached = false
    @State private var lightningShown = false
    @State private var pingStart = false

    private func stationaryObserver() {
        pingStart = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            withAnimation(Animation.easeInOut(duration: 1)) {
                self.destinationReached = true
            }
            self.parent.stationaryReached()
        }
    }
    /**
     Begin Stationary Simulation
     */
    private func startup() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.1)) {
                lightningShown = true
            }
            playSound("Thunder")

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                stationaryObserver()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        lightningShown = false
                    }
                }
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Text("With a stationary observer, the two beams of light reach the person at the same time. Therefore, they perceive the lightning strikes as simultaneous.")
                    .foregroundColor(.yellow)
                    .font(.headline).fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .frame(width: geometry.size.width * 0.6, height: geometry.size.height*0.2)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.yellow, lineWidth: 5)
                            .background(Color.clear)
                            .padding(2)
                    )
                    .offset(y: -geometry.size.height + geometry.size.height*0.23)
                    .opacity(destinationReached ? 1:0)
                
                ForEach([-1,1], id: \.self) { no in

                    Group {
                        Line()
                            .stroke(#colorLiteral(red: 0, green: 0.5742132664, blue: 0.3003304601, alpha: 1).suColor,lineWidth: 6)
                            .zIndex(-10)
                    }
                    .offset(y: (geometry.size.height*0.5) - 3)

                    Group {
                        Image("exclamation")
                            .resizable()
                            .frame(width: destinationReached ? 35*206/182: 0, height: destinationReached ? 35:0)
                            .animation(.interpolatingSpring(stiffness: 350, damping: 5, initialVelocity: 10))
                            .rotationEffect(Angle(degrees: Double(no) * 45))
                    }
                    .offset(x: CGFloat(no) * geometry.size.width * 0.065, y: -80)

                    Group {
                        Image("bolt")
                            .resizable()
                            .frame(width: geometry.size.height * 0.9 * 91/212, height: geometry.size.height * 0.9)
                            .animation(Animation.easeOut(duration: 1))
                            .offset(y: -12)
                            .opacity(lightningShown ? 1:0)
                        Group {
                            Circle().foregroundColor(.orange).frame(width: 10, height: 10)
                            if pingStart {
                                Ping(left: no == -1 ? true: false, maxDistance: Double(geometry.size.width) * 0.38)
                                    .frame(width: radius, height: radius)
                                    .offset(y: -radius/2 - 3)
                            }
                        }

                    }.offset(x: CGFloat(no) * geometry.size.width * 0.38)
                }

                Group {
                    Image("person")
                        .colourImage(col: Color.blue)
                        .frame(width: 110 * 189/466, height: 110)
                }
                .offset(y: -6)

            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(#colorLiteral(red: 0.07459770888, green: 0.07461819798, blue: 0.07459501177, alpha: 1).suColor)
            .cornerRadius(20)
            .onChange(of: stage, perform: { value in
                if stage == 0 {
                    startup()
                }
            })
        }
    }

}

struct SRMoving: View {
    var stage : Int
    var parent: RelativityExplainationHolder
    @State private var radius : CGFloat = 10
    @State private var destinationReached = [false, false]
    @State private var lightningShown = false
    @State private var pingStart = false

    @State private var xMultiplier : CGFloat = -0.1

    static private let speedLight : Double = 0.05
    static private let speedTrain : Double = 0.025
    static private let tleft : Double = 15.2
    static private let tright : Double = 5.066

    /**
     Begin Moving Simulation
     */
    private func start() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.1)) {
                lightningShown = true
            }
            playSound("Thunder")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                movingObserver()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        lightningShown = false
                    }
                }
            }
        }
    }
    private func movingObserver() {
        pingStart = true
        DispatchQueue.main.asyncAfter(deadline: .now() + SRMoving.tright) {
            self.destinationReached[1] = true

        }
        DispatchQueue.main.asyncAfter(deadline: .now() + SRMoving.tleft) {
            self.destinationReached[0] = true
            self.parent.movingReached()
        }

        withAnimation(Animation.linear(duration: SRMoving.tleft)) {
            self.xMultiplier = 0.38
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Text("With a moving observer, the two beams of light reach the person at different times. They see the lightning which they are travelling towards before the lightning they are moving away from.")
                    .foregroundColor(.yellow)
                    .font(.headline).fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .frame(width: geometry.size.width * 0.6, height: geometry.size.height*0.2)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.yellow, lineWidth: 5)
                            .background(Color.clear)
                    )
                    .offset(y: -geometry.size.height + geometry.size.height*0.23)
                    .opacity(destinationReached[0] ? 1:0)
                
                ForEach([-1,1], id: \.self) { no in
                    
                    Line()
                        .stroke(#colorLiteral(red: 0, green: 0.5742132664, blue: 0.3003304601, alpha: 1).suColor,lineWidth: 6)
                        .zIndex(-10)
                        .offset(y: geometry.size.height*0.5 - 3)
                    
                    Group {
                        Image("exclamation")
                            .resizable()
                            .frame(width: destinationReached[no == -1 ? 0 : 1] ? 35*206/182: 0, height: destinationReached[no == -1 ? 0 : 1] ? 35:0)
                            .animation(.interpolatingSpring(stiffness: 350, damping: 5, initialVelocity: 10))
                            .rotationEffect(Angle(degrees: [20, -45][no == -1 ? 0:1]))
                    }
                    .offset(x: geometry.size.width * CGFloat([0.42, SRMoving.tright*SRMoving.speedTrain*0.98][no == -1 ? 0:1]), y: -[120, 100][no == -1 ? 0:1])
                    
                    Group {
                        
                        Image("bolt")
                            .resizable()
                            .frame(width: geometry.size.height * 0.9 * 91/212, height: geometry.size.height * 0.9)
                            .animation(Animation.easeOut(duration: 1))
                            .offset(y: -12)
                            .opacity(lightningShown ? 1:0)
                        Group {
                            Circle().foregroundColor(.orange).frame(width: 10, height: 10)
                            if pingStart {
                                Ping(left: no == -1 ? true: false, maxDistance: Double(geometry.size.width) * [SRMoving.tleft*SRMoving.speedLight, SRMoving.tright*SRMoving.speedLight][no == -1 ? 0 : 1], maxTime: [SRMoving.tleft, SRMoving.tright][no == -1 ? 0 : 1])
                                    .frame(width: radius, height: radius)
                                    .offset(y: -radius/2 - 3)
                            }
                        }
                    }.offset(x: CGFloat(no) * geometry.size.width * 0.38)
                }
                
                Train()
                    .frame(width: 100 * 900/602, height: 100)
                    .offset(x: xMultiplier * geometry.size.width,y: -5)
                
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(#colorLiteral(red: 0.07459770888, green: 0.07461819798, blue: 0.07459501177, alpha: 1).suColor)
            .cornerRadius(20)
            .onChange(of: stage, perform: { value in
                if stage == 2 {
                    start()
                }
            })
            .onAppear {
                withAnimation(Animation.linear(duration: 4)) {
                    self.xMultiplier = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    self.parent.movingFlash()
                }
            }
        }
        
    }

}

struct RelativityExplainationHolder: View {
    @Binding var showVisualisation: Bool
    @State private var animating = false
    @State private var text = "Lightning"
    @State private var showBtn = false
    
    @State private var observer = "Stationary"
    @State private var stage = 0
    
    @State private var btnDeactivated = false
    @State private var shakes = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("\(observer) Observer")
                    .font(.largeTitle).bold()
                    .foregroundColor(.black)
                    .frame(height: 45)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).fill(Color.white))
                
                Group {
                    if stage <= 1 {
                        SRStationary(stage: stage, parent: self)
                    } else {
                        SRMoving(stage: stage, parent: self)
                    }
                }
                .frame(width: geometry.size.width*0.8, height: geometry.size.height*0.65)
                .background(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 4).foregroundColor(.clear))
                .modifier(ShakeEffect(shakes: shakes))
                
                Button(action: {
                    if !btnDeactivated {
                        btnDeactivated = true
                        stage += 1
                        
                        withAnimation(.easeInOut(duration: 1)) {
                            self.showBtn = false
                        }
                        
                        playSound(stage == 1 || stage == 3 ? "Thunder":"Pop")
                        if stage == 2 || stage == 3 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                                playSound("TrainSound")
                            }
                        }
                        
                        if stage == 2 {
                            observer = "Moving"
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation(.easeInOut(duration: 1)) {
                                    self.showBtn = false
                                }
                            }
                            
                        }
                        if stage == 4 {
                            showVisualisation = false
                        }
                        
                        if stage == 1 || stage == 3 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(Animation.linear(duration: 1)) {
                                    self.shakes += 1
                                }
                            }
                        }
                    }
                }, label: {
                    RelativityButton(text: "\(text)")
                        .padding()
                })
                .scaleEffect(animating ? 1.15 : 1)
                .transition(.scale)
                .opacity(showBtn ? 1:0)
            }
            .offset(x: geometry.size.width*0.1, y: geometry.size.height*0.175 - (22.5 + ((text == "Lightning" ? 75:60)/2)))
            .onAppear {
                showBtn = true
                
                withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(0.2), {
                    self.animating.toggle()
                })
            }
        }
    }
    
    /**
    Stationary Observer Simulation Simulated
     */
    func stationaryReached() {
        text = "Next"
        withAnimation(.easeInOut(duration: 1)) {
            showBtn = true
        }
        btnDeactivated = false
    }
    func movingFlash() {
        text = "Lightning"
        withAnimation(.easeInOut(duration: 1)) {
            showBtn = true
        }
        btnDeactivated = false
    }
    /**
    Moving Observer Simulation Simulated
     */
    func movingReached() {
        text = "Next"
        withAnimation(.easeInOut(duration: 1)) {
            showBtn = true
        }
        btnDeactivated = false
    }
}

public struct RelativityView : View {

    public init() { }
    @State private var showVisualisation = true
    
    let addNotif = NotificationCenter.default.publisher(for: Notification.Name("add"))
    @State public var sceneAdded = false
    @State private var size: CGFloat = 0.8
    @State private var showingAlert = false
    @State private var rotation = 0.0
    @State private var btnDisabled = false
    
    @State private var showingAdviceAlert = false
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                ARViewContainer()
                    .edgesIgnoringSafeArea(.all)
                
                ZStack {
                    VStack {
                        Text("Touch the Train to Begin the Simulation")
                            .foregroundColor(.red)
                            .font(.headline).fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .frame(width: geometry.size.width * 0.3, height: geometry.size.height*0.07)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .foregroundColor(Color.white)
                                    .padding(2)
                            )
                        Spacer()
                    }
                }
                .opacity(showingAdviceAlert ? 1:0)
                
                VStack {
                    if !sceneAdded {
                        Spacer()
                    }
                    Button(action: {
                        playSound("Pop")
                        if !sceneAdded {
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "addPressed"), object: nil)
                        } else {
                            /// Reset
                            withAnimation(.linear(duration: 3)) {
                                self.rotation -= 360
                            }
                            showingAlert = true
                        }
                    }, label: {
                        Image(sceneAdded ? "reset":"add")
                            .resizable()
                            .frame(width: sceneAdded ? 60:120, height: sceneAdded ? 60:120)
                            .rotationEffect(Angle.degrees(rotation))
                            .scaleEffect(size)
                            .onAppear() {
                                addAnimation()
                            }
                    }).padding()
                    .offset(x: sceneAdded ? geometry.size.width/2 - 35 : 0)
                    if sceneAdded {
                        Spacer()
                    }
                }
                
                Group {
                    if showVisualisation {
                        VisualEffectView(effect: UIBlurEffect(style: .dark))
                            .edgesIgnoringSafeArea(.all)
                        
                        RelativityExplainationHolder(showVisualisation: $showVisualisation)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }.transition(AnyTransition.opacity.combined(with: .scale))
                
            }.onChange(of: showVisualisation, perform: { value in
                showVisualisation = false
            })
            .onReceive(addNotif) { (output) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                    withAnimation(.easeInOut(duration: 1.2)) {
                        showingAdviceAlert = true
                    }
                }
                if !sceneAdded {
                    sceneChange()
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Reset"), message: Text("Are you sure you want to reset the scene?"), primaryButton: .destructive(Text("Yes!")) {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "reset"), object: nil)
                    
                    sceneChange()
                    addAnimation()
                }, secondaryButton: .default(Text("Never mind")))
            }
        }
    }
    
    /**
    AR Simulation Added / Removed
     */
    func sceneChange() {
        withAnimation(.easeInOut(duration: 1.5)) {
            self.sceneAdded.toggle()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.btnDisabled = false
        }
    }
    /**
    Repeated Scale Animation
     */
    func addAnimation() {
        withAnimation(Animation.easeInOut(duration: 2).repeatCount(4, autoreverses: true)) {
            self.size = 1.1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            withAnimation(Animation.easeInOut(duration: 1)) {
                self.size = 1
            }
        }
    }
}

let view = RelativityView()
PlaygroundPage.current.setLiveView(view)
