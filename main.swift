import UIKit
import SceneKit

class GameViewController: UIViewController {
    
    var sceneView: SCNView!
    var scene: SCNScene!
    var chickenNode: SCNNode!
    var groundNode: SCNNode!
    var obstacles = [SCNNode]()
    var isFlapping = false
    var gameOver = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the SceneKit view
        sceneView = self.view as? SCNView
        sceneView.allowsCameraControl = true // Allow the camera to be controlled
        sceneView.autoenablesDefaultLighting = true // Automatically enable default lighting
        sceneView.showsStatistics = true // Show FPS and timing info for debugging
        
        // Create a scene
        scene = SCNScene()
        sceneView.scene = scene
        
        // Add camera to the scene
        addCamera()
        
        // Add chicken (player)
        addChicken()
        
        // Add ground (for collision detection)
        addGround()
        
        // Add physics to the scene
        scene.physicsWorld.gravity = SCNVector3(0, -9.8, 0)
    }
    
    // Add the camera to the scene
    func addCamera() {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 20)
        cameraNode.look(at: SCNVector3(x: 0, y: 0, z: 0))
        scene.rootNode.addChildNode(cameraNode)
    }
    
    // Add chicken to the scene
    func addChicken() {
        let chickenGeometry = SCNSphere(radius: 1) // Simple sphere as placeholder for chicken
        let chickenMaterial = SCNMaterial()
        chickenMaterial.diffuse.contents = UIColor.yellow // Color for chicken
        chickenGeometry.materials = [chickenMaterial]
        
        chickenNode = SCNNode(geometry: chickenGeometry)
        chickenNode.position = SCNVector3(x: 0, y: 5, z: 0) // Initial position
        scene.rootNode.addChildNode(chickenNode)
        
        // Add physics to chicken
        chickenNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        chickenNode.physicsBody?.mass = 1.0
        chickenNode.physicsBody?.categoryBitMask = PhysicsCategory.Chicken
        chickenNode.physicsBody?.contactTestBitMask = PhysicsCategory.Obstacle
    }
    
    // Add ground to the scene
    func addGround() {
        let groundGeometry = SCNBox(width: 100, height: 1, length: 100, chamferRadius: 0)
        let groundMaterial = SCNMaterial()
        groundMaterial.diffuse.contents = UIColor.brown
        groundGeometry.materials = [groundMaterial]
        
        groundNode = SCNNode(geometry: groundGeometry)
        groundNode.position = SCNVector3(x: 0, y: 0, z: 0) // Ground positioned at the bottom
        scene.rootNode.addChildNode(groundNode)
        
        // Add physics to ground
        groundNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        groundNode.physicsBody?.categoryBitMask = PhysicsCategory.Ground
    }
    
    // Handle taps for flapping
    @objc func flapChicken() {
        if !isFlapping {
            isFlapping = true
            let flapAction = SCNAction.moveBy(x: 0, y: 5, z: 0, duration: 0.5) // Flap movement
            chickenNode.runAction(flapAction) {
                self.isFlapping = false
            }
        }
    }
    
    // Add obstacles randomly
    func createObstacle() {
        let obstacleGeometry = SCNBox(width: 2, height: CGFloat.random(in: 5...10), length: 2, chamferRadius: 0)
        let obstacleMaterial = SCNMaterial()
        obstacleMaterial.diffuse.contents = UIColor.green
        obstacleGeometry.materials = [obstacleMaterial]
        
        let obstacleNode = SCNNode(geometry: obstacleGeometry)
        obstacleNode.position = SCNVector3(x: 20, y: CGFloat.random(in: 5...15), z: 0)
        scene.rootNode.addChildNode(obstacleNode)
        obstacles.append(obstacleNode)
        
        // Add physics to obstacle
        obstacleNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        obstacleNode.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
        obstacleNode.physicsBody?.contactTestBitMask = PhysicsCategory.Chicken
    }
    
    // Update the scene periodically
    override func update(_ currentTime: TimeInterval) {
        if !gameOver {
            // Move obstacles
            for obstacle in obstacles {
                obstacle.position.x -= 0.1
            }
            
            // Remove obstacles once they go off-screen
            obstacles = obstacles.filter { $0.position.x > -10 }
            
            // Create new obstacles at random intervals
            if Int(currentTime) % 2 == 0 {
                createObstacle()
            }
        }
    }
}

// Physics categories for collision detection
struct PhysicsCategory {
    static let Chicken: UInt32 = 0x1 << 0
    static let Obstacle: UInt32 = 0x1 << 1
    static let Ground: UInt32 = 0x1 << 2
}
