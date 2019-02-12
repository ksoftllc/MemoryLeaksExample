//
//  PlayGamesViewController.swift
//
//  Created by Chuck Krutsinger on 2/8/19.
//  Copyright © 2019 Countermind, LLC. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PlayGamesViewController: UIViewController {

    @IBOutlet weak var playTetrisTap: UIButton!
    
    private var bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let viewModel = playGamesViewModel(playTetrisTap: playTetrisTap.rx.tap.asObservable())
        
        bag.insert(
            viewModel
        )
    }
    
    #if DEBUG
    deinit {
        print("\(String(describing: self)) deinit")
    }
    #endif
}
