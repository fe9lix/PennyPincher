import UIKit

class GestureView: UIView {
    
    struct Stroke {
        let points: [CGPoint]
    }
    
    var strokes = [Stroke]() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var points: [CGPoint] {
        return strokes.reduce([CGPoint]()) { points, stroke in
            return points + stroke.points
        }
    }
    
    private var strokePoints = [CGPoint]()
    
    var strokeColor: UIColor = UIColor.blackColor() {
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
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    private func setup() {
        path.lineWidth = 2.0
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        addStrokePointFromTouches(touches)
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        
        addStrokePointFromTouches(touches)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        
        strokes.append(Stroke(points: strokePoints))
        
        strokePoints.removeAll(keepCapacity: false)
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        super.touchesCancelled(touches, withEvent: event)
        
        strokePoints.removeAll(keepCapacity: false)
    }
    
    private func addStrokePointFromTouches(touches: Set<NSObject>) {
        if let touch = touches.first as? UITouch {
            let point = touch.locationInView(self)
            strokePoints.append(point)
            
            setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
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
    
    private func addStrokePoint(points: [CGPoint]) {
        if points.count < 3 {
            return
        }
        
        path.moveToPoint(points.first!)
        
        for i in 1...points.count - 2 {
            let point = points[i]
            let nextPoint = points[i + 1]
            let endPoint = CGPointMake(
                (point.x + nextPoint.x) / 2,
                (point.y + nextPoint.y) / 2)
            
            path.addQuadCurveToPoint(endPoint, controlPoint: point)
        }
        
        let lastPoint = points[points.count - 1]
        let secondLastPoint = points[points.count - 2]
        
        path.addQuadCurveToPoint(lastPoint, controlPoint: secondLastPoint)
    }
    
    private func addSamplingPoints() {
        samplingPath.removeAllPoints()
        
        UIColor.redColor().setStroke()
        
        for stroke in strokes {
            for point in stroke.points {
                samplingPath.moveToPoint(point)
                samplingPath.appendPath(UIBezierPath(arcCenter:point, radius: path.lineWidth * 3, startAngle: 0.0, endAngle: CGFloat(M_PI) * 2, clockwise: true))
            }
        }
        
        samplingPath.stroke()
    }
    
}
