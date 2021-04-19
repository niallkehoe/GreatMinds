//
//  ViewController.swift
//  BookCore
//
//  Created by Niall Kehoe on 02/04/2021.
//

import UIKit
import SceneKit
import ARKit
import SpriteKit
import SwiftUI

var globalView : UIViewController = UIViewController()

@objc(BookCore_ViewController)
public final class ViewController: UIViewController, ARSCNViewDelegate {

    // MARK: - Virtual View Declarations
    private let sceneView = SCNView()
    private var scene: SCNScene!
    private var lightNode : SCNNode!
    private var hinge: SCNNode!
    private var rightRotor: SCNNode!
    private var middleRotor: SCNNode!
    private var lid : SCNNode!
    private var open = false
    private var keyInProgress = false
    private var hingedeployed = false
    private var rightRotorPositions = 18
    private var cameraSetup : CameraSetup!
    private var camerainUse: CameraOptions!
    private let ARBadge = UIButton()

    //MARK: Hinges
    private var hingeinProgress = false
    private var ARhingeinProgress = false

    // MARK: - Game
    private let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let plugBoard = SKView()
    private var Gamescene : PlugboardScn!
    private let correctImg = UIImageView()
    private let correctLbl = UILabel()

    // MARK: - AR View
    private let ARsceneView = ARSCNView()
    private let coachingOverlay = ARCoachingOverlayView()
    private var ARlightNode : SCNNode!
    private let addbtn = UIButton()
    private var added = false
    private var ARisOn = false
    private var ARrightRotorPositions = 18
    private var lastRotation: Float = 0

    // MARK: - Encryption
    private let map = Mappings()
    private let armap = Mappings()
    private var encryptedLabel : UITextView!
    private var unencryptedLabel : UITextView!
    private let textbackground = UIView()
    private var message = ""
    private var unencryptedmessage = ""

    // MARK: - Explanation
    private var explanationinProgress = false
    private var childView : UIHostingController<CodeBreakingDemonstration>!

    // MARK: - Layout
    private var initialWidth: CGFloat = 0
    private var lastWidth : CGFloat = 0
    private var ARWidth: NSLayoutConstraint!
    private let keyboardBtn = UIButton()
    private let explanationBtn = UIButton()

    private var topConstraints : [NSLayoutConstraint]!
    
    // MARK: - Instructions
    private let visualEffectView2 = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let videoview = UIView()
    private var avPlayer: AVPlayer!
    private var instructionsShowing = false
    private let OKbtn = UIButton()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        globalView = self

        sceneView.clipsToBounds = true
        self.view.addSubview(sceneView)

        fullScreenSetup(sceneView, superView: view)

        scene = SCNScene(named: "art.scnassets/enigma.scn")!
        sceneView.showsStatistics = false
        sceneView.allowsCameraControl = true
        sceneView.scene = scene

        let camera1 = scene.rootNode.childNode(withName: "camera", recursively: true)!
        let camera2 = scene.rootNode.childNode(withName: "plugBoardcamera", recursively: true)!
        let camera3 = scene.rootNode.childNode(withName: "keyboardCamera", recursively: true)!
        cameraSetup = CameraSetup(cam1: camera1, cam2: camera2, cam3: camera3)
        camerainUse = .normal

        sceneView.pointOfView = camera1

        lightNode = (sceneView.scene?.rootNode.childNode(withName: "Lights", recursively: true))!
        rightRotor = sceneView.scene?.rootNode.childNode(withName: "RotorRight", recursively: true)?.childNode(withName: "rotor", recursively: true)?.childNode(withName: "torus", recursively: true)
        middleRotor = sceneView.scene?.rootNode.childNode(withName: "RotorMiddle", recursively: true)?.childNode(withName: "rotor", recursively: true)?.childNode(withName: "torus", recursively: true)
        hinge = sceneView.scene?.rootNode.childNode(withName: "hinges", recursively: true)!
        lid = sceneView.scene?.rootNode.childNode(withName: "lid", recursively: true)
        lid.runAction(SCNAction.rotateTo(x: 0, y: 0, z: degreesToRadians(90), duration: 1.0))

        resetKeyLights()

        self.view.addSubview(ARsceneView)
        fullScreenSetup(ARsceneView, superView: view)

