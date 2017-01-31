import UIKit
import PennyPincher

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var gestureView: GestureView!
    @IBOutlet weak var templateTextField: UITextField!
    @IBOutlet weak var recognizerResultLabel: UILabel!
    
    private let pennyPincherGestureRecognizer = PennyPincherGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pennyPincherGestureRecognizer.enableMultipleStrokes = true
        pennyPincherGestureRecognizer.allowedTimeBetweenMultipleStrokes = 0.2
        pennyPincherGestureRecognizer.cancelsTouchesInView = false
        pennyPincherGestureRecognizer.addTarget(self, action: #selector(didRecognize(_:)))
        
        gestureView.addGestureRecognizer(pennyPincherGestureRecognizer)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func didTapAddTemplate(_ sender: AnyObject) {
        if
            let text = templateTextField.text,
            let template = PennyPincher.createTemplate(text, points: gestureView.points) {
                pennyPincherGestureRecognizer.templates.append(template)
        }
        
        gestureView.clear()
    }
    
    @IBAction func onLoadAndroidDataButtonPressed(_ sender: Any) {
        let templates = AndroidRecognizerToPennyPincher.translatedTemplates()
        pennyPincherGestureRecognizer.templates.append(contentsOf: templates)
    }
    
    func didRecognize(_ pennyPincherGestureRecognizer: PennyPincherGestureRecognizer) {
        switch pennyPincherGestureRecognizer.state {
        case .ended, .cancelled, .failed:
            updateRecognizerResult()
        default: break
        }
    }
    
    private func updateRecognizerResult() {
        guard let (template, similarity) = pennyPincherGestureRecognizer.result else {
            recognizerResultLabel.text = "Could not recognize."
            return
        }
        
        let similarityString = String(format: "%.2f", similarity)
        recognizerResultLabel.text = "Template: \(template.id), Similarity: \(similarityString)"
    }
   
    @IBAction func didTapClear(_ sender: AnyObject) {
        recognizerResultLabel.text = ""
        gestureView.clear()
    }
}
