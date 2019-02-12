//
//  PlayGamesViewModel.swift
//  MemoryLeaksExample
//
//  Created by Chuck Krutsinger on 2/11/19.
//  Copyright © 2019 Countermind, LLC. All rights reserved.
//

import RxSwift

func playGamesViewModel(playTetrisTap: Observable<Void>)
    -> Disposable {
    return playTetrisTap
        .subscribe(onNext: {
            Dependencies.routerAction(RoutingAction.pushTetris)
        })
}
