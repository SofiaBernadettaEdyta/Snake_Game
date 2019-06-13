
//
//  SnakeModel.swift
//  Domenicos_Snake_1_01
//
//  Created by Zofia Drabek on 13/11/2018.
//  Copyright © 2018 Zofia Drabek. All rights reserved.
//

import Foundation
import SpriteKit

class Snake {
    
    var snakePositions = [(x: Int, y: Int)]()
    var direction = 3 // 0 up, 1 left, 2 down, 3 right
    var nextMoveTime: Double?
    var timeExtension = 0.5
    var numCols = Int()
    var numRows = Int()
    var gameIsStarted = false
    var scorePos: (x: Int, y: Int)!
    var currentScore = 0

    func initGame() {
        snakePositions = []
        direction = 3
        currentScore = 0
        snakePositions.append((x: 4, y: 2))
        snakePositions.append((x: 3, y: 2))
        snakePositions.append((x: 2, y: 2))
        generateNewPoint()
    }
    
    func update(time: Double) {
        if nextMoveTime == nil {
            nextMoveTime = time + timeExtension
        } else if time >= nextMoveTime! && gameIsStarted{
            nextMoveTime = time + timeExtension
            updateSnakePosition()
            checkForScore()
            checkFoDeath()
        }
    }
    
    func swipe(direction: Int ) {
        // checking if the move make sence, if it is not the same direction or the oposite one
        if direction % 2 != self.direction % 2 {
            self.direction = direction
        }
    }
    
    private func generateNewPoint() {
        scorePos = (Int(arc4random_uniform(UInt32(numCols - 1))), Int(arc4random_uniform(UInt32(numRows - 1))) )
        while snakePositions.contains(where: { position in
            if position == scorePos {
                return true
            }
            return false
        }) {
            scorePos.x = Int(arc4random_uniform(UInt32(numCols - 1)))
            scorePos.y = Int(arc4random_uniform(UInt32(numRows - 1)))
        }
    }
    
    private func checkForScore() {
        if scorePos != nil {
            let x = snakePositions[0].x
            let y = snakePositions[0].y
            if x == scorePos.x && y == scorePos.y {
                currentScore += 1
                generateNewPoint()
                snakePositions.append(snakePositions.last!)
            }
        }
    }
    
    func updateSnakePosition() {
        
        var xChange = 0
        var yChange = 0
        
        switch direction {
        case 0:
            xChange = 0
            yChange = -1
        case 1:
            xChange = -1
            yChange = 0
        case 2:
            xChange = 0
            yChange = 1
        case 3:
            xChange = 1
            yChange = 0
        default:
            break
        }
        
        var index = self.snakePositions.count - 1
        while index > 0 {
            snakePositions[index] = snakePositions[index-1]
            index -= 1
        }
        
        // checking if edges and at the end if not new position of first cell
        if direction == 0 && snakePositions[0].y == 0 {
            snakePositions[0].y = numRows - 1
        } else if direction == 1 && snakePositions[0].x == 0 {
            snakePositions[0].x = numCols - 1
        } else if direction == 2 && snakePositions[0].y == numRows - 1 {
            snakePositions[0].y = 0
        } else if direction == 3 && snakePositions[0].x == numCols - 1 {
            snakePositions[0].x = 0
        } else {
            snakePositions[0].x += xChange
            snakePositions[0].y += yChange
        }
    }
    
    private func checkFoDeath() {
        if snakePositions.count > 0 {
            var arrayOfPositions = snakePositions
            let headOfSnake = arrayOfPositions[0]
            arrayOfPositions.remove(at: 0)
            if arrayOfPositions.contains(where: { position in
                if position == headOfSnake {
                    return true
                }
                return false
            }) {
                direction = -1
                gameIsStarted = false
            }
        }
    }
    
    
}
