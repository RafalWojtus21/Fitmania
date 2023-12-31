//
//  RegisterScreenMiddleware.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 06/04/2023.
//

import RxSwift

final class RegisterScreenMiddlewareImpl: RegisterScreenMiddleware, RegisterScreenCallback {
    typealias Dependencies = HasAuthenticationFlowNavigation
    typealias Result = RegisterScreenResult
    
    private let dependencies: Dependencies

    private let middlewareSubject = PublishSubject<Result>()
    var middlewareObservable: Observable<Result> { return middlewareSubject }
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func process(result: Result) -> Observable<Result> {
        switch result {
        case .partialState(_): break
        case .effect(let effect):
            switch effect {
            case .registerError:
                break
            case .showAccountSetupScreen:
                dependencies.authFlowNavigation?.showCreateAccountScreen()
            default:
                break
            }
        }
        return .just(result)
    }
}