        keyboardBtn.setImage(UIImage(systemName: "keyboard"), for: .normal)
        keyboardBtn.addTarget(self, action: #selector(keyboardPressed), for: .touchUpInside)
        keyboardBtn.imageView!.contentMode = .scaleAspectFit
        keyboardBtn.contentVerticalAlignment = .fill
        keyboardBtn.contentHorizontalAlignment = .fill
        keyboardBtn.backgroundColor = #colorLiteral(red: 0.9999071956, green: 1, blue: 0.999881804, alpha: 1)
        keyboardBtn.layer.cornerRadius = 12
        self.view.addSubview(keyboardBtn)

        explanationBtn.setBackgroundImage(UIImage(systemName: "rectangle.3.offgrid.bubble.left.fill"), for: .normal)
        explanationBtn.addTarget(self, action: #selector(explanationPressed), for: .touchUpInside)
        explanationBtn.backgroundColor = #colorLiteral(red: 0.9999071956, green: 1, blue: 0.999881804, alpha: 1)
        explanationBtn.layer.cornerRadius = 12
        self.view.addSubview(explanationBtn)

        ARBadge.setBackgroundImage(UIImage(named: "ARBadge1"), for: .normal)
        ARBadge.addTarget(self, action: #selector(ARPush), for: .touchUpInside)
        ARBadge.createCornerRadius(cornerRadius: 10)
        self.view.addSubview(ARBadge)
        
        self.view?.addSubview(visualEffectView)
        fullScreenSetup(visualEffectView, superView: view)

        plugBoard.createCornerRadius(cornerRadius: 10)
        self.view.addSubview(plugBoard)

        centreXandY(plugBoard, superView: view)
        plugBoard.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.65).isActive = true
        plugBoard.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.65 * 0.6).isActive = true

        correctLbl.text = "You've successfully wired the plugboard. To exit just press outside the plugboard."
        correctLbl.textAlignment = .center
        correctLbl.font = .systemFont(ofSize: 18, weight: .bold)
        correctLbl.textColor = #colorLiteral(red: 0, green: 1, blue: 0.5185423493, alpha: 1)
        correctLbl.numberOfLines = 0
        self.view.addSubview(correctLbl)

        centreX(correctLbl, superView: view)
        correctLbl.bottomAnchor.constraint(equalTo: plugBoard.topAnchor, constant: -5).isActive = true
        correctLbl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        attributeSetup(correctLbl.heightAnchor, sideLength: 80)

        correctImg.image = UIImage(systemName: "checkmark.circle.fill")
        correctImg.tintColor = #colorLiteral(red: 0, green: 1, blue: 0.5185423493, alpha: 1)
        self.view.addSubview(correctImg)

        centreX(correctImg, superView: view)
        squareSetup(correctImg, with: 50)
        correctImg.bottomAnchor.constraint(equalTo: correctLbl.topAnchor, constant: -5).isActive = true

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchDetected(_:)))
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotateDetected(_:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panDetected(_:)))
        self.ARsceneView.addGestureRecognizer(pinchGesture)
        self.ARsceneView.addGestureRecognizer(rotationGesture)
        self.ARsceneView.addGestureRecognizer(panGesture)
    }

    public override func viewDidAppear(_ animated: Bool) {
        addbtn.setImage(UIImage(named: "add"), for: .normal)
        addbtn.clipsToBounds = true
        addbtn.addTarget(self, action: #selector(addfunc), for: .touchUpInside)
        self.view.addSubview(addbtn)

        centreX(addbtn, superView: view)
        addbtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -42).isActive = true
        sidesSetup(addbtn, width: 114, height: 120)

        setupEncryptionLabels()

        Gamescene = PlugboardScn(size: plugBoard.frame.size)
        Gamescene.passVC = self
        plugBoard.presentScene(Gamescene)

        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "dismissModal"), object: nil, queue: nil) { (notif) in
            self.showExplanation(to: 0.0)
        }

        squareSetup(keyboardBtn, with: 50)
        keyboardBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        let topConstraint1 = keyboardBtn.topAnchor.constraint(equalTo: view.topAnchor, constant: 10 + self.view.safeAreaInsets.top)

        squareSetup(explanationBtn, with: 50)
        explanationBtn.trailingAnchor.constraint(equalTo: keyboardBtn.leadingAnchor, constant: -10).isActive = true
        let topConstraint2 = explanationBtn.topAnchor.constraint(equalTo: view.topAnchor, constant: 10 + self.view.safeAreaInsets.top)

        translatesAutoresizing(ARBadge)
        attributeSetup(ARBadge.heightAnchor, sideLength: 55)
        ARWidth = ARBadge.widthAnchor.constraint(equalToConstant: 55)
        ARBadge.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12).isActive = true
        let topConstraint3 = ARBadge.topAnchor.constraint(equalTo: view.topAnchor, constant: 7 + self.view.safeAreaInsets.top)
        self.view.addConstraint(ARWidth)

        topConstraints = [topConstraint1, topConstraint2, topConstraint3]
        for constraint in topConstraints {
            self.view.addConstraint(constraint)
        }

        initialWidth = self.view.frame.width
        lastWidth = initialWidth

        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateLayout), userInfo: nil, repeats: true)
        
        self.view?.addSubview(visualEffectView2)
        fullScreenSetup(visualEffectView2, superView: view)
        
        videoview.backgroundColor = .white
        videoview.createCornerRadius(cornerRadius: 12)
        self.view.addSubview(videoview)

        centreXandY(videoview, superView: view)
        videoview.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4).isActive = true
        videoview.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4*322/678).isActive = true
        
        let videoURL = Bundle.main.url(forResource: "Instructions", withExtension: "mp4")
        avPlayer = AVPlayer(url: videoURL! as URL)
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.avPlayer.currentItem, queue: .main) { [weak self] _ in
            self?.avPlayer.seek(to: CMTime.zero)
            self?.avPlayer.play()
        }
        
        OKbtn.setTitle("Got it!", for: .normal)
        OKbtn.titleLabel?.font = UIFont(name: "ArialRoundedMTBold", size: 35)
        OKbtn.titleLabel?.textColor = .white
        OKbtn.backgroundColor = #colorLiteral(red: 0, green: 0.4840524793, blue: 1, alpha: 1)
        OKbtn.layer.cornerRadius = 10
        OKbtn.addTarget(self, action: #selector(OKTapped), for: .touchUpInside)
        self.view.addSubview(OKbtn)
        
        centreX(OKbtn, superView: view)
        OKbtn.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.22).isActive = true
        attributeSetup(OKbtn.heightAnchor, sideLength: 50)
        OKbtn.topAnchor.constraint(equalTo: videoview.bottomAnchor, constant: 10).isActive = true
        
        /// Hide:
        for item in [ARsceneView, visualEffectView, plugBoard, correctLbl, correctImg, addbtn, visualEffectView2, videoview, OKbtn] {
            item.alpha = 0
        }
    }

    /// Check for Move to/from Full Screen
    @objc private func updateLayout() {
        if lastWidth != self.view.frame.width {
            lastWidth = self.view.frame.width
            UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseIn], animations: { [self] in
                for constraint in topConstraints {
                    constraint.constant = 5 + self.view.safeAreaInsets.top
                }
                
                ARBadge.setBackgroundImage(UIImage(named: "ARBadge\(lastWidth > initialWidth ? 2:1)"), for: .normal)
                ARWidth.constant = 55*(lastWidth > initialWidth ? (296/156):1)
                
                self.view.layoutIfNeeded()
            })
        }
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ARsceneView.session.pause()
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if explanationinProgress {
            if touch.view == self.visualEffectView {
                showExplanation(to: 0.0)
            }
        }
        else if instructionsShowing {
            changeInstructional(to: 0)
        }
        else if(touch.view == self.visualEffectView){
            let selectedHingeinProgress = !ARisOn ? hingeinProgress : ARhingeinProgress
            if selectedHingeinProgress == true {
                if Gamescene.wiresRemaining != 0 {
                    shakeAnimation()
                } else {
                    changePlugBoard(to: 0.0)
                }
            }
        }
        else if !ARisOn {
            if (touch.view == self.sceneView) && !hingeinProgress  {
                keyTest(touch: touch, view: sceneView) {
                    moveWheel()
                }
            }
        } else if added {
            //AR is On
            if(touch.view == self.ARsceneView) && !ARhingeinProgress {
                keyTest(touch: touch, view: ARsceneView) {
                    ARmoveWheel()
                }
            }
        }
    }

    /** Test if key pressed
     - Parameter touch: location of touch
     - Parameter view: view of touch
     - Parameter task: functon to call upon detection
    */
    private func keyTest(touch: UITouch, view: SCNView, task: () -> Void) {
        let viewTouchLocation:CGPoint = touch.location(in: view)
        guard let result = view.hitTest(viewTouchLocation, options: nil).first else { return }
        if open == true {
            if !keyInProgress {
                for ltr in "abcdefghijklmnopqrstuvwxyz" {
                    for indx in 0...3 {
                        if let Node = view.scene?.rootNode.childNode(withName: "Keys", recursively: true)!.childNode(withName: "key\(ltr)", recursively: true)?.childNodes[indx], Node == result.node {
                            standardKeyClick(ltr: "\(ltr)")
                            task()
                            break
                        }
                    }
                }

                // Front Panel
                if Gamescene.wiresRemaining != 0 {
                    guard let Node1 = view.scene!.rootNode.childNode(withName: "hinges", recursively: true)!.childNode(withName: "frontboxwall", recursively: true) else { return }
                    guard let Node2 = view.scene?.rootNode.childNode(withName: "plugboard", recursively: true) else { return }
                    if Node1 == result.node || Node2 == result.node {
                        editPlugBoard()
                    }
                }
            }
        } else {
            // Open Case
            playSound("WoodenBoxOpening")
            lid.runAction(SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 5.0))
            open = true
        }
    }

    /// Shake Vibration Effect
    private func shakeAnimation() {
        let anim = CABasicAnimation(keyPath: "position")
        anim.duration = 0.07
        anim.repeatCount = 4
        anim.autoreverses = true
        anim.fromValue = NSValue(cgPoint: CGPoint(x: plugBoard.center.x - 10, y: plugBoard.center.y))
        anim.toValue = NSValue(cgPoint: CGPoint(x: plugBoard.center.x + 10, y: plugBoard.center.y))

        plugBoard.layer.add(anim, forKey: "position")
    }

    // MARK: - Augmented Reality

    /// ARButton Pressed
    @objc private func ARPush() {
        ARisOn.toggle()
        added = false
        open = true
        if ARisOn {
            /// congigure AR Lighting
            ARsceneView.autoenablesDefaultLighting = true
            ARsceneView.automaticallyUpdatesLighting = true
            
            setUpARSceneView()
        }
        ARAnimationAlter()
    }

    /// Setup AR Scene View
    private func setUpARSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        ARsceneView.session.run(configuration)
        ARsceneView.delegate = self
        ARsceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

        coachingOverlay.session = ARsceneView.session
        coachingOverlay.delegate = self

        translatesAutoresizing(coachingOverlay)
        ARsceneView.addSubview(coachingOverlay)

        fullScreenSetup(coachingOverlay, superView: view)

        coachingOverlay.activatesAutomatically = true
        coachingOverlay.goal = .horizontalPlane
    }

    /// Add Btn Pressed
    @objc private func addfunc() {
        addEnigmaMachineToSceneView(location: CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2))
        //Allow user to scale and rotate the object swift, add feature
        playSound("Pop")
        if added {
            ARAnimationAlter()
            resetKeyLights()
        }
    }

    private func ARAnimationAlter(){
        UIView.animate(withDuration: 1.0) { [self] in
            for viewpassed in [self.encryptedLabel, self.unencryptedLabel, self.textbackground] {
                viewpassed!.alpha = !ARisOn ? 1:0
            }
            self.addbtn.alpha = !added && ARisOn ? 1 : 0
            self.ARsceneView.alpha = ARisOn ? 1 : 0
            self.ARBadge.setBackgroundImage(UIImage(named: ARisOn ? "ViewBadge": "ARBadge2"), for: .normal)
            self.ARWidth.constant = 55*(296/156)
        }
    }

    private func addEnigmaMachineToSceneView(location: CGPoint) {
        let hitTestResults : ARRaycastQuery? = ARsceneView.raycastQuery(from: location, allowing: .existingPlaneGeometry, alignment: .horizontal)

        guard let nonOptQuery: ARRaycastQuery = hitTestResults else { return }
        let result: [ARRaycastResult] = ARsceneView.session.raycast(nonOptQuery)

        guard let rayCast: ARRaycastResult = result.first else { return }
        added = true

        let enigmaScene = SCNScene(named: "art.scnassets/enigma.scn")
        let enigma = EnigmaMachine(scene: enigmaScene!)
        enigma.name = "enigma"
        enigma.position = SCNVector3(rayCast.worldTransform.columns.3.x, rayCast.worldTransform.columns.3.y, rayCast.worldTransform.columns.3.z)

        guard let frame = self.ARsceneView.session.currentFrame else { return }
        enigma.eulerAngles.y = frame.camera.eulerAngles.y+90 // 90 is not the right number, adjust it
        lastRotation = enigma.eulerAngles.y

        enigma.scale = SCNVector3(x: 0.2, y: 0.2, z: 0.2)

        ARsceneView.scene.rootNode.addChildNode(enigma)
        ARlightNode = enigma.lightNode

        let spotLight = SCNNode()
        spotLight.light = SCNLight()
        spotLight.scale = SCNVector3(1,1,1)
        spotLight.light?.intensity = 300
        spotLight.castsShadow = true
        spotLight.position = SCNVector3Zero
        spotLight.light?.type = SCNLight.LightType.ambient
        spotLight.light?.color = UIColor.white
        ARsceneView.scene.rootNode.addChildNode(spotLight)
    }

    // MARK: - ARSCNViewDelegate
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        let plane = Plane(anchor: planeAnchor, in: ARsceneView)
        node.addChildNode(plane)
        
        doAddedCheck(plane: plane)
    }

    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, let plane = node.childNodes.first as? Plane else { return }

        if let planeGeometry = plane.meshNode.geometry as? ARSCNPlaneGeometry {
            planeGeometry.update(from: planeAnchor.geometry)
        }

        if let extentGeometry = plane.extentNode.geometry as? SCNPlane {
            extentGeometry.width = CGFloat(planeAnchor.extent.x)
            extentGeometry.height = CGFloat(planeAnchor.extent.z)
            plane.extentNode.simdPosition = planeAnchor.center
        }
        doAddedCheck(plane: plane)
    }
    
    private func doAddedCheck(plane: Plane) {
        if added == true {
            plane.meshNode.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
            plane.meshNode.opacity = 0.0
            plane.opacity = 0.0
            plane.meshNode.geometry?.firstMaterial?.shaderModifiers?.removeAll()
        }
    }

    // MARK: - ARSessionObserver

    public func sessionWasInterrupted(_ session: ARSession) { }

    public func sessionInterruptionEnded(_ session: ARSession) {
        resetTracking()
    }

    public func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }

        print(error)
    }

    //MARK: - AR Methods
    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        ARsceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    //MARK: - Pinch and Pan Gestures
    @objc private func pinchDetected(_ gesture: UIPinchGestureRecognizer) {
        let node = ARsceneView.scene.rootNode.childNode(withName: "enigma", recursively: false)!
        switch gesture.state {
            case .began:
                gesture.scale = CGFloat(node.scale.x)
            case .changed:
                var newScale: SCNVector3
                if gesture.scale > 3 {
                    newScale = SCNVector3(2, 2, 2)
                } else {
                    newScale = SCNVector3(gesture.scale, gesture.scale, gesture.scale)
                }
                node.scale = newScale
            default:
                break
        }
    }

    @objc private func rotateDetected(_ gesture: UIRotationGestureRecognizer) {
        rotateNode(gesture: gesture, rotation: Float(gesture.rotation))
    }
    private var rotationAngle: CGFloat = 90
    @objc private func panDetected(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: view)
        let gestureRotation = CGFloat(angle(from: location)) - rotationAngle
        if gesture.state == .began { rotationAngle = angle(from: location) }
        rotateNode(gesture: gesture, rotation: Float(degreesToRadians(gestureRotation)))
    }

    private func angle(from location: CGPoint) -> CGFloat {
        let deltaY = location.y - view.center.y
        let deltaX = location.x - view.center.x
        let angle = atan2(deltaY, deltaX) * 180 / .pi
        return angle < 0 ? abs(angle) : 360 - angle
    }

    private func rotateNode(gesture: UIGestureRecognizer, rotation: Float) {
        let node = ARsceneView.scene.rootNode.childNode(withName: "enigma", recursively: false)!
        switch gesture.state {
            case .changed:
                node.eulerAngles.y = self.lastRotation + rotation
            case .ended:
                self.lastRotation += rotation
            default :
                break
        }
    }

    @objc private func explanationPressed() {
        if let childView = childView {
            childView.removeFromParent()
        }
        childView = UIHostingController(rootView: CodeBreakingDemonstration())
        addChild(childView)

        view.addSubview(childView.view)
        childView.didMove(toParent: self)

        childView.view.alpha = 0.0
        childView.view.createCornerRadius(cornerRadius: 10)

        centreXandY(childView.view, superView: view)
        attributeSetup(childView.view, superView: view, Xmultiplier: 0.4, Ymultiplier: 0.8)

        showExplanation(to: 1.0)
    }
    private func showExplanation(to alpha: CGFloat) {
        explanationinProgress.toggle()
        UIView.animate(withDuration: 1.0) { [self] in
            for item in [childView.view, visualEffectView] {
                item?.alpha = alpha
            }
        }
    }
    
    //MARK: - Plugboard Functions
    public func sucessfullyWiredBox() {
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]

        UIView.transition(with: self.correctLbl, duration: 1.0, options: transitionOptions, animations: {
            self.correctLbl.alpha = 1.0
        })
        UIView.transition(with: self.correctImg, duration: 1.0, options: transitionOptions, animations: {
            self.correctImg.alpha = 1.0
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            self.changePlugBoard(to: 0.0)
        }
    }
}

