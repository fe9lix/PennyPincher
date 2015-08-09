[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](http://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg?style=flat)](https://github.com/fe9lix/PennyPincher)
[![Swift](https://img.shields.io/badge/swift-2.0-orange.svg)](https://developer.apple.com/swift/blog/?id=29)

# PennyPincher

*Penny Pincher* is a fast template-based gesture recognizer, developed by Eugene Taranta and Joseph LaViola (full paper reference below). The algorithm is well-suited for mobile applications since it is both fast and accurate and, as shown in the evaluation by the authors, outperforms other recognizers. This project provides a Swift implementation of *Penny Pincher* and shows its usage in a simple example project. Also, the framework contains a UIGestureRecognizer subclass that integrates well into the existing gesture recognition framework of iOS.

Here's the full reference for the paper:

> Eugene M. Taranta, II and Joseph J. LaViola, Jr.. 2015. Penny pincher: a blazing fast, highly accurate $-family recognizer. In Proceedings of the 41st Graphics Interface Conference (GI '15). Canadian Information Processing Society, Toronto, Ont., Canada, Canada, 195-202.

## Demo

![PennyPincher](https://github.com/fe9lix/PennyPincher/raw/gh-pages/images/pennypincher.gif?raw=true)

## Requirements

*>=* iOS 8, Xcode 7, Swift 2.0

## Installation
Recommended installation options are via Carthage or manual installation.

### Carthage:
PennyPincher supports installation via [Carthage](https://github.com/Carthage/Carthage):

- Add the following line to your Cartfile: `github "fe9lix/PennyPincher" >= 1.0`
- Run `carthage update`

### Manual:
- Drag the folder `PennyPincherExample/Carthage/Build/iOS/PennyPincher.framework` into your Xcode project and select "Copy items if needed".
- Make sure that the framework is added under `Embedded Binaries` in the general section of your project's target settings.

## Usage

Please see the `ViewController` of the example project on how to use PennyPincher. Although you can use the `PennyPincher` class directly, the easiest way is to instantiate its gesture recognizer class, configure it, and add it to a view:

```swift
let pennyPincherGestureRecognizer = PennyPincherGestureRecognizer()
pennyPincherGestureRecognizer.enableMultipleStrokes = true
pennyPincherGestureRecognizer.allowedTimeBetweenMultipleStrokes = 0.2
pennyPincherGestureRecognizer.cancelsTouchesInView = false
pennyPincherGestureRecognizer.addTarget(self, action: "didRecognize:")

view.addGestureRecognizer(pennyPincherGestureRecognizer)
```

In the code above, the following properties are set:

- `enableMultipleStrokes`: Allows gestures to be composed of multiple separate strokes, as long as the pause between strokes does not exceed `allowedTimeBetweenMultipleStrokes`. When the property is set to `false`, the gesture recognizer transitions to the cancelled state as soon as the user lifts the finger.
- `allowedTimeBetweenMultipleStrokes`: See above.
- `cancelsTouchesInView`: Regular iOS gesture recongizer property. Might be set to `false` when you want to ensure that touches are still delivered to the attached view. 

The target-action pair is executed for state changes triggered by the recognizer. You can use the `state` property to react accordingly in the UI. The `result` property returns a tuple consisting of the recognized `PennyPincherTemplate` and CGFloat value indicating the similarity. For example:

```swift
guard let (template, similarity) = pennyPincherGestureRecognizer.result else {
    print("Could not recognize.")
    return
}

let similarityString = String(format: "%.2f", similarity)
print("Template: \(template.id), Similarity: \(similarityString)")
```

You can add and remove templates by modifying the `templates` array property of the recognizer. The `PennyPincher` class provides a static method to create new templates of type `PennyPincherTemplate` (a struct). Required parameters are the `id` (a unique string) and `points` (an array of CGPoints).

For example:

```swift
let template = PennyPincher.createTemplate("templateID", points: points)
pennyPincherGestureRecognizer.templates.append(template)
```

Templates could be serialized and saved to disk and then loaded again into memory when the application launches. PennyPincher works pretty well with only one template per gesture (`id`) but, depending on your use case, you can increase its accuracy by adding more for each gesture.

## Author

fe9lix

## License

PennyPincher is available under the MIT license. See the LICENSE file for more info.


