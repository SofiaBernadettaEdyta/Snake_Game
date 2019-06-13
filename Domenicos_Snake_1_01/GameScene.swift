//
//  GameScene.swift
//  Domenicos_Snake_1_01
//
//  Created by Zofia Drabek on 12/11/2018.
//  Copyright © 2018 Zofia Drabek. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    
    var gameBG: SKShapeNode!
    var snakeLights: [[SKSpriteNode]] = []
    var snake = Snake()
    var cellSize: CGFloat!
    var domenicosEmoji: SKLabelNode!
    var bestScore: SKLabelNode!
    var playButton: SKShapeNode!
    var playLabel: SKLabelNode!
    var text: SKLabelNode!
    var textBackground: SKShapeNode!
    var currentScoreLabel: SKLabelNode!
    var endGameLabel: SKLabelNode!
    
    @objc func swipeR() {
        snake.swipe(direction: 3)
    }
    
    @objc func swipeL() {
        snake.swipe(direction: 1)
    }
    
    @objc func swipeU() {
        snake.swipe(direction: 0)
    }
    
    @objc func swipeD() {
        snake.swipe(direction: 2)
    }
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor(red:0.85, green:0.85, blue:0.85, alpha:1)
        initializeMenu()
        createBoard()
        
        
        let swipeRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeR))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let swipeLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeL))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeUp: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeU))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeD))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = self.nodes(at: location)
            for node in touchedNode {
                if node.name == "play_button" {
                    snake.gameIsStarted = true
                    startGame()
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if snake.gameIsStarted {
            snake.update(time: currentTime)
            updateSnake()
            updateScore()
            finishAnimation()
            
        }
    }
    
    private func startGame() {
        domenicosEmoji.run(SKAction.scale(to: 0, duration: 0.6)){
            self.domenicosEmoji.isHidden = true
        }
        playButton.run(SKAction.scale(to: 0, duration: 0.6)){
            self.playButton.isHidden = true
        }
        playLabel.run(SKAction.scale(to: 0, duration: 0.6)){
            self.playLabel.isHidden = true
        }
        text.run(SKAction.scale(to: 0, duration: 0.6))
        gameBG.setScale(0)
        gameBG.isHidden = false
        gameBG.run(SKAction.scale(to: 1, duration: 0.6))
        snake.initGame()
        
    }
    
    func createBoard() {

        var width = frame.size.width * 0.8
        var height = frame.size.height * 0.8
        let rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
        gameBG = SKShapeNode(rect: rect, cornerRadius: 0.02)
        gameBG.fillColor = SKColor(red:0.85, green:0.85, blue:0.85, alpha:1)
        gameBG.zPosition = 0
        self.addChild(gameBG)
        
        //size of circles
        width *= 0.85
        height *= 0.85
        snake.numRows = 14
        snake.numCols = 8

        cellSize = width / CGFloat(snake.numCols)
        
        let emptyNode = SKSpriteNode()
        snakeLights = Array(repeating: Array(repeating: emptyNode, count: snake.numRows), count: snake.numCols)
        
        for col in 0 ..< snake.numCols {
            for row in 0 ..< snake.numRows {
                let point = postitionToCoordinatesNodes(x: col, y: row)
                let rect = CGRect(x: point.x, y: point.y, width: cellSize, height: cellSize)
                let cellNode = SKShapeNode(rect: rect, cornerRadius: 100)
                cellNode.fillColor = SKColor(red:0.9, green:0.9, blue:0.9, alpha:0.75)
                cellNode.lineWidth = 3
                cellNode.strokeColor = SKColor(red:0.85, green:0.85, blue:0.85, alpha:1)
                cellNode.zPosition = 2
                self.gameBG.addChild(cellNode)
                
                let radialGradientSize = CGSize(width: cellSize * 1.5, height: cellSize * 1.5)
                let radialGradientColors = [ UIColor.white, UIColor(red:1.00, green:1.00, blue:0.52, alpha:1.0), UIColor(red:1.00, green:0.78, blue:0.63, alpha:1.0), UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.0)]
                let radialGradientLocations: [CGFloat] = [0, 0.33, 0.5, 1]
                let radialGradientTexture = SKTexture(radialGradientWithColors: radialGradientColors, locations: radialGradientLocations, size: radialGradientSize)
                snakeLights[col][row] = SKSpriteNode(texture: radialGradientTexture)
                snakeLights[col][row].zPosition = 2
                snakeLights[col][row].position = postitionToCoordinatesLights(x: col, y: row)
                self.gameBG.addChild(snakeLights[col][row])
                snakeLights[col][row].isHidden = true
                gameBG.isHidden = true
            }
        }

        currentScoreLabel = SKLabelNode(fontNamed: "San Francisco")
        currentScoreLabel.position = CGPoint(x: 0, y: (frame.size.height / -2) * 0.9)
        currentScoreLabel.fontSize = 40
        currentScoreLabel.fontColor = .black
        currentScoreLabel.text = "Score: \(snake.currentScore)"
        self.gameBG.addChild(currentScoreLabel)
    }
    
    func postitionToCoordinatesNodes(x: Int, y: Int) -> CGPoint {
        let xCoordinate = Double(cellSize) * ( Double(x) -  Double(snake.numCols) / 2 )
        let yCoordinate = ( Double(snake.numRows) / 2  - Double(y)) * Double(cellSize)
        return CGPoint(x: xCoordinate, y: yCoordinate)
    }
    
    func postitionToCoordinatesLights(x: Int, y: Int) -> CGPoint {
        let xCoordinate = Double(cellSize) * ( Double(x) + 0.5 -  Double(snake.numCols) / 2 )
        let yCoordinate = ( Double(snake.numRows) / 2  - Double(y) + 0.5) * Double(cellSize)
        return CGPoint(x: xCoordinate, y: yCoordinate)
    }
    
    func updateSnake() {
        for lights in snakeLights {
            for light in lights {
                light.isHidden = true
            }
        }
        for position in snake.snakePositions {
            snakeLights[position.x][position.y].isHidden = false
        }
        snakeLights[snake.scorePos.x][snake.scorePos.y].isHidden = false
    }
    
    private func initializeMenu() {
        
        //Create game title
        domenicosEmoji = SKLabelNode(fontNamed: "San Francisco")
        domenicosEmoji.zPosition = 10
        domenicosEmoji.position = CGPoint(x: 0, y: -100)
        domenicosEmoji.fontSize = 250
        domenicosEmoji.text = "🐍"
        domenicosEmoji.isHidden = false
        self.addChild(domenicosEmoji)

        //Create play button
        let rect = CGRect(x: -275, y: -75, width: 550, height: 150)
        playButton = SKShapeNode(rect: rect, cornerRadius: 75)
        playButton.name = "play_button"
        playButton.zPosition = 10
        playButton.position = CGPoint(x: 0, y: (frame.size.height / -2) + 300)
        playButton.fillColor = SKColor.orange
        self.addChild(playButton)
        
        playLabel = SKLabelNode(fontNamed: "San Francisco")
        playLabel.zPosition = 11
        playLabel.position = playButton.position
        playLabel.fontSize = 50
        playLabel.text = "Let's play a snake!"
        playLabel.fontColor = SKColor.white
        playLabel.verticalAlignmentMode = .center
        self.addChild(playLabel)
        
    }
    
    func updateScore() {
        currentScoreLabel.text = "Score: \(snake.currentScore)"
    }
    
    func finishAnimation() {
        if snake.direction < 0 {
            
            endGameLabel = SKLabelNode(fontNamed: "ArialRoundedMTBold")
            endGameLabel.position = CGPoint(x: 0, y: 0)
            endGameLabel.fontSize = 70
            endGameLabel.zPosition  = 12
            endGameLabel.text = "GAME OVER"
            endGameLabel.fontColor = SKColor.black
            endGameLabel.isHidden = false
            self.addChild(endGameLabel)
            
            
            
            gameBG.run(SKAction.scale(to: 0, duration: 1)){
                self.gameBG.isHidden = false
                self.endGameLabel.run(SKAction.scale(to: 0, duration: 2)) {
                    self.endGameLabel.isHidden = true
                    self.domenicosEmoji.isHidden = false
                    self.playButton.isHidden = false
                    self.playLabel.isHidden = false
                    self.text.isHidden = false
                    self.domenicosEmoji.run(SKAction.scale(to: 1, duration: 0.6))
                    self.playButton.run(SKAction.scale(to: 1, duration: 0.6))
                    self.playLabel.run(SKAction.scale(to: 1, duration: 0.6))
                    self.text.run(SKAction.scale(to: 1, duration: 0.6))
                }
                
                
            }
            
            
            
        }
    }
}

extension SKTexture
{
    convenience init(radialGradientWithColors colors: [UIColor], locations: [CGFloat], size: CGSize)
    {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { (context) in
            let colorSpace = context.cgContext.colorSpace ?? CGColorSpaceCreateDeviceRGB()
            let cgColors = colors.map({ $0.cgColor }) as CFArray
            guard let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors, locations: UnsafePointer<CGFloat>(locations)) else {
                fatalError("Failed creating gradient.")
            }
            
            let radius = max(size.width, size.height) / 2.0
            let midPoint = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
            context.cgContext.drawRadialGradient(gradient, startCenter: midPoint, startRadius: 0, endCenter: midPoint, endRadius: radius, options: [])
        }
        
        self.init(image: image)
    }
}
