//
//  LoginState.swift
//
//  Created by Chuck Krutsinger on 2/5/19.
//  Copyright © 2019 Countermind, LLC. All rights reserved.
//

import ReSwift



struct LoginState: StateType {
    
    enum LoginStatus {
        case loggedOut, loggedIn(username: Username, jwt: String)
        
        ///Returns username if logged in
        var username: Username? {
            switch self {
            
            case .loggedOut:
                return nil
            case .loggedIn(let username, _):
                return username
            }
        }
    }
    
    var loginStatus: LoginStatus
    
    init(loginStatus: LoginStatus = .loggedOut) {
        self.loginStatus = loginStatus
    }
}

func loginReducer(action: Action, state: LoginState?) -> LoginState {
    
    var state = state ?? LoginState()

    if let loginAction = action as? AppAction {
        switch loginAction {
            
        case .logUserIn(let username, let jwt):
            state.loginStatus = .loggedIn(username: username, jwt: jwt)
        case .logUserOut:
            state.loginStatus = .loggedOut
        }
    }

    return state
}

//convenience functions
func logUserOut() {
    Dependencies.app(.logUserOut)
}

func logUserIn(username: Username, jwt: JWT) {
    Dependencies.app(.logUserIn(username: username, jwt: jwt))
}
