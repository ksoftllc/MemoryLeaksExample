//
//  HomeScreenViewModel.swift
//
//  Created by Chuck Krutsinger on 2/8/19.
//  Copyright © 2019 Countermind, LLC. All rights reserved.
//

import ReSwift
import RxSwift
import RxCocoa

struct HomeScreenViewModel {
    
    struct UIInputs {
        let viewProfileTap: Observable<Void>
        let playGamesTap: Observable<Void>
        let logoutTap: Observable<Void>
    }
    
    //UIOutputs
    let username: Driver<Username>
    let viewProfileDisposable: Disposable
    let playGamesDisposable: Disposable
    let logoutDisposable: Disposable
}

extension HomeScreenViewModel {
   
    init(_ inputs: UIInputs ) {
    
        username = Dependencies.appState
            .map { $0.loginState.loginStatus.username }
            .unwrapOptional()
            .map { "\($0) - Home Screen" }
            .asDriverLogError()
        
        viewProfileDisposable = inputs.viewProfileTap
            .subscribe(onNext: pushViewProfileView)
        
        playGamesDisposable = inputs.playGamesTap
            .subscribe(onNext: pushPlayGamesView)
        
        logoutDisposable = inputs.logoutTap
            .do(onNext: logUserOut)
            .subscribe(onNext: displayLoginScreen)
    }
}

fileprivate func pushPlayGamesView() {
    appRouter(.push(.playGamesStoryboard))
}

fileprivate func pushViewProfileView() {
    appRouter(.push(.viewProfileStoryboard))
}

fileprivate func displayLoginScreen() {
    appRouter(.displayLoginScreen)
}
