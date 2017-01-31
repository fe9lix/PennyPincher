//
//  AndroidGesturesToPennyPincher.swift
//  PennyPincherExample
//
//  Created by Raf Cabezas on 1/30/17.
//  Copyright © 2017 WillowTree, Inc. All rights reserved.
//

import Foundation

//Comments from: https://android.googlesource.com/platform/frameworks/base/+/master/core/java/android/gesture/GestureStore.java :
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

struct AndroidGesturesFile {
    struct Header {
        let version: Int16
        let entryCount: Int32
    }

    struct Entry {
        let name: String
        let gestureCount: Int32
    }

    struct Gesture {
        let id: Int64
        let strokeCount: Int32
    }
    
    struct Stroke {
        let pointsCount: Int32
    }
    
    struct Point {
        let x: Float32
        let y: Float32
        let timeStamp: Int64
    }
}

protocol ByteSwappable {
    var byteSwapped: Self { get }
    init()
}

extension Int16: ByteSwappable {}
extension Int32: ByteSwappable {}
extension Int64: ByteSwappable {}

extension Data {
    func dump(length: Int) {
        let array = [UInt8](self)
        for (idx, byte) in array.enumerated() {
            guard idx < length else {
                break
            }
            print(String(format:"0x%x %c", byte, byte))
        }
    }
}

class BigEndianDataReader {
    var index = 0
    let data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    func getInt<T: ByteSwappable>(zeroedType: T) -> T {
        var buffer = zeroedType
        let length = MemoryLayout<T>.size
        (data as NSData).getBytes(&buffer, range: NSRange(location: index, length: length))
        index += length
        
        return buffer.byteSwapped
    }
    
    func getFloat32() -> Float32 {
        var buffer: UInt32 = 0
        let length = 4
        (data as NSData).getBytes(&buffer, range: NSRange(location: index, length: length))
        let value = unsafeBitCast(buffer.byteSwapped, to: Float32.self)
        index += length
        
        return value
    }

    func getCString() -> String {
        let maxLength = (data.count - index - 1)
        let stringData = data.subdata(in: index..<index + maxLength)
//        stringData.dump(length: 8)
        let string = String(cString: [UInt8](stringData))
        index += (string.characters.count) //(why not: +1 for null-terminator?)
        
        return string
    }
    
    func skip(bytes: Int) {
        index += bytes
    }
}

class AndroidRecognizerToPennyPincher {
    
    func loadGesturesFile() {
        guard let path = Bundle.main.path(forResource: "gestures", ofType: "bin") else {
            print("File not found")
            return
        }
        
        print("loadGesturesFile invoked. path=\(path)")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            print("Error reading data")
            return
        }
        
        print("Read \(data.count)bytes")
        
        //BigEndian reader
        let reader = BigEndianDataReader(data: data)
        
        //Header
        let header = AndroidGesturesFile.Header(version: reader.getInt(zeroedType: Int16()),
                                                entryCount: reader.getInt(zeroedType: Int32()))
        
        print("Header data: version=\(header.version) entries=\(header.entryCount)")
        
        for entryNumber in 0..<header.entryCount {
            //Entry
            let unk = reader.getInt(zeroedType: Int16()) //there's 2 extra bytes here for some reason....
            let entry = AndroidGesturesFile.Entry(name: reader.getCString(), gestureCount: reader.getInt(zeroedType: Int32()))
            print("Entry #\(entryNumber): name=\(entry.name) gestures=\(entry.gestureCount) Unk=\(unk)")
            
            for gestureNumber in 0..<entry.gestureCount {
                let gesture = AndroidGesturesFile.Gesture(id: reader.getInt(zeroedType: Int64()), strokeCount: reader.getInt(zeroedType: Int32()))
                
                print("Gesture #\(gestureNumber): id=\(gesture.id) strokes=\(gesture.strokeCount)")
                
                for strokeNumber in 0..<gesture.strokeCount {
                    
                    let stroke = AndroidGesturesFile.Stroke(pointsCount: reader.getInt(zeroedType: Int32()))

                    print("Stroke #\(strokeNumber): points=\(stroke.pointsCount)")
                    
                    for pointNumber in 0..<stroke.pointsCount {
                        
                        let point = AndroidGesturesFile.Point(x: reader.getFloat32(),
                                                              y: reader.getFloat32(),
                                                              timeStamp: reader.getInt(zeroedType: Int64()))
                        
                        print("Point #\(pointNumber): (\(point.x), \(point.y)) timestamp:\(point.timeStamp)")
                    }
                }
            }
        }
    }
}
