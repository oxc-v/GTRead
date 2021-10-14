//
//  GTTrackCorrectModel.swift
//  GTRead
//
//  Created by Dev on 2021/10/10.
//

import UIKit

class GTTrackCorrectModel {
    var isCorrect = false
    var acceptPoints = [CGPoint(x: 1, y: 1), CGPoint(x: 1, y: 1), CGPoint(x: 1, y: 1), CGPoint(x: 1, y: 1)]

    func getCorrectSightData(p: CGPoint) -> CGPoint {
        let x_new = Double((2 * p.x - acceptPoints[0].x - acceptPoints[3].x) / (acceptPoints[1].x + acceptPoints[2].x - acceptPoints[0].x - acceptPoints[3].x) * (UIScreen.main.bounds.width - 24))
        let y_new = Double((2 * p.y - acceptPoints[0].y - acceptPoints[1].y) / (acceptPoints[2].y + acceptPoints[3].y - acceptPoints[0].y - acceptPoints[1].y) * (UIScreen.main.bounds.width - 24))
        
        return CGPoint(x: x_new, y: y_new)
    }
}
