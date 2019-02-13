//
//  Game.swift
//
//  Created by Chuck Krutsinger on 2/12/19.
//  Copyright © 2019 Countermind, LLC. All rights reserved.
//

typealias GameName = String
typealias Objective = String

struct Game {
    let name: GameName
    let minPlayers: Int
    let maxPlayers: Int
    let objective: Objective
}

