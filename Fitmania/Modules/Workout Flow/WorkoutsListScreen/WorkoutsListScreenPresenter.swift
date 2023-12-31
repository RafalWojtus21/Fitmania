//
//  WorkoutsListScreenPresenter.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 20/04/2023.
//

import RxSwift

final class WorkoutsListScreenPresenterImpl: WorkoutsListScreenPresenter {
    typealias View = WorkoutsListScreenView
    typealias ViewState = WorkoutsListScreenViewState
    typealias Middleware = WorkoutsListScreenMiddleware
    typealias Interactor = WorkoutsListScreenInteractor
    typealias Effect = WorkoutsListScreenEffect
    typealias Result = WorkoutsListScreenResult
    
    private let interactor: Interactor
    private let middleware: Middleware
    
    private let initialViewState: ViewState
    
    init(interactor: Interactor, middleware: Middleware, initialViewState: ViewState) {
        self.interactor = interactor
        self.middleware = middleware
        self.initialViewState = initialViewState
    }
    
    func bindIntents(view: View, triggerEffect: PublishSubject<Effect>) -> Observable<ViewState> {
        let intentResults = view.intents.flatMap { [unowned self] intent -> Observable<Result> in
            switch intent {
            case .plusButtonIntent:
                return .just(.effect(.nameCustomWorkoutAlert))
            case .createNewTraining(name: let name):
                return .just(.effect(.showNewTrainingPlanScreen(name: name)))
            case .loadTrainingPlans:
                return interactor.loadTrainingPlans()
            case .deleteWorkoutPlan(id: let id):
                return interactor.deleteTrainingPlan(id: id)
            case .workoutSelected(plan: let plan):
                return .just(.effect(.showScheduleWorkoutScreen(plan: plan)))
            }
        }
        return Observable.merge(middleware.middlewareObservable, intentResults)
            .flatMap { self.middleware.process(result: $0) }
            .scan(initialViewState, accumulator: { previousState, result -> ViewState in
                switch result {
                case .partialState(let partialState):
                    return partialState.reduce(previousState: previousState)
                case .effect(let effect):
                    triggerEffect.onNext(effect)
                    return previousState
                }
            })
            .startWith(initialViewState)
            .distinctUntilChanged()
    }
}
