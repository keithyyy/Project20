//
//  GameScene.swift
//  Project20
//
//  Created by Keith Crooc on 2021-11-14.
//


// CHALLENGE
// 1. Create a scorelabel that updates the score ✅
// 2. Make the game end after certain number of launches. Will need to use the invalidate() method of Timer to stop the repeating.
// 3. use waitForDuration and removeFromParent actions in a sequence to make sure explosion particle emitters are removed from game scene when they are finished.

import SpriteKit

class GameScene: SKScene {
    
    
    
    var gameTimer: Timer?
    var fireworks = [SKNode]()
    var scoreLabel: SKLabelNode!
    var displayTimer: Timer?
    
    var addedScore: SKLabelNode!

    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var addedPoints = 0 {
        didSet {
            addedScore.text = "+\(addedPoints)!"
        }
    }
    
    
   
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 512, y: 670)
        scoreLabel.zPosition = 1
        scoreLabel.alpha = 1
        addChild(scoreLabel)
        
        score = 0
        
        addedScore = SKLabelNode(fontNamed: "Chalkduster")
        addedScore.position = CGPoint(x: 512, y: 384)
        addedScore.fontSize = 120
        addedScore.zPosition = 1
        addedScore.alpha = 0
        addChild(addedScore)
        
        
        addedPoints = 0
        
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
        
    }
    
    func createFirework(xMovement: CGFloat, x: Int, y: Int) {
        
//        SKNode is going to act as our container (holding our rocket and our spark)
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1
//      colorBlendFactor let's swift know that for this object, I want it to be fully a specific color. When we do assign it a color, itll be completely that.
        firework.name = "firework"
        node.addChild(firework)
//        once we configure it, we add it to the container node
        
        
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .cyan
        case 1:
            firework.color = .green
        default:
            firework.color = .red
        }
        
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        node.run(move)
        
        
        if let emitter = SKEmitterNode(fileNamed: "fuse") {
            emitter.position = CGPoint(x: 0, y: -22)
            node.addChild(emitter)
        }
        
        
        fireworks.append(node)
//        adding it to our array of fireworks
        addChild(node)
        
    }
    
    
    @objc func launchFireworks() {
        let movementAmount: CGFloat = 1800
        
        
        switch Int.random(in: 0...3) {
        case 0:
//            fireworks going straight up
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)
        case 1:
//          fireworks in a fan
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)
            
        case 2:
//            fireworks going left to right
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)
            
            
        case 3:
//            fireworks going right to left
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)
            
        default:
            break
        }
    }
    
    
    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint {
            guard node.name == "firework" else { continue }
            
            for parent in fireworks {
                guard let firework = parent.children.first as? SKSpriteNode else { continue }
                
                
                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            
            node.name = "selected"
            node.colorBlendFactor = 0
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 980 {
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    
    func explode(firework: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            emitter.position = firework.position
            addChild(emitter)
        }
        firework.removeFromParent()
    }
    
        
    func explodeFireworks() {
        var numExploded = 0
        
        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }
            
            if firework.name == "selected" {
                explode(firework: fireworkContainer)
                fireworks.remove(at: index)
                numExploded += 1
            }
            
            
        }
        
        switch numExploded {
        case 0:
            break
        case 1:
            score += 200
            addedPoints = 200
        case 2:
            score += 500
            addedPoints = 500
        case 3:
            score += 1500
            addedPoints = 1500
        case 4:
            score += 2500
            addedPoints = 2500
        default:
            score += 4000
            addedPoints = 4000
        }
        
        displayScore()
    }
    
    
    
    func displayScore() {
        addedScore.alpha = 1


        displayTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(hideDisplay), userInfo: nil, repeats: false)
    }


    @objc func hideDisplay() {
        addedScore.alpha = 0
    }
    
}