private extension ViewController {
    //MARK: - Setup

    final func setupEncryptionLabels() {
        textbackground.backgroundColor = #colorLiteral(red: 0.1125097051, green: 0.1125361994, blue: 0.1125062183, alpha: 1)
        self.view.insertSubview(textbackground, belowSubview: visualEffectView)

        centreX(textbackground, superView: view)
        textbackground.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        textbackground.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        attributeSetup(textbackground.heightAnchor, sideLength: 100)

        func createLabels() -> UITextView {
            let lbl = UITextView()
            lbl.backgroundColor = .clear
            lbl.isUserInteractionEnabled = false
            lbl.textColor = #colorLiteral(red: 0, green: 0.9987453818, blue: 0.4437932074, alpha: 1)
            lbl.font = UIFont.systemFont(ofSize: 19, weight: .semibold)

            return lbl
        }
        func addStanardAttributes(txtView: UITextView) {
            centreX(txtView, superView: view)
            txtView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
            attributeSetup(txtView.heightAnchor, sideLength: 50)
        }

        encryptedLabel = createLabels()
        self.view.insertSubview(encryptedLabel, belowSubview: visualEffectView)
        addStanardAttributes(txtView: encryptedLabel)
        encryptedLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        unencryptedLabel = createLabels()
        self.view.insertSubview(unencryptedLabel, belowSubview: visualEffectView)
        addStanardAttributes(txtView: unencryptedLabel)
        unencryptedLabel.bottomAnchor.constraint(equalTo: encryptedLabel.topAnchor).isActive = true
        unencryptedLabel.text = "Type your message using the machine's keyboard"
    }
}


