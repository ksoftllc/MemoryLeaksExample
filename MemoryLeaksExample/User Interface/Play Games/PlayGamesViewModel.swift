//
//  PlayGamesViewModel.swift
//  MemoryLeaksExample
//
//  Created by Chuck Krutsinger on 2/11/19.
//  Copyright © 2019 Countermind, LLC. All rights reserved.
//

import RxSwift


struct PlayGamesViewModel {
    
    let gameNames: Observable<[GameName]>
    
    init() {
        gameNames = GamesRepository().allGames.map { $0.map { $0.name } }
    }
}
