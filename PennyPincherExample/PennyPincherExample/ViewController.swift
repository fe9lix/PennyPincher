import UIKit
import PennyPincher

final class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var gestureView: GestureView!
    @IBOutlet weak var templateTextField: UITextField!
    @IBOutlet weak var recognizerResultLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let pennyPincherGestureRecognizer = PennyPincherGestureRecognizer()
    fileprivate let cellId = "cellId"
    fileprivate var gestures = [ImportedGesture]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        pennyPincherGestureRecognizer.enableMultipleStrokes = true
        pennyPincherGestureRecognizer.allowedTimeBetweenMultipleStrokes = 0.6
        pennyPincherGestureRecognizer.cancelsTouchesInView = false
        pennyPincherGestureRecognizer.addTarget(self, action: #selector(didRecognize(_:)))
        
        gestureView.addGestureRecognizer(pennyPincherGestureRecognizer)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
}

//MARK:- Actions
extension ViewController {
    @IBAction func didTapAddTemplate(_ sender: AnyObject) {
        guard let text = templateTextField.text, !text.isEmpty else {
            recognizerResultLabel.text = "Please name the template"
            return
        }

        guard let template = PennyPincher.createTemplate(text, points: gestureView.points) else {
            recognizerResultLabel.text = "Error creating template"
            return
        }
        
        pennyPincherGestureRecognizer.templates.append(template)
        let strokes = gestureView.strokes.map { ImportedStrokes(points: $0.points) }
        let gesture = ImportedGesture(id: text, strokes: strokes)
        gestures.append(gesture)
        
        gestureView.clear()
        tableView.reloadData()
    }
    
    @IBAction func didTapLoadAndroidData(_ sender: Any) {
        guard let androidGesturesFileURL = PennyPincherAndroidGesturesImporter.defaultImportFileURL else {
            recognizerResultLabel.text = "File not found"
            return
        }
        
        let importedGestures = PennyPincherAndroidGesturesImporter.translatedGestures(fromURL: androidGesturesFileURL)
        gestures.append(contentsOf: importedGestures)
        
        for gesture in importedGestures {
            if let template = PennyPincher.createTemplate(gesture.id, points: gesture.allPoints) {
                pennyPincherGestureRecognizer.templates.append(template)
            }
        }

        tableView.reloadData()
    }

    @IBAction func didTapClear(_ sender: AnyObject) {
        recognizerResultLabel.text = ""
        gestureView.clear()
    }
}

//MARK:- TableView
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gestures.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let gesture = gestures[indexPath.row]

        cell.textLabel?.text = "\(gesture.id): strokes = \(gesture.strokes.count) total points = \(gesture.allPoints.count)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let gesture = gestures[indexPath.row]
        
        gestureView.clear()
        let strokes = gesture.strokes.map { GestureViewStroke(points: $0.points) }
        gestureView.strokes.append(contentsOf: strokes)
        gestureView.setNeedsDisplay()
    }
}
