import SwiftUI
import ARKit
import SceneKit

struct ArViewContainer: UIViewRepresentable {
    let arDelegate = ARDelegate()
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        arView.autoenablesDefaultLighting = true
        arView.delegate = arDelegate
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        
        arView.addGestureRecognizer(tapGesture)
        context.coordinator.sceneView = arView
        
        let button = UIButton()
        button.frame = CGRect(x: 20, y: 40, width: 60, height: 60)
        button.setImage(UIImage(systemName: "arrow.2.circlepath"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .black.withAlphaComponent(0.7)
        button.layer.cornerRadius = 30
        button.addTarget(context.coordinator, action: #selector(Coordinator.toggleShape(_:)), for: .touchUpInside)
        
        arView.addSubview(button)
        
        
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        
    }
    
    class Coordinator: NSObject {
        
        var totalBlocks = 0
        let maxBlocks: Int = 15
        var sceneView: ARSCNView?
        
        enum shapeType{
            case box, sphere, pyramid
        }
        
        var currentShape: shapeType = .box
        
        @objc func handleTap(_ sender: UITapGestureRecognizer){
            
            guard let sceneView = sceneView else { return }
            
            let location = sender.location(in:sceneView)
            
            guard let query = sceneView.raycastQuery(from:location, allowing: .existingPlaneInfinite, alignment: .horizontal) else { return }
            
            let results = sceneView.session.raycast(query)
            guard let result = results.first else { return }
            
            let geometry: SCNGeometry
            
            switch currentShape {
            case .box:
                geometry = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0)
            case .sphere:
                geometry = SCNSphere(radius: 0.15)
            case .pyramid:
                geometry = SCNPyramid(width: 0.3, height: 0.3, length: 0.3)
                
            }
            geometry.firstMaterial?.diffuse.contents = UIColor.red
            
            let node = SCNNode(geometry: geometry)
            let position = result.worldTransform.columns.3
            node.position = SCNVector3(position.x, position.y + 0.05, position.z)
            node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            
            sceneView.scene.rootNode.addChildNode(node)
            
            
        }
        
        @objc func toggleShape(_ sender: UIButton){
            switch currentShape {
            case .box:
                currentShape = .sphere
            case .sphere:
                currentShape = .pyramid
            case .pyramid:
                currentShape = .box
            }
            
        }
        
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
