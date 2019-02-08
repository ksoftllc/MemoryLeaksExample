//
//  LoginService.swift
//
//  Created by Chuck Krutsinger on 2/4/19.
//  Copyright © 2019 Countermind, LLC. All rights reserved.
//

import Foundation
import RxSwift

enum LoginError: Error {
    case invalidCredentials
}

enum LoginResult {
    case success(username: Username, jwt: JWT), failure(error: LoginError)
}

typealias JWT = String //just for demo
typealias Username = String
typealias Password = String

func mockLoginValidatorService(username: String, password: String) -> Observable<LoginResult> {

    return Observable<LoginResult>.create { observer in
        //dispatch to simulate web service
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { //pause for 1 second as if going to web
            //simulates invalid username by using "bogus" as username
            guard username != "bogus" else {
                observer.on(.next(LoginResult.failure(error: LoginError.invalidCredentials)))
                observer.on(.completed)
                return
            }
            
            //simulates login failure by using "bogus" as password
            guard password != "bogus" else {
                observer.on(.next(LoginResult.failure(error: LoginError.invalidCredentials)))
                observer.on(.completed)
                return
            }
            
            //accept any username/password combo that gets past the guard statements
            observer.on(.next(LoginResult.success(username: username, jwt: "SOMEJWTSTRINGWOULDGOHERE")))
            observer.on(.completed)
        }
        
        return Disposables.create()
    }
}
