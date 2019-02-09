//
//  AppRouter.swift
//
//  Created by Chuck Krutsinger on 2/5/19.
//  Copyright © 2019 Countermind, LLC. All rights reserved.
//

import ReSwift
import RxSwift


//all storyboards need a case
enum RoutingDestination: String {
    case loginStoryboard = "Login"
    case homeScreenStoryboard = "HomeScreen"
    case playGamesStoryboard = "PlayGames"
    case viewProfileStoryboard = "ViewProfile"
}

struct RoutingState: StateType {
    
    enum Route {
        case rootWindow(_ destination: RoutingDestination)
        case push(_ destination: RoutingDestination)
        case alert(title: String, message: String, completion: (() -> Void)?)
    }

    var navigationState: Route
    
    init(navigationState: Route = .rootWindow(.loginStoryboard)) {
        self.navigationState = navigationState
    }
}


enum RoutingAction: Action {
    case displayLoginScreen
    case displayHomeScreen
    case push(_ destination: RoutingDestination)
    case alert(title: String, message: String, completion: (() -> Void)?)
}

func routingReducer(action: Action, state: RoutingState?) -> RoutingState {
    
    var state = state ?? RoutingState()
    
    if let routingAction = action as? RoutingAction {
        switch routingAction {

        case .displayLoginScreen:
            state.navigationState = .rootWindow(.loginStoryboard)
        case .displayHomeScreen:
            state.navigationState = .rootWindow(.homeScreenStoryboard)
        case .push(let destination):
            state.navigationState = .push(destination)
        case .alert(let title, let message, let completion):
            state.navigationState = .alert(title: title, message: message, completion: completion)
        }
    }
    return state
}

class AppRouter {
    
    private let navigationController: UINavigationController
    private var bag = DisposeBag()
    
    init(window: UIWindow) {
        navigationController = UINavigationController()
        window.rootViewController = navigationController
        Dependencies.appRouterState
            .subscribe(onNext: { [weak self] in
                self?.processStateChanges(state: $0)
            })
            .disposed(by: bag)
    }
    
    private func pushViewController(identifier: String, animated: Bool) {
        let viewController = instantiateViewController(identifier: identifier)
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    private func instantiateViewController(identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: identifier, bundle: nil)
        return instantiateInitialViewController(for: storyboard)
    }
    
    private func instantiateInitialViewController(for storyboard: UIStoryboard) -> UIViewController {
        guard let initialViewController = storyboard.instantiateInitialViewController() else {
            fatalError("\(storyboard) does not have an initial view controller - designate the initial view controller in storyboard")
        }
        return initialViewController
    }
    
    func processStateChanges(state: RoutingState) {
        switch state.navigationState {
            
        case .rootWindow(let destination):
            let destinationViewController = instantiateViewController(identifier: destination.rawValue)
            navigationController.setViewControllers([destinationViewController], animated: false)
        case .push(let destination):
            let shouldAnimate = navigationController.topViewController != nil
            pushViewController(identifier: destination.rawValue, animated: shouldAnimate)
        case .alert(let title, let message, let completion):
            if let topViewController = navigationController.topViewController {
                let handler: ((UIAlertAction) -> ())?
                if let completion = completion {
                    handler = { (action: UIAlertAction) in completion() }
                } else {
                    handler = { (action: UIAlertAction) in return }
                }
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
                topViewController.present(alert, animated: true)
            }
        }
    }
}

//Convenience functions
func appRouterAction(_ action: RoutingAction) {
    Dependencies.router(action)
}
