import UIKit
import UIKit.UIGestureRecognizerSubclass

public final class PennyPincherGestureRecognizer: UIGestureRecognizer {
    
    public var enableMultipleStrokes: Bool = true
    public var allowedTimeBetweenMultipleStrokes: NSTimeInterval = 0.2
    public var templates = [PennyPincherTemplate]()
    
    private(set) public var result: (template: PennyPincherTemplate, similarity: CGFloat)?
    
    private let pennyPincher = PennyPincher()
    private var points = [CGPoint]()
    private var timer: NSTimer?
    
    public override func reset() {
        super.reset()
       
        invalidateTimer()
        
        points.removeAll(keepCapacity: false)
        
        result = nil
    }
    
    override public func touchesBegan(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        invalidateTimer()
        
        if let touch = touches.first as? UITouch {
            points.append(touch.locationInView(view))
        }

        if state == .Possible {
            state = .Began
        }
    }
    
    override public func touchesMoved(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        if let touch = touches.first as? UITouch {
            points.append(touch.locationInView(view))
        }
        
        state = .Changed
    }
    
    override public func touchesEnded(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        if enableMultipleStrokes {
            timer = NSTimer.scheduledTimerWithTimeInterval(allowedTimeBetweenMultipleStrokes,
                target: self,
                selector: "timerDidFire:",
                userInfo: nil,
                repeats: false)
        } else {
            recognize()
        }
    }
    
    override public func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        points.removeAll(keepCapacity: false)
        
        state = .Cancelled
    }
    
    private func recognize() {
        result = PennyPincher.recognize(points, templates: templates)
        
        state = result != nil ? .Ended : .Failed
    }
    
    func timerDidFire(timer: NSTimer) {
        recognize()
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
}
