//
//  Dependencies.swift
//
//  Created by Chuck Krutsinger on 2/4/19.
//  Copyright © 2019 Countermind, LLC. All rights reserved.
//

import Foundation
import RxSwift
import ReSwift

//Functional method of dependency injection as described at https://www.pointfree.co/blog/posts/21-how-to-control-the-world
struct Environment {
    //LoginService
    var loginValidator = mockLoginValidatorService
    
    //AppState
    var app: (AppAction) -> Void = { action in appStateStore.dispatch(action) }
    var appState: Observable<AppState> = appStateStore.state
    
    //AppRouter
    var router: (RoutingAction) -> Void = { action in appRouterStateStore.dispatch(action) }
    var appRouterState: Observable<RoutingState> = appRouterStateStore.state
    
    //LoginView
    var loginView: (LoginViewAction) -> Void = { action in loginViewStateStore.dispatch(action) }
    var loginViewState: Observable<LoginViewState> = loginViewStateStore.state
}

//immutable for release build
#if DEBUG
var Dependencies = Environment()
#else
let Dependencies = Environment()
#endif

fileprivate var appStateStore = RxStore<AppState>(reducer: appReducer, initialState: nil)
fileprivate var appRouterStateStore = RxStore<RoutingState>(reducer: routingReducer, initialState: nil)
fileprivate var loginViewStateStore = RxStore<LoginViewState>(reducer: loginViewReducer, initialState: nil)