private extension ViewController {
    //MARK: - Extensions

    //MARK: - Toolbar Actions
    @objc final func keyboardPressed() {
        if camerainUse == CameraOptions.normal {
            sceneView.allowsCameraControl = false
            moveToCameraposition(cameraSetup.keyboardCamera)
            camerainUse = .keyboard
        } else if camerainUse == CameraOptions.keyboard {
            sceneView.allowsCameraControl = true
            moveToCameraposition(cameraSetup.normalCamera)
            camerainUse = .normal
        }
    }

    //MARK: - Scene Functions
    final func changeHinge(to: Camera) {
        if ARisOn {
            ARhingeinProgress = to.name == "plugboard" ? true : false
        } else {
            hingeinProgress = to.name == "plugboard" ? true : false
        }
    }

    //MARK: - Camera Actions
    final func moveToCameraposition(_ to: Camera) {
        let camera = sceneView.scene?.rootNode.childNode(withName: "camera", recursively: true)
        sceneView.pointOfView = camera
        sceneView.allowsCameraControl = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.sceneView.allowsCameraControl = to.name == "camera" ? true : false
        }

        let action1 = SCNAction.move(to: to.position, duration: 3.0)
        let action2 = SCNAction.rotateTo(x: CGFloat(to.rotation.x), y: CGFloat(to.rotation.y), z: CGFloat(to.rotation.z), duration: 3.0)
        let group = SCNAction.group([action1, action2])
        camera!.runAction(group)

