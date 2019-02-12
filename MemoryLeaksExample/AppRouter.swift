//
//  AppRouter.swift
//
//  Created by Chuck Krutsinger on 2/5/19.
//  Copyright © 2019 Countermind, LLC. All rights reserved.
//

import ReSwift
import RxSwift
import CMUtilities


//all storyboards need a case
enum RoutingDestination: String {
    case loginStoryboard = "Login"
    case homeScreenStoryboard = "HomeScreen"
    case playGamesStoryboard = "PlayGames"
    case viewProfileStoryboard = "ViewProfile"
}

//
enum RoutingAction: AppRouterAction {
    case displayLoginScreen
    case displayHomeScreen
    case pushTetris
    case push(_ destination: RoutingDestination)
    case alert(title: String, message: String, completion: (() -> Void)?)
}

protocol AppRouterAction: Action {}  

enum AppRouterPrivateAction: AppRouterAction {
    case wasPoppedByNavController //update state when view popped by nav controller
    case alertClosed //update
}


func routingReducer(action: Action, state: RoutingState?) -> RoutingState {
    
    var state = state ?? RoutingState()
    
    if let routingAction = action as? RoutingAction {
        switch routingAction {

        case .displayLoginScreen:
            state.displayedRoute = .rootWindow(.loginStoryboard)
            state.routingStack.reset()
            state.routingStack.push(state.displayedRoute!)
        case .displayHomeScreen:
            state.displayedRoute = .rootWindow(.homeScreenStoryboard)
            state.routingStack.reset()
            state.routingStack.push(state.displayedRoute!)
        case .push(let destination):
            state.displayedRoute = .push(destination)
            state.routingStack.push(state.displayedRoute!)
        case .alert(let title, let message, let completion):
            state.displayedRoute = .alert(title: title, message: message, completion: completion)
        case .pushTetris:
            //use alert until this is implemented
            state.displayedRoute = .alert(title: "Not Implemented", message: "Tetris is not yet implemented", completion: nil)
        }
        
    } else if let appRouterAction = action as? AppRouterPrivateAction {
        switch appRouterAction {
        case .wasPoppedByNavController:
            _ = state.routingStack.pop()
            state.displayedRoute = nil
        case .alertClosed:
            state.displayedRoute = nil
        }
    }
    
    return state
}

struct RoutingState: StateType {
    
    enum Route {
        case rootWindow(_ destination: RoutingDestination)
        case push(_ destination: RoutingDestination)
        case alert(title: String, message: String, completion: (() -> Void)?)
    }
    
    fileprivate var displayedRoute: Route?
    fileprivate var routingStack = Stack<Route>()
    
    private mutating func resetRoutingStack() {
        routingStack = Stack<Route>()
    }
    
    init(navigationState: Route = .rootWindow(.loginStoryboard)) {
        switch navigationState {
        case .rootWindow(_):
            routingStack.reset()
            routingStack.push(navigationState)
        case .push(_):
            fatalError("push is not a valid initial state")
        case .alert(_, _, _):
            fatalError("alert is not a valid initial state")
        }
        displayedRoute = navigationState
    }
}


class AppRouter: NSObject {
    
    private let navigationController: UINavigationController
    private var navigationControllerArraySize: Int = 0
    private var bag = DisposeBag()
    
    init(window: UIWindow) {
        navigationController = UINavigationController()
        super.init()

        navigationController.delegate = self
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
        if let displayedRoute = state.displayedRoute {
            switch displayedRoute {
                
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
                        handler = { (action: UIAlertAction) in
                            Dependencies.router(AppRouterPrivateAction.alertClosed)
                            completion()
                        }
                    } else {
                        handler = { (action: UIAlertAction) in
                            Dependencies.router(AppRouterPrivateAction.alertClosed)
                        }
                    }
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
                    topViewController.present(alert, animated: true)
                }
            }
        }
    }
}

extension AppRouter: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let newArraySize = navigationController.viewControllers.count
        let isNotResettingRootView = navigationController.viewControllers.count > 0
        if isNotResettingRootView && (newArraySize < navigationControllerArraySize) {
            Dependencies.router(AppRouterPrivateAction.wasPoppedByNavController)
        }
        navigationControllerArraySize = newArraySize
    }
}

//Convenience functions
func appRouterAction(_ action: RoutingAction) {
    Dependencies.router(action)
}


