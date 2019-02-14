//
//  PlayGamesViewController.swift
//
//  Created by Chuck Krutsinger on 2/8/19.
//  Copyright © 2019 Countermind, LLC. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CMUtilities

class PlayGamesViewController: UIViewController {
    
    private static let gameCellId = "gameCell"

    @IBOutlet weak var gamesTable: UITableView!
    
    private var bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gamesTable |> hideTableViewFooter
        
        let cellNib = UINib.init(nibName: "GameCell", bundle: nil)
        gamesTable.register(cellNib, forCellReuseIdentifier: PlayGamesViewController.gameCellId)

        let viewModel = PlayGamesViewModel(rowSelected: gamesTable.rx.itemSelected.map { $0.row }) 
        
        bag.insert(
            viewModel.gameNames.bind(to: gamesTable.rx.items) { [weak self](tableView, row, element) in
                let cell = self?.gamesTable.dequeueReusableCell(withIdentifier: PlayGamesViewController.gameCellId) as! GameCell
                cell.nameLabel.text = element
                return cell
            },
            
            viewModel.rowSelectedDisposable
        )

    }
    
    #if DEBUG
    deinit {
        print("\(String(describing: self)) deinit")
    }
    #endif
}
