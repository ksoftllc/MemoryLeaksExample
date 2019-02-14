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
    
    private let games = GamesRepository().allGames.share()
    
    struct UIInputs {
        let rowSelected: Observable<Int>
    }
    
    //UI Outputs
    let gameNames: Observable<[GameName]>
    let rowSelectedDisposable: Disposable
    
    init(inputs: UIInputs) {
        gameNames = games.map { $0.map { $0.name } }
 
        rowSelectedDisposable = Observable.combineLatest(inputs.rowSelected, games)
            .map { row, games in games[row] }
            .subscribe(onNext: displayGameDetails)
    }
}

fileprivate func displayGameDetails(_ game: Game) {
    let players = game.minPlayers == game.maxPlayers
        ? "\(game.minPlayers)"
        : "\(game.minPlayers) to \(game.maxPlayers)"
    let message = """
    Players: \(players)
    Objective: \(game.objective)
    """
    appRouterAction(
        .alert(title: game.name, message: message, completion: nil)
    )
}

