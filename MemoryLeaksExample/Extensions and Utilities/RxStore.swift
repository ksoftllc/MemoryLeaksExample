//
//  RxStore.swift
//
//  Created by Chuck Krutsinger on 2/6/19.
//  Copyright © 2019 Countermind, LLC. All rights reserved.
//

import RxSwift
import RxCocoa
import ReSwift

///Wrapper class to provide an RxSwift `Observable` of ReSwift `Store`.
class RxStore<AnyStateType: StateType> {
    
    private var stateRelay: BehaviorRelay<AnyStateType?> = BehaviorRelay<AnyStateType?>(value: nil)
    private var store: Store<AnyStateType>
    
    init(reducer: @escaping Reducer<AnyStateType>, initialState: AnyStateType?, middleware: [Middleware<AnyStateType>] = []) {
        self.store = Store<AnyStateType>(reducer: reducer, state: initialState, middleware: middleware)
        self.store.subscribe(self)
    }
    
    deinit {
        self.store.unsubscribe(self)
    }
    
    func dispatch(_ action: Action) {
        store.dispatch(action)
    }
    
    var state: Observable<AnyStateType> {
        return stateRelay.asObservable().unwrapOptional()
    }
}

extension RxStore: StoreSubscriber {
    
    func newState(state newState: AnyStateType) {
        stateRelay.accept(newState)
    }
}


