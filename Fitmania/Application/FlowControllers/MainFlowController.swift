//
//  MainFlowController.swift
//  AcademyMVI
//
//  Created by Bart on 15/11/2021.
//

import Foundation

protocol HasAppNavigation {
    var appNavigation: AppNavigation? { get }
}

protocol AppNavigation: AnyObject {
    func startApplication()
    func showWelcomeScreen()
    func showLoginScreen()
    func showRegisterScreen()
}

final class MainFlowController: AppNavigation {
    typealias Dependencies = HasNavigation
    
    struct ExtendedDependencies: Dependencies, HasAppNavigation {
        private let dependencies: Dependencies
        weak var appNavigation: AppNavigation?
        var navigation: Navigation { dependencies.navigation }
        
        init(dependencies: Dependencies, appNavigation: AppNavigation) {
            self.dependencies = dependencies
            self.appNavigation = appNavigation
        }
    }
    
    // MARK: - Properties
    
    private let dependencies: Dependencies
    private lazy var extendedDependencies = ExtendedDependencies(dependencies: dependencies, appNavigation: self)
    
    // MARK: - Builders
    
    private lazy var welcomeScreenBuilder: WelcomeScreenBuilder = WelcomeScreenBuilderImpl(dependencies: extendedDependencies)
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: - AppNavigation
    
    func startApplication() {
        showWelcomeScreen()
    }
    
    func showWelcomeScreen() {
        let view = welcomeScreenBuilder.build(with: .init()).view
        dependencies.navigation.set(view: view, animated: false)
    }
    
    func showLoginScreen() {
    }
    
    func showRegisterScreen() {
    }
}