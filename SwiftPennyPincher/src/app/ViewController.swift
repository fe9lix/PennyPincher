import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var gestureView: GestureView!
    @IBOutlet weak var templateTextField: UITextField!
    @IBOutlet weak var recognizerResult: UILabel!
    
    let pennyPincher = PennyPincher()
    var templates = [PennyPincherTemplate]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func didTapAddTemplate(sender: AnyObject) {
        addTemplate(templateTextField.text, points: gestureView.points)
        
        gestureView.clear()
    }
    
    private func addTemplate(id: String, points: [CGPoint]) {
        templates.append(pennyPincher.createTemplate(id, points: points))
    }
    
    @IBAction func didTapRecognize(sender: AnyObject) {
        let (template, similarity) = pennyPincher.recognize(gestureView.points, templates: templates)
       
        let similarityString = String(format: "%.2f", similarity)
        recognizerResult.text = "Template: \(template.id), Similarity: \(similarityString)"
        
        gestureView.clear()
    }

}