        camerainUse = to.name == "camera" ? CameraOptions.normal : to.name == "plugboard" ? CameraOptions.plugboard : CameraOptions.keyboard
    }

    //MARK: - Key Presses
    final func standardKeyClick(ltr: String) {
        //Encrypt the message and then light that light
        playSound("Typewriter")
        unencryptedmessage = unencryptedmessage + "\(ltr)"
        let encrypted = encrypt(ltr: "\(ltr)")
        changeLightIntensity(letter: "\(encrypted)", setting: true)
        TurnOffTimer(letter: "\(encrypted)")
    }

    /// Turn Light Off/On
    /// - Parameters:
    ///   - letter: Letter of Key
    ///   - setting: On/Off
    final func changeLightIntensity(letter: String, setting: Bool = false) {
        let lightnode = !ARisOn ? lightNode! : ARlightNode!
        let omniLight = lightnode.childNode(withName: "\(letter)light", recursively: true)?.childNode(withName: "omni", recursively: true)!.light!
        let textNode = lightnode.childNode(withName: "\(letter)light", recursively: true)?.childNode(withName: "\(letter)txt", recursively: true)!.geometry as! SCNText
        if !setting {
            omniLight?.intensity = 0
            textNode.materials.first?.diffuse.contents = #colorLiteral(red: 0.9546430707, green: 0.9548028111, blue: 0.9546220899, alpha: 1)
        } else {
            keyInProgress = true

            omniLight?.intensity = !ARisOn ? 0.069 : 0.01
            textNode.materials.first?.diffuse.contents = #colorLiteral(red: 0.2072313428, green: 0.2072727978, blue: 0.2072258592, alpha: 1)
            message = message + letter

            UIView.animate(withDuration: 1.0) {
                self.encryptedLabel.text = "Encrypted Message: \(self.message)"
                self.unencryptedLabel.text = "Unencrypted Message: \(self.unencryptedmessage)"
            }
        }
    }
    final func TurnOffTimer(letter: String) {
        Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(turnoff(timer:)), userInfo: letter, repeats: false)
    }
    @objc final func turnoff(timer: Timer) {
        let letter = timer.userInfo as! String
        changeLightIntensity(letter: letter, setting: false)
        keyInProgress = false
    }

    final func moveMiddleRotorForward() {
        let maptype = !ARisOn ? map : armap //replaced map with maptype
        let lastValue = maptype.mapping2[25]

        for indx in (0...25).reversed() {
            if indx != 0 {
                maptype.mapping2[indx] = maptype.mapping2[indx-1]
            } else {
                maptype.mapping2[0] = lastValue
            }
        }
    }

    final func moveWheel() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
            if rightRotorPositions == 25 {
                rightRotorPositions = 0
                //rotate Middle Rotor 1 position
                middleRotor.runAction(SCNAction.rotateBy(x: 0, y: 0, z: degreesToRadians(-13.846), duration: 0.8))
                moveMiddleRotorForward()
            } else { rightRotorPositions += 1 }
            rightRotor.runAction(SCNAction.rotateBy(x: 0, y: 0, z: degreesToRadians(-13.846), duration: 0.8))

            playRotorEffect()
        }
    }

    // MARK: - AR Animations

    final func ARmoveWheel() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
            let ARrightRotor = (ARsceneView.scene.rootNode.childNode(withName: "RotorRight", recursively: true)?.childNode(withName: "rotor", recursively: true)?.childNode(withName: "torus", recursively: true))!
            if ARrightRotorPositions == 25 {
                ARrightRotorPositions = 0
                // Rotate Middle Rotor 1 position
                let ARmiddleRotor = (ARsceneView.scene.rootNode.childNode(withName: "RotorMiddle", recursively: true)?.childNode(withName: "rotor", recursively: true)?.childNode(withName: "torus", recursively: true))!
                ARmiddleRotor.runAction(SCNAction.rotateBy(x: 0, y: 0, z: degreesToRadians(-13.846), duration: 0.8))
                moveMiddleRotorForward()
            } else { ARrightRotorPositions += 1 }
            ARrightRotor.runAction(SCNAction.rotateBy(x: 0, y: 0, z: degreesToRadians(-13.846), duration: 0.8))

            playRotorEffect()
        }
    }

    final func playRotorEffect() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            playSound("Rotors")
        }
    }

    final func editPlugBoard() {
        let hingeDep = !ARisOn ? hingedeployed : ARhingeinProgress
        if !hingeDep {
            if ARisOn { ARhingeinProgress = true } else { hingeinProgress = true }

            let rotview = !ARisOn ? hinge! : ARsceneView.scene.rootNode.childNode(withName: "hinges", recursively: true)!
            rotview.runAction(SCNAction.rotateTo(x: 0, y: 0, z: degreesToRadians(87.082), duration: 4.0))
            Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(showPlugBoard), userInfo: nil, repeats: false)

            if !ARisOn {
                Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(movePlugboardpass), userInfo: cameraSetup.plugboardCamera, repeats: false)
            }
        }
    }

    final func changePlugBoard(to alpha: CGFloat) {
        UIView.animate(withDuration: 1.5) {
            self.plugBoard.alpha = alpha
            self.visualEffectView.alpha = alpha
            if self.Gamescene.wiresRemaining <= 0 {
                self.correctImg.alpha = alpha
                self.correctLbl.alpha = alpha
            }
        } completion: { [self] (true) in
            if alpha == 0 && hingeinProgress {
                moveToCameraposition(cameraSetup.normalCamera)
            }
            changeHinge(to: alpha == 0 ? cameraSetup.normalCamera: cameraSetup.plugboardCamera)
        }
    }

    @objc final func showPlugBoard() {
        changePlugBoard(to: 1.0)
        
        let playerLayer = AVPlayerLayer(player: avPlayer)
        playerLayer.frame = self.videoview.bounds
        self.videoview.layer.cornerRadius = 28
        self.videoview.layer.addSublayer(playerLayer)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.changeInstructional(to: 1)
        }
    }

    @objc final func movePlugboardpass(timer: Timer) {
        let To = timer.userInfo as! Camera
        moveToCameraposition(To)
    }

    //MARK: - Encryption Functions

    /// Encrypts letter using Enigma Cypher
    final func encrypt(ltr: String) -> String {
        //Encrypt without plug board
        let number = !ARisOn ? rightRotorPositions : ARrightRotorPositions
        let mapped = !ARisOn ? map : armap

        var passed = false
        var offset = 0 /// Offset handles the event of s self key encryption (Input=Output) e.g. e -> e
        var str = ""
        while !passed {
            let encrypted : Int = mapped.mapping2[map.mapping1[(number + offset)]!]!
            str = map.charsToNumbers.someKey(forValue: encrypted)!
            if str != ltr { passed = true } else { offset += number == 25 ? -1 : 1; }
        }

        return str
    }
    
    final func changeInstructional(to alpha: CGFloat) {
        instructionsShowing = alpha == 1 ? true: false
        UIView.animate(withDuration: 1.5) { [self] in
            for item in [videoview, visualEffectView2, OKbtn] {
                item.alpha = alpha
            }
        } completion: { [self] (true) in
            if alpha == 1 {
                avPlayer.play()
            } else {
                avPlayer.pause()
            }
        }
    }
    
    /// Check to see if OKT Btn apped
    @objc final func OKTapped() {
        changeInstructional(to: 0)
    }
    final func resetKeyLights() {
        for char in "abcdefghijklmnopqrstuvwxyz" {
            changeLightIntensity(letter: "\(char)")
        }
    }
}

