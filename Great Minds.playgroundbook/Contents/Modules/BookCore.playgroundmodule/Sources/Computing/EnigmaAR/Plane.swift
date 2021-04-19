//
//  Plane.swift
//  BookCore
//
//  Created by Niall Kehoe on 02/04/2021.
//

import ARKit

extension UIColor {
    static let planeColor = #colorLiteral(red: 0.09076655656, green: 0.6586913466, blue: 1, alpha: 1)
}

/// Plane Class
final class Plane: SCNNode {
    
    internal let meshNode: SCNNode
    internal let extentNode: SCNNode
    
    init(anchor: ARPlaneAnchor, in sceneView: ARSCNView) {
        guard let meshGeometry = ARSCNPlaneGeometry(device: sceneView.device!) else { fatalError("Can't create plane geometry") }
        meshGeometry.update(from: anchor.geometry)
        meshNode = SCNNode(geometry: meshGeometry)
        
        let extentPlane: SCNPlane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        extentNode = SCNNode(geometry: extentPlane)
        extentNode.simdPosition = anchor.center
        
        extentNode.eulerAngles.x = -.pi / 2

        super.init()

        self.setupMeshVisualStyle()
        self.setupExtentVisualStyle()

        addChildNode(meshNode)
        addChildNode(extentNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupMeshVisualStyle() {
        meshNode.opacity = 0.42
        
        guard let material = meshNode.geometry?.firstMaterial
            else { fatalError("ARSCNPlaneGeometry always has one material") }
        material.diffuse.contents = UIColor.planeColor
    }
    
    private func setupExtentVisualStyle() {
        extentNode.opacity = 0.6

        guard let material = extentNode.geometry?.firstMaterial else { fatalError("SCNPlane always has one material") }
        
        material.diffuse.contents = UIColor.planeColor

        guard let path = Bundle.main.path(forResource: "wireframe_shader", ofType: "metal", inDirectory: "art.scnassets") else { fatalError("Can't find wireframe shader") }
        do {
            let shader = try String(contentsOfFile: path, encoding: .utf8)
            material.shaderModifiers = [.surface: shader]
        } catch {
            fatalError("Can't load wireframe shader: \(error)")
        }
    }
}
