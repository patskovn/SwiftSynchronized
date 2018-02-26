//
//  ViewController.swift
//  SwiftSynchronized
//
//  Created by nd.packov on 02/22/2018.
//  Copyright (c) 2018 nd.packov. All rights reserved.
//

import UIKit
import SwiftSynchronized


class ViewController: UIViewController {
	
	var synchronizedMap = SynchronizedDictionary<Int, Any>.init(object: [:])
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		DispatchQueue.concurrentPerform(iterations: 1000) { index in
			print(index)
			self.synchronizedMap[index] = "\(index)"
			self.synchronizedMap[22] = "NONONO"
		}
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
}