private extension ViewController {
    //MARK: - Layout Setup

    /** Set object to square shape
     - Parameter view: view for Setup
     - Parameter side: length of side
     */
    final func squareSetup(_ view: UIView, with side: CGFloat) {
        translatesAutoresizing(view)
        attributeSetup(view.widthAnchor, sideLength: side)
        attributeSetup(view.heightAnchor, sideLength: side)
    }

    /** Attribute Setup for Constant Attribute
     - Parameter anchor: origin of hemisphere
     - Parameter sideLength: length of side
     */
    final func attributeSetup(_ anchor: NSLayoutDimension, sideLength: CGFloat) {
         anchor.constraint(equalToConstant: sideLength).isActive = true
    }

    /** Attribute Setup for Variable
     - Parameter view: view for Setup
     - Parameter superView: superView
     - Parameter Xmultiplier: multiplier for x component
     - Parameter Ymultiplier: multiplier for y component
     */
    final func attributeSetup(_ view: UIView, superView: UIView, Xmultiplier: CGFloat, Ymultiplier: CGFloat) {
        view.widthAnchor.constraint(equalTo: superView.widthAnchor, multiplier: Xmultiplier).isActive = true
        view.heightAnchor.constraint(equalTo: superView.heightAnchor, multiplier: Ymultiplier).isActive = true
   }

