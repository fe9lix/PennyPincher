import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var gestureView: GestureView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        gestureView.showSamplingPoints = true
    }

}
