import ARKit
import SceneKit

class ARDelegate: NSObject, ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        
        let width = CGFloat(planeAnchor.planeExtent.width)
        let height = CGFloat(planeAnchor.planeExtent.height)
        
        let plane = SCNPlane(width: width, height: height)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemBlue.withAlphaComponent(0.8)
        material.isDoubleSided = true
        plane.materials = [material]
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.simdTransform = planeAnchor.transform
        planeNode.eulerAngles.x = -.pi / 2
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard let planeAnchor = anchor as? ARPlaneAnchor,
                  let planeNode = node.childNodes.first,
                  let plane = planeNode.geometry as? SCNPlane else { return }

            plane.width = CGFloat(planeAnchor.planeExtent.width)
            plane.height = CGFloat(planeAnchor.planeExtent.height)
            planeNode.simdPosition = planeAnchor.center
        }
    
}
