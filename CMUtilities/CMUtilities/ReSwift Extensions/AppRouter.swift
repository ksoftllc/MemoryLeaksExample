//
//  AppRouter.swift
//  CMUtilities
//
//  Created by Chuck Krutsinger on 2/12/19.
//  Copyright © 2019 Countermind, LLC. All rights reserved.
//

import ReSwift
import RxSwift


///Marker protocol for `Action` enum defined in the app.
public protocol AppRouterAction: Action {}

///App's reducer must conform to this type
public typealias AppRouterReducer = (AppRouterAction, AppRouterState?) -> AppRouterState

///App should provide an enum of its `Storyboard`s that will be routing destinations
public protocol AppRouterDestination {
    var rawValue: String { get }
}

fileprivate enum AppRouterPrivateAction: Action {
    //TODO: implement popToRootView and popToView
    case wasPoppedByNavController //update state when view popped by nav controller
    case alertClosed //update
}

public struct AppRouterState: StateType {
    
    public enum Route {
        case rootWindow(_ destination: AppRouterDestination)
        case push(_ destination: AppRouterDestination)
        case alert(title: String, message: String, completion: (() -> Void)?)
    }
    
    ///Route that the AppRouter is to display. If nil, display will not be updated.
    fileprivate var routeToDisplay: Route?
    
    ///Stack used to keep track of UINavigationController pushes and pops
    fileprivate var routingStack = Stack<Route>()
    
    private mutating func resetRoutingStack() {
        routingStack = Stack<Route>()
    }
    
    public init(route: Route) {
        switch route {
            
        case .rootWindow(_):
            updateRoute(route)
        case .push(_):
            fatalError("push is not a valid initial state")
        case .alert(_, _, _):
            fatalError("alert is not a valid initial state")
        }
        routeToDisplay = route
    }
    
    public mutating func updateRoute(_ route: Route) {
        switch route {
            
        case .rootWindow(_):
            routingStack.reset()
            routingStack.push(route)
        case .push(_):
            routingStack.push(route)
        case .alert(_, _, _):
            break
        }

        routeToDisplay = route
    }
}


public class AppRouter: NSObject {
    
    private let navigationController = UINavigationController()
    private var navigationControllerArraySize: Int = 0
    private var bag = DisposeBag()
    
    public init(window: UIWindow, appRouterState: Observable<AppRouterState>) {
        super.init()
        
        navigationController.delegate = self
        window.rootViewController = navigationController
        appRouterState
            .subscribe(onNext: { [weak self] in
                self?.stateDidChange(state: $0)
            })
            .disposed(by: bag)
    }
    
    fileprivate static var instance: RxStore<AppRouterState>?
    
    public static func storeInstance(reducer: @escaping AppRouterReducer, initialState: AppRouterState)
                    -> RxStore<AppRouterState> {
        
        let appRouterReducer: (Action, AppRouterState?) -> AppRouterState = { action, state in
            
//            guard var state = state else {
//                fatalError("AppRouter state was never initialized.")
//            }
            var state = state ?? initialState
            
            if let AppRouterAction = action as? AppRouterAction {
                state = reducer(AppRouterAction, state)
            } else if let appRouterAction = action as? AppRouterPrivateAction {
                switch appRouterAction {
                case .wasPoppedByNavController:
                    _ = state.routingStack.pop()
                    state.routeToDisplay = nil
                case .alertClosed:
                    state.routeToDisplay = nil
                }
            }
            
            return state
        }
        
        return RxStore<AppRouterState>(reducer: appRouterReducer, initialState: nil)
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
    
    func stateDidChange(state: AppRouterState) {
        if let displayedRoute = state.routeToDisplay {
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
                            appRouterAction(AppRouterPrivateAction.alertClosed)
                            completion()
                        }
                    } else {
                        handler = { (action: UIAlertAction) in
                            appRouterAction(AppRouterPrivateAction.alertClosed)
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
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let newArraySize = navigationController.viewControllers.count
        let isNotResettingRootView = navigationController.viewControllers.count > 0
        if isNotResettingRootView && (newArraySize < navigationControllerArraySize) {
            appRouterAction(AppRouterPrivateAction.wasPoppedByNavController)
        }
        navigationControllerArraySize = newArraySize
    }
}

//Convenience functions
fileprivate func appRouterAction(_ action: Action) {
    guard let appRouter = AppRouter.instance else {
        fatalError("No AppRouter instance")
    }
    appRouter.dispatch(action)
}

fileprivate var appRouterState: Observable<AppRouterState> {
    guard let appRouter = AppRouter.instance else {
        fatalError("App must invoke AppRouter.storeInstance(...) during app launch" )
    }
    return appRouter.state
}

