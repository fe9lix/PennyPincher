//
//  PennyPincherAndroidGesturesImporter.swift
//  PennyPincher
//
//  Created by Raf Cabezas on 1/30/17.
//  Copyright © 2017 WillowTree, Inc. All rights reserved.
//

import Foundation

public struct ImportedStrokes {
    public let points: [CGPoint]
    
    public init(points: [CGPoint]) {
        self.points = points
    }
}

public struct ImportedGesture {
    public let id: String
    public let strokes: [ImportedStrokes]
    
    public init(id: String, strokes: [ImportedStrokes]) {
        self.id = id
        self.strokes = strokes
    }
    
    public var allPoints: [CGPoint] {
        return strokes.flatMap { $0.points }
    }
}
