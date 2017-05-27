import UIKit

struct GestureViewStroke {
    let points: [CGPoint]
}

class GestureView: UIView {
    var strokes = [GestureViewStroke]() {
        didSet {
            strokePoints.removeAll(keepingCapacity: false)
            setNeedsDisplay()
        }
    }
    
    var points: [CGPoint] {
        return strokes.reduce([CGPoint]()) { points, stroke in
            return points + stroke.points
        }
    }
    
    private var strokePoints = [CGPoint]()
    
    var strokeColor: UIColor = UIColor.black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var showSamplingPoints = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private let path = UIBezierPath()
    private let samplingPath = UIBezierPath()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    private func setup() {
        path.lineWidth = 2.0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        addStrokePointFromTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)  {
        super.touchesMoved(touches, with: event)
        
        addStrokePointFromTouches(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        strokes.append(GestureViewStroke(points: strokePoints))
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        strokePoints.removeAll(keepingCapacity: false)
    }
    
    private func addStrokePointFromTouches(_ touches: Set<NSObject>) {
        guard let touch = touches.first as? UITouch else { return }
        
        let point = touch.location(in: self)
        strokePoints.append(point)
        
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        path.removeAllPoints()
        
        strokeColor.setStroke()
        
        addStrokePoint(strokePoints)
        for stroke in strokes {
            addStrokePoint(stroke.points)
        }
        
        path.stroke()
        
        if showSamplingPoints {
            addSamplingPoints()
        }
    }
    
    fileprivate func addStrokePoint(_ points: [CGPoint]) {
        guard points.count >= 3 else { return }
        
        path.move(to: points.first!)
        
        for i in 1...points.count - 2 {
            let point = points[i]
            let nextPoint = points[i + 1]
            let endPoint = CGPoint(
                x: (point.x + nextPoint.x) / 2,
                y: (point.y + nextPoint.y) / 2)
            
            path.addQuadCurve(to: endPoint, controlPoint: point)
        }
        
        let lastPoint = points[points.count - 1]
        let secondLastPoint = points[points.count - 2]
        
        path.addQuadCurve(to: lastPoint, controlPoint: secondLastPoint)
    }
    
    fileprivate func addSamplingPoints() {
        samplingPath.removeAllPoints()
        
        UIColor.red.setStroke()
        
        for stroke in strokes {
            for point in stroke.points {
                samplingPath.move(to: point)
                samplingPath.append(UIBezierPath(
                    arcCenter:point,
                    radius: path.lineWidth * 3,
                    startAngle: 0.0,
                    endAngle: .pi * 2,
                    clockwise: true)
                )
            }
        }
        
        samplingPath.stroke()
    }
    
    func clear() {
        strokes.removeAll(keepingCapacity: false)
    }
}
