//
//  LoginViewModel.swift
//
//  Created by Chuck Krutsinger on 2/4/19.
//  Copyright © 2019 Countermind, LLC. All rights reserved.
//

import RxSwift
import RxCocoa

struct LoginViewModel {
    
    struct UIInputs {
        let viewState: Observable<LoginViewState>
        let username: Observable<Username>
        let password: Observable<Password>
        let loginTap: Observable<Void>
    }
    
    //UI Outputs
    let loginEnabled: Driver<Bool>
    let validatingCredentials: Driver<Bool>
    let loginTapDisposable: Disposable
}


extension LoginViewModel {
    init(_ inputs: UIInputs) {
        let usernameAndPassword = Observable.combineLatest(inputs.username, inputs.password)
            .share()
        
        let isCredentialsEntered = usernameAndPassword
            .map(bothStringsNotEmpty)
        
        let isViewStateEnteringCredentials = inputs.viewState
            .map { $0.loginViewStatus == .enteringCredentials }
        
        validatingCredentials = inputs.viewState
            .map { $0.loginViewStatus == .validatingCredentials }
            .asDriverLogError()
        
        loginEnabled = Observable.combineLatest(isViewStateEnteringCredentials, isCredentialsEntered)
            .map(bothTrue)
            .startWith(false)
            .asDriverLogError()
        
        loginTapDisposable = inputs.loginTap
            .withLatestFrom(usernameAndPassword)
            .do(onNext: { _ in 
                loginView(.startValidatingCredentials)
            })
            .flatMap(Dependencies.loginValidator)
            .subscribe(onNext: processLoginResult)
        
        loginView(.allowInput)
    }
}

fileprivate func bothStringsNotEmpty(first: String, second: String) -> Bool {
    return bothTrue(first: !first.isEmpty, second: !second.isEmpty)
}

fileprivate func bothTrue(first: Bool, second: Bool) -> Bool {
    return first && second
}

fileprivate func processLoginResult(_ loginResult: LoginResult) {
    switch loginResult {
    case .success(let username, let jwt):
        logUserIn(username: username, jwt: jwt)
        appRouter(.displayHomeScreen)
    case .failure:
        appRouter(.alert(title: "Failed Login", message: "Verify that username and password are correct", completion: {
            appRouter(.displayLoginScreen)
        }))
    }
}
