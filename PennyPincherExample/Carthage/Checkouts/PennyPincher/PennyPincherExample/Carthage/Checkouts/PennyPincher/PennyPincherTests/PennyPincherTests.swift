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
        
        if let template = template, (foundTemplate, similarity) = PennyPincher.recognize(points, templates: [template]) {
            XCTAssertEqual(foundTemplate.id, template.id)
            XCTAssertEqualWithAccuracy(similarity, 12.0, accuracy: 0.1)
        } else {
            XCTFail("Expected recognition result.")
        }
    }
    
    func testRecognitionPerformance() {
        let points = templatePoints()
        let templates = randomTemplates(1000)
        
        self.measureBlock() {
            PennyPincher.recognize(points, templates: templates)
        }
    }
    
    // MARK: Helper functions
    
    func randomTemplates(count: Int) -> [PennyPincherTemplate] {
        var templates = [PennyPincherTemplate]()
        let points = templatePoints()
        
        for i in 0..<count {
            if let template = PennyPincher.createTemplate("\(i)", points: shufflePoints(points)) {
                templates.append(template)
            }
        }
        
        return templates
    }
    
    func templatePoints() -> [CGPoint] {
        return [
            CGPointMake(137.0, 284.0),
            CGPointMake(142.0, 281.0),
            CGPointMake(150.5, 276.0),
            CGPointMake(166.0, 268.0),
            CGPointMake(183.0, 257.5),
            CGPointMake(207.5, 244.0),
            CGPointMake(229.5, 231.0),
            CGPointMake(249.0, 218.0),
            CGPointMake(266.0, 204.0),
            CGPointMake(277.5, 192.5),
            CGPointMake(286.0, 181.0),
            CGPointMake(291.5, 172.0),
            CGPointMake(295.0, 163.0),
            CGPointMake(296.5, 153.0),
            CGPointMake(297.0, 143.5),
            CGPointMake(297.0, 134.5),
            CGPointMake(294.0, 126.0),
            CGPointMake(287.5, 118.5),
            CGPointMake(276.0, 111.5),
            CGPointMake(258.5, 107.0),
            CGPointMake(234.5, 106.5),
            CGPointMake(210.5, 107.5),
            CGPointMake(187.0, 117.5),
            CGPointMake(163.0, 134.5),
            CGPointMake(136.5, 161.5),
            CGPointMake(115.0, 192.0),
            CGPointMake(98.0, 227.5),
            CGPointMake(86.5, 266.0),
            CGPointMake(79.5, 304.5),
            CGPointMake(79.0, 342.5),
            CGPointMake(79.5, 372.0),
            CGPointMake(91.5, 399.5),
            CGPointMake(112.0, 420.5),
            CGPointMake(144.5, 433.5),
            CGPointMake(179.5, 435.0),
            CGPointMake(216.5, 429.0),
            CGPointMake(251.5, 410.5),
            CGPointMake(280.5, 388.5),
            CGPointMake(300.0, 370.5),
            CGPointMake(312.5, 356.0)
        ]
    }
    
    func shufflePoints(points: [CGPoint]) -> [CGPoint] {
        let count = points.count
        var newPoints = points
        
        for i in 0..<newPoints.count {
            let randNum = Int(arc4random_uniform(UInt32(count - i)))
            let tmp = points[i]
            newPoints[i] = newPoints[randNum]
            newPoints[randNum] = tmp;
        }
        
        return newPoints;
    }
    
}
