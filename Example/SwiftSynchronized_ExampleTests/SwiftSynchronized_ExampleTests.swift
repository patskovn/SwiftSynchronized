//
//  SwiftSynchronized_ExampleTests.swift
//  SwiftSynchronized_ExampleTests
//
//  Created by Пацков Н.Д. on 22/02/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import SwiftSynchronized

class SwiftSynchronized_ExampleTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testConcurrent() {
		// This is an example of a performance test case.
		var synchronizedMap = SynchronizedDictionary<Int, Any>.init(object: [:])
		
		DispatchQueue.concurrentPerform(iterations: 1000) { index in
			synchronizedMap[index] = "\(index)"
			synchronizedMap[22] = "NONONO"
		}
	}
	
	func testSyncMapExample() {
		// This is an example of a performance test case.
		var synchronizedMap = SynchronizedDictionary<Int, Any>.init(object: [:])
		
		var index = 0
		func index1() -> Int {
			index += 1
			return index
		}
		
		self.measure() {
			let index = index1()
			synchronizedMap[index] = "\(index)"
			synchronizedMap[22] = "NONONO"
		}
	}
	
	func testSimpleDictExample() {
		// This is an example of a performance test case.
		var synchronizedMap = Dictionary<Int, Any>.init()
		
		var index = 0
		func index1() -> Int {
			index += 1
			return index
		}
		
		self.measure() {
			let index = index1()
			synchronizedMap[index] = "\(index)"
			synchronizedMap[22] = "NONONO"
		}
	}
	
}