    /** Setup sides of Constant Length
     - Parameter view: view for Setup
     - Parameter width: constant width
     - Parameter height: constant height
     */
    final func sidesSetup(_ view: UIView, width: CGFloat, height: CGFloat) {
        attributeSetup(view.widthAnchor, sideLength: width)
        attributeSetup(view.heightAnchor, sideLength: height)
    }

    /** Full Screen Setup
     - Parameter view: view for Setup
     - Parameter superView: superView of object
     */
    final func fullScreenSetup(_ view: UIView, superView: UIView) {
        translatesAutoresizing(view)
        view.centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: superView.centerYAnchor).isActive = true
        view.widthAnchor.constraint(equalTo: superView.widthAnchor).isActive = true
        view.heightAnchor.constraint(equalTo: superView.heightAnchor).isActive = true
    }

    /** Centre X and Y Component of Object
     - Parameter view: view for Setup
     - Parameter superView: superView of object
     */
    final func centreXandY(_ view: UIView, superView: UIView) {
        centreX(view, superView: superView)
        view.centerYAnchor.constraint(equalTo: superView.centerYAnchor).isActive = true
    }

    /** Centre X of Object
     - Parameter view: view for Setup
     - Parameter superView: superView of object
     */
    final func centreX(_ view: UIView, superView: UIView) {
        translatesAutoresizing(view)
        view.centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
    }

    /** Translates Autoresizing Mask Into Constraints
     - Parameter view: view for Setup
     */
    final func translatesAutoresizing(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension UIView {
    internal func createCornerRadius(cornerRadius: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadius
    }
}

extension ViewController: ARCoachingOverlayViewDelegate {
    //MARK: - ARCoachingOverlay Setup
    public func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) { }
    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) { }
    public func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) { }
}

// MARK: - Camera Options
fileprivate enum CameraOptions {
    case normal
    case keyboard
    case plugboard
}
