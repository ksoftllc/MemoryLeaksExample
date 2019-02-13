//
//  UITableViewConfigurators.swift
//  CMUtilities
//
//  Created by Chuck Krutsinger on 2/13/19.
//  Copyright © 2019 Countermind, LLC. All rights reserved.
//

import UIKit

func hideTableViewFooter(_ tableView: UITableView) {
    tableView.tableFooterView = UIView(frame: CGRect.zero)
}
