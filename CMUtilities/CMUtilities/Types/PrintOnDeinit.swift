//
//  PrintOnDeinit.swift
//  CMUtilities
//
//  Created by Chuck Krutsinger on 2/14/19.
//  Copyright © 2019 Countermind, LLC. All rights reserved.
//

public class PrintOnDeinit {
    private let message: String
    
    init(message: String) {
        self.message = message
    }
    
    deinit {
        print("\(message)")
    }
}
