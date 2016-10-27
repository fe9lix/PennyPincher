import UIKit
import UIKit.UIGestureRecognizerSubclass

public class PennyPincherGestureRecognizer: UIGestureRecognizer {
    public var enableMultipleStrokes: Bool = true
    public var allowedTimeBetweenMultipleStrokes: TimeInterval = 0.2
    public var templates = [PennyPincherTemplate]()
    
    private(set) public var result: (template: PennyPincherTemplate, similarity: CGFloat)?
    
    private(set) var pennyPincher = PennyPincher()
    private(set) var points = [CGPoint]()
    private(set) var timer: Timer?
    
    public override func reset() {
        super.reset()
       
        invalidateTimer()
        points.removeAll(keepingCapacity: false)
        result = nil
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        invalidateTimer()
        
        if let touch = touches.first {
            points.append(touch.location(in: view))
        }

        if state == .possible {
            state = .began
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        if let touch = touches.first {
            points.append(touch.location(in: view))
        }
        
        state = .changed
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        if enableMultipleStrokes {
            timer = Timer.scheduledTimer(timeInterval: allowedTimeBetweenMultipleStrokes,
                target: self,
                selector: #selector(timerDidFire(_:)),
                userInfo: nil,
                repeats: false)
        } else {
            recognize()
        }
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        points.removeAll(keepingCapacity: false)
        
        state = .cancelled
    }
    
    private func recognize() {
        result = PennyPincher.recognize(points, templates: templates)
        
        state = result != nil ? .ended : .failed
    }
    
    @objc private func timerDidFire(_ timer: Timer) {
        recognize()
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
}
