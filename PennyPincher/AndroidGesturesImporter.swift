//
//  AndroidGesturesImporter.swift
//  PennyPincher
//
//  Created by Raf Cabezas on 1/30/17.
//

import Foundation

/// AndroidGesturesImporter
/// Example usage:
///
///    for gesture in AndroidGesturesImporter.translatedGestures(fromURL: androidGesturesFileURL) {
///        if let template = PennyPincher.createTemplate(gesture.id, points: gesture.allPoints) {
///            pennyPincherGestureRecognizer.templates.append(template)
///        }
///    }
///
public final class AndroidGesturesImporter {
    
    /// Default android gestures file is called 'gestures', no extension
    public static var defaultImportFileURL: URL? {
        guard let url = Bundle.main.url(forResource: "gestures", withExtension: nil) else {
            print("File not found")
            return nil
        }
        
        return url
    }
    
    public static func translatedGestures(from url: URL, debug: Bool = false) -> [ImportedGesture] {
        var translatedGestures = [ImportedGesture]()
        if debug { print("translatedGestures invoked. path=\(url.absoluteString)") }
        
        guard let data = try? Data(contentsOf: url) else {
            if debug { print("Error reading data") }
            return []
        }
        if debug { print("Read \(data.count)bytes") }
        
        //Read from android binary file: (Comments from: https://android.googlesource.com/platform/frameworks/base/+/master/core/java/android/gesture/GestureStore.java)
        //
        //    File format for GestureStore:
        //
        //                Nb. bytes   Java type   Description
        //                -----------------------------------
        //    Header
        //                2 bytes     short       File format version number
        //                4 bytes     int         Number of entries
        //    Entry
        //                X bytes     UTF String  Entry name
        //                4 bytes     int         Number of gestures
        //    Gesture
        //                8 bytes     long        Gesture ID
        //                4 bytes     int         Number of strokes
        //    Stroke
        //                4 bytes     int         Number of points
        //    Point
        //                4 bytes     float       X coordinate of the point
        //                4 bytes     float       Y coordinate of the point
        //                8 bytes     long        Time stamp
        //

        let reader = BigEndianDataReader(data: data)
        let version = reader.getInt(zeroedType: Int16())
        let entryCount = reader.getInt(zeroedType: Int32())
        if debug { print("Header data: version=\(version) entries=\(entryCount)") }
        
        guard version == 1 else {
            print("PennyPincherAndroidGesturesImporter Error. Unsupported file version \(version)")
            return []
        }
        
        for entryNumber in 0..<entryCount {
            //Entry
            let unk = reader.getInt(zeroedType: Int16()) //there's 2 extra bytes here for some reason....
            let entryName = reader.getCString()
            let gestureCount = reader.getInt(zeroedType: Int32())
            if debug { print("Entry #\(entryNumber): name=\(entryName) gestures=\(gestureCount) Unk=\(unk)") }
            
            for gestureNumber in 0..<gestureCount {
                let gestureId = reader.getInt(zeroedType: Int64())
                let strokeCount = reader.getInt(zeroedType: Int32())
                if debug { print("Gesture #\(gestureNumber): id=\(gestureId) strokes=\(strokeCount)") }
                
                var strokes = [ImportedStrokes]()
                for strokeNumber in 0..<strokeCount {
                    
                    let pointsCount = reader.getInt(zeroedType: Int32())

                    if debug { print("Stroke #\(strokeNumber): points=\(pointsCount)") }
                    
                    var cgPoints = [CGPoint]()
                    for pointNumber in 0..<pointsCount {
                        let point = CGPoint(x: CGFloat(reader.getFloat32()), y: CGFloat(reader.getFloat32()))
                        let timeStamp = reader.getInt(zeroedType: Int64())
                        cgPoints.append(point)
                        
                        if debug { print("Point #\(pointNumber): (\(point.x), \(point.y)) timestamp:\(timeStamp)") }
                    }
                    strokes.append(ImportedStrokes(points: cgPoints).normalized())
                }
                
                let importedGesture = ImportedGesture(id: entryName, strokes: strokes)
                translatedGestures.append(importedGesture)
            }
        }
        
        return translatedGestures
    }
}

private protocol BigEndianConvertible {
    init(bigEndian value: Self)
    init()
}

extension Int16: BigEndianConvertible {}
extension Int32: BigEndianConvertible {}
extension Int64: BigEndianConvertible {}

private final class BigEndianDataReader {
    var index = 0
    let data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    func getInt<T: BigEndianConvertible>(zeroedType: T) -> T {
        var buffer = zeroedType
        let length = MemoryLayout<T>.size
        (data as NSData).getBytes(&buffer, range: NSRange(location: index, length: length))
        index += length
        
        return T(bigEndian: buffer)
    }
    
    func getFloat32() -> Float32 {
        var buffer: UInt32 = 0
        let length = 4
        (data as NSData).getBytes(&buffer, range: NSRange(location: index, length: length))
        index += length
        
        return Float32(bitPattern: UInt32(bigEndian: buffer))
    }
    
    func getCString() -> String {
        let maxLength = (data.count - index - 1)
        let stringData = data.subdata(in: index..<index + maxLength)
        let string = String(cString: [UInt8](stringData))
        index += (string.characters.count) //(why not: +1 for null-terminator?)
        
        return string
    }
    
    func skip(bytes: Int) {
        index += bytes
    }
}

extension ImportedStrokes {
    fileprivate func normalized() -> ImportedStrokes {
        let max = (points.map { $0.x } + points.map { $0.y }).max() ?? 1
        let scale: CGFloat = 300
        
        let np = points.map { point in
            return CGPoint(x: (point.x / max) * scale,
                           y: (point.y / max) * scale)
        }
        
        return ImportedStrokes(points: np)
    }
}
