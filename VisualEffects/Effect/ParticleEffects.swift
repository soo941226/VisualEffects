//
//  VisualEffects.swift
//  VisualEffectTestProject
//
//  Created by kjs on 2021/12/20.
//

import UIKit
import CoreGraphics
import QuartzCore

//MARK: - public interface for particle effects
public enum Particle {
    case withSnow
    case withBubble

    func ready(for view: UIView) -> Runable {
        switch self {
        case .withSnow:
            return SnowEffect(for: view)
        case .withBubble:
            return BubbleEffect(for: view)
        }
    }
}


//MARK: - Definition about ParticleEffectable
private protocol ParticleEffectable {
    var cells: [CAEmitterCell] { get }
    var emitterLayer: CAEmitterLayer { get }
}


//MARK: - basic concepts of ParticleEffect
private class ParticleEffect: Effect, ParticleEffectable {
    fileprivate unowned var background: CALayer!
    fileprivate var cells = [CAEmitterCell]()
    fileprivate var emitterLayer = CAEmitterLayer()

    required fileprivate init(for view: UIView) {
        self.background = view.layer
    }

    fileprivate func setUpCells(with block: () -> [CAEmitterCell]) {
        cells = block()
    }

    fileprivate func setUpLayer(with block: (CAEmitterLayer) -> Void) {
        emitterLayer.emitterCells = cells
        block(emitterLayer)
    }

    func run() -> Stopable {
        background.addSublayer(emitterLayer)

        return self
    }

    func stop() {
        emitterLayer.lifetime = 0
    }
}


//MARK: - Snow Effect
final private class SnowEffect: ParticleEffect {
    override func run() -> Stopable {
        setUpCells {
            let cell = CAEmitterCell()
            cell.contents = UIImage(systemName: "snowflake")?.filled(with: .white)?.cgImage

            cell.lifetime = 20.0
            cell.birthRate = 20.0

            cell.scale = 0.4
            cell.scaleRange = 0.3

            cell.velocity = -50
            cell.velocityRange = 50

            cell.spin = 0
            cell.spinRange = 0.5

            cell.yAcceleration = 10
            cell.xAcceleration = 5
            cell.emissionRange = .pi

            return [cell]
        }

        setUpLayer { layer in
            layer.emitterPosition = CGPoint(x: background.bounds.width / 2.0, y: -100)
            layer.emitterSize = CGSize(width: background.bounds.width, height: 0)
            layer.emitterShape = .line
            layer.beginTime = CACurrentMediaTime()
        }

        return super.run()
    }
}


//MARK: - Bubble Effect
final private class BubbleEffect: ParticleEffect {
    private func drawBubble() -> UIImage? {
        let radius = 40.0
        let center = CGPoint(x: radius, y: radius)
        let circumference: CGFloat = 2 * .pi
        let quarterArc: CGFloat = .pi / 2
        
        let defaultStrokeColor = CGColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 0.75)
        let defaultInnerColor = CGColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 0.15)

        let bubbleSize = CGSize(width: radius * 2, height: radius * 2)
        UIGraphicsBeginImageContext(bubbleSize)
        let pen = UIGraphicsGetCurrentContext()

        pen?.setStrokeColor(defaultStrokeColor)
        pen?.setFillColor(defaultInnerColor)
        pen?.beginPath()

        pen?.addArc(
            center: center,
            radius: radius * 0.75,
            startAngle: quarterArc,
            endAngle: .pi,
            clockwise: false
        )
        pen?.strokePath()

        pen?.addArc(
            center: center,
            radius: radius * 0.7,
            startAngle: quarterArc,
            endAngle: .pi,
            clockwise: false
        )
        pen?.strokePath()

        pen?.setLineWidth(2.0)
        pen?.addArc(
            center: center,
            radius: radius,
            startAngle: 0,
            endAngle: circumference,
            clockwise: true
        )
        pen?.strokePath()

        pen?.addArc(
            center: center,
            radius: radius,
            startAngle: 0,
            endAngle: circumference,
            clockwise: true
        )
        pen?.fillPath()

        pen?.closePath()

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }


    override func run() -> Stopable {
        setUpCells {
            let image = drawBubble()

            let cell = CAEmitterCell()
            cell.contents = image?.cgImage

            cell.lifetime = 20.0
            cell.birthRate = 12.0

            cell.scale = 0.4
            cell.scaleRange = 0.3

            cell.velocity = 50
            cell.velocityRange = 20

            cell.spin = 0.2
            cell.spinRange = 0.8

            cell.yAcceleration = -15
            cell.xAcceleration = 10
            cell.emissionRange = .pi

            return [cell]
        }

        setUpLayer { layer in
            layer.emitterPosition = CGPoint(
                x: background.bounds.width / 2.0,
                y: background.bounds.height + 50
            )
            layer.emitterSize = CGSize(width: background.bounds.width, height: .zero)
            layer.emitterShape = .line
            layer.beginTime = CACurrentMediaTime()
        }

        return super.run()
    }
}
