import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var gestureView: GestureView!
    @IBOutlet weak var templateTextField: UITextField!
    @IBOutlet weak var recognizerResultLabel: UILabel!
    
    let pennyPincherGestureRecognizer = PennyPincherGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pennyPincherGestureRecognizer.enableMultipleStrokes = true
        pennyPincherGestureRecognizer.allowedTimeBetweenMultipleStrokes = 0.2
        pennyPincherGestureRecognizer.cancelsTouchesInView = false
        pennyPincherGestureRecognizer.addTarget(self, action: "didRecognize:")
        
        gestureView.addGestureRecognizer(pennyPincherGestureRecognizer)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func didTapAddTemplate(sender: AnyObject) {
        if let template = PennyPincher.createTemplate(templateTextField.text, points: gestureView.points) {
            pennyPincherGestureRecognizer.templates.append(template)
        }
        
        gestureView.clear()
    }
    
    func didRecognize(pennyPincherGestureRecognizer: PennyPincherGestureRecognizer) {
        println("pennyPincherGestureRecognizer state: \(pennyPincherGestureRecognizer.state.rawValue)")
        
        switch pennyPincherGestureRecognizer.state {
        case .Ended, .Cancelled, .Failed:
            updateRecognizerResult()
        default:
            break
        }
    }
    
    func updateRecognizerResult() {
        if let (template, similarity) = pennyPincherGestureRecognizer.result {
            let similarityString = String(format: "%.2f", similarity)
            recognizerResultLabel.text = "Template: \(template.id), Similarity: \(similarityString)"
        } else {
            recognizerResultLabel.text = "Could not recognize."
        }
    }
   
    @IBAction func didTapClear(sender: AnyObject) {
        recognizerResultLabel.text = ""
        gestureView.clear()
    }
    
}
