//
//  PlayGamesViewModel.swift
//  MemoryLeaksExample
//
//  Created by Chuck Krutsinger on 2/11/19.
//  Copyright © 2019 Countermind, LLC. All rights reserved.
//

import RxSwift
import RxCocoa

private class PrintOnDeinit {
    private let message: String
    
    init(message: String) {
        self.message = message
    }
    
    deinit {
        print("\(message)")
    }
}

struct PlayGamesViewModel {
    
    private let gamesRepository = GamesRepository()
    
    //UI Outputs
    let gameNames: Observable<[GameName]>
    let rowSelectedDisposable: Disposable
    
    init(rowSelected: Observable<Int>) {
        gameNames = gamesRepository.allGames.map { $0.map { $0.name } }
        
        rowSelectedDisposable = rowSelected
            .subscribe(onNext: {
                print("chose row \($0)")
            })
    }
}
