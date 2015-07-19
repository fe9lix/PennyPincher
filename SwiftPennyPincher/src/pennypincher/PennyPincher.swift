import UIKit

final public class PennyPincher {
    
    private static let NumResamplingPoints = 16
    
    public init() {
        
    }
    
    public func createTemplate(id: String, points: [CGPoint]) -> PennyPincherTemplate {
        return PennyPincherTemplate(id: id, points: resampleBetweenPoints(points))
    }
    
    public func recognize(points: [CGPoint], templates: [PennyPincherTemplate]) -> (template: PennyPincherTemplate, similarity: CGFloat) {
        let c = resampleBetweenPoints(points)
        var similarity = CGFloat.min
        var t: PennyPincherTemplate!
        var d: CGFloat
        
        for template in templates {
            d = 0.0
            
            let count = min(c.count, template.points.count)
            
            for i in 0...count - 1 {
                let tp = template.points[i]
                let cp = c[i]
                
                d = d + tp.x * cp.x + tp.y * cp.y
                
                if d > similarity {
                    similarity = d
                    t = template
                }
            }
        }
        
        return (t, similarity)
    }
    
    private func resampleBetweenPoints(var points: [CGPoint]) -> [CGPoint] {
        let i = pathLength(points) / CGFloat(PennyPincher.NumResamplingPoints - 1)
        var d: CGFloat = 0.0
        var v = [CGPoint]()
        var prev = points.first!
        
        var index = 0
        for _ in points {
            
            if index == 0 {
                index++
                continue
            }
            
            let thisPoint = points[index]
            let prevPoint = points[index - 1]
            
            let pd = distanceBetweenPoint(thisPoint, andPoint: prevPoint)
            
            if (d + pd) >= i {
                let q = CGPointMake(
                    prevPoint.x + (thisPoint.x - prevPoint.x) * (i - d) / pd,
                    prevPoint.y + (thisPoint.y - prevPoint.y) * (i - d) / pd)
                
                var r = CGPointMake(q.x - prev.x, q.y - prev.y)
                let rd = distanceBetweenPoint(CGPointZero, andPoint: r)
                r.x = r.x / rd
                r.y = r.y / rd
                
                d = 0.0
                prev = q
                
                v.append(r)
                points.insert(q, atIndex: index)
                index++
            } else {
                d = d + pd
            }
            
            index++
        }
        
        return v
    }
    
    private func pathLength(points: [CGPoint]) -> CGFloat {
        var d: CGFloat = 0.0
        
        for i in 1..<points.count {
            d = d + distanceBetweenPoint(points[i - 1], andPoint: points[i])
        }
        
        return d
    }
    
    private func distanceBetweenPoint(pointA: CGPoint, andPoint pointB: CGPoint) -> CGFloat {
        let distX = pointA.x - pointB.x
        let distY = pointA.y - pointB.y
        
        return sqrt((distX * distX) + (distY * distY))
    }
    
}
