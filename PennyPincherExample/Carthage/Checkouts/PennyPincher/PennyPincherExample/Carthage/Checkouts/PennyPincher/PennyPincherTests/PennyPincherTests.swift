//
//  PennyPincherTests.swift
//  PennyPincherTests
//
//  Created by Felix on 28.07.15.
//  Copyright © 2015 betriebsraum. All rights reserved.
//

import XCTest
@testable import PennyPincher

class PennyPincherTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInvalidTemplate() {
        let template = PennyPincher.createTemplate("A", points: [CGPoint]())
        
        XCTAssert(template == nil)
    }
    
    func testValidTemplate() {
        let points = templatePoints()
        let template = PennyPincher.createTemplate("e", points: points)!
        
        XCTAssertEqual(template.id, "e")
        XCTAssert(template.points.count < points.count)
    }
    
    func testInvalidRecognition() {
        if let (_, _) = PennyPincher.recognize([CGPoint](), templates: [PennyPincherTemplate]()) {
            XCTFail("Did not expect recognition result.")
        } else {
            XCTAssertTrue(true)
        }
    }
    
    func testTemplateRecognition() {
        let points = templatePoints()
        let template = PennyPincher.createTemplate("e", points: points)!
        var templates = randomTemplates(10)
        templates.append(template)
        
        if let (foundTemplate, _) = PennyPincher.recognize(points, templates: templates) {
            XCTAssertEqual(foundTemplate.id, template.id)
        } else {
            XCTFail("Expected recognition result.")
        }
    }
    
    func testExactRecognition() {
        let points = templatePoints()
        let template = PennyPincher.createTemplate("e", points: points)
        
        if let template = template, let (foundTemplate, similarity) = PennyPincher.recognize(points, templates: [template]) {
            XCTAssertEqual(foundTemplate.id, template.id)
            XCTAssertEqualWithAccuracy(similarity, 12.0, accuracy: 0.1)
        } else {
            XCTFail("Expected recognition result.")
        }
    }
    
    func testRecognitionPerformance() {
        let points = templatePoints()
        let templates = randomTemplates(1000)
        
        self.measure() {
            _ = PennyPincher.recognize(points, templates: templates)
        }
    }
    
    // MARK: Helper functions
    
    private func randomTemplates(_ count: Int) -> [PennyPincherTemplate] {
        var templates = [PennyPincherTemplate]()
        let points = templatePoints()
        
        for i in 0..<count {
            if let template = PennyPincher.createTemplate("\(i)", points: shufflePoints(points)) {
                templates.append(template)
            }
        }
        
        return templates
    }
    
    private func templatePoints() -> [CGPoint] {
        return [
            CGPoint(x: 137.0, y: 284.0),
            CGPoint(x: 142.0, y: 281.0),
            CGPoint(x: 150.5, y: 276.0),
            CGPoint(x: 166.0, y: 268.0),
            CGPoint(x: 183.0, y: 257.5),
            CGPoint(x: 207.5, y: 244.0),
            CGPoint(x: 229.5, y: 231.0),
            CGPoint(x: 249.0, y: 218.0),
            CGPoint(x: 266.0, y: 204.0),
            CGPoint(x: 277.5, y: 192.5),
            CGPoint(x: 286.0, y: 181.0),
            CGPoint(x: 291.5, y: 172.0),
            CGPoint(x: 295.0, y: 163.0),
            CGPoint(x: 296.5, y: 153.0),
            CGPoint(x: 297.0, y: 143.5),
            CGPoint(x: 297.0, y: 134.5),
            CGPoint(x: 294.0, y: 126.0),
            CGPoint(x: 287.5, y: 118.5),
            CGPoint(x: 276.0, y: 111.5),
            CGPoint(x: 258.5, y: 107.0),
            CGPoint(x: 234.5, y: 106.5),
            CGPoint(x: 210.5, y: 107.5),
            CGPoint(x: 187.0, y: 117.5),
            CGPoint(x: 163.0, y: 134.5),
            CGPoint(x: 136.5, y: 161.5),
            CGPoint(x: 115.0, y: 192.0),
            CGPoint(x: 98.0, y: 227.5),
            CGPoint(x: 86.5, y: 266.0),
            CGPoint(x: 79.5, y: 304.5),
            CGPoint(x: 79.0, y: 342.5),
            CGPoint(x: 79.5, y: 372.0),
            CGPoint(x: 91.5, y: 399.5),
            CGPoint(x: 112.0, y: 420.5),
            CGPoint(x: 144.5, y: 433.5),
            CGPoint(x: 179.5, y: 435.0),
            CGPoint(x: 216.5, y: 429.0),
            CGPoint(x: 251.5, y: 410.5),
            CGPoint(x: 280.5, y: 388.5),
            CGPoint(x: 300.0, y: 370.5),
            CGPoint(x: 312.5, y: 356.0)
        ]
    }
    
    private func shufflePoints(_ points: [CGPoint]) -> [CGPoint] {
        let count = points.count
        var newPoints = points
        
        for i in 0..<newPoints.count {
            let randNum = Int(arc4random_uniform(UInt32(count - i)))
            let tmp = points[i]
            newPoints[i] = newPoints[randNum]
            newPoints[randNum] = tmp
        }
        
        return newPoints
    }
}
