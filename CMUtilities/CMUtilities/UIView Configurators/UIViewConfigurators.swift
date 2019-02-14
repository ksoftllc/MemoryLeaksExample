//
//  UIViewConfigurators.swift
//  CMUtilities
//
//  Created by Chuck Krutsinger on 2/14/19.
//  Copyright © 2019 Countermind, LLC. All rights reserved.
//

import Foundation

public func makeViewRound(view: UIView) {
    assert(view.frame.height == view.frame.width, "view must be equal height/width in order to become round")
    view.layer.masksToBounds = true
    view.layer.cornerRadius = view.frame.height / 2.0 //radius
    view.clipsToBounds = true
}
