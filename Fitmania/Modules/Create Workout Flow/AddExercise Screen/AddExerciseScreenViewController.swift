//
//  AddExerciseScreenViewController.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class AddExerciseScreenViewController: BaseViewController, AddExerciseScreenView {
    typealias ViewState = AddExerciseScreenViewState
    typealias Effect = AddExerciseScreenEffect
    typealias Intent = AddExerciseScreenIntent
    
    @IntentSubject() var intents: Observable<AddExerciseScreenIntent>
    
    private let effectsSubject = PublishSubject<Effect>()
    private let bag = DisposeBag()
    private let presenter: AddExerciseScreenPresenter
    
    private lazy var addExerciseButton = UIBarButtonItem.init().apply(style: .rightStringButtonItemWhite, imageName: nil, title: Localization.General.add)
    private lazy var exerciseDetailsView = ExerciseDetailsView()
    
    init(presenter: AddExerciseScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutView()
        bindControls()
        effectsSubject.subscribe(onNext: { [weak self] effect in self?.trigger(effect: effect) })
            .disposed(by: bag)
        presenter.bindIntents(view: self, triggerEffect: effectsSubject)
            .subscribe(onNext: { [weak self] state in self?.render(state: state) })
            .disposed(by: bag)
    }
    
    private func layoutView() {
        self.navigationItem.rightBarButtonItem = addExerciseButton
        view.backgroundColor = .primaryColor
        
        view.addSubview(exerciseDetailsView)
        
        exerciseDetailsView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(64)
            $0.height.equalTo(120)
            $0.left.right.equalToSuperview().inset(15)
        }
    }
    
    private func bindControls() {
        let addExerciseButtonIntent = addExerciseButton?.tap.map { [weak self] _ -> Intent in
            guard let exerciseTime = self?.exerciseDetailsView.timeTextField.text, let exerciseBreakTime = self?.exerciseDetailsView.breakTimeTextField.text, let setsNumber = self?.exerciseDetailsView.setsTextfield.text else { return Intent.invalidDataSet }
            return Intent.addExerciseIntent(sets: setsNumber, time: exerciseTime, breakTime: exerciseBreakTime)
        }
        
        let exerciseTimeValidationIntent = exerciseDetailsView.timeTextField.rx.text.orEmpty.asObservable().map { Intent.validateExerciseTime(text: $0) }
        let exerciseSetsValidationIntent = exerciseDetailsView.setsTextfield.rx.text.orEmpty.asObservable().map { Intent.validateSets(text: $0) }
        let exerciseBreakTimeValidationIntent = exerciseDetailsView.breakTimeTextField.rx.text.orEmpty.asObservable().map { Intent.validateExerciseBreakTime(text: $0) }
        
        guard let addExerciseButtonIntent else { return }
        Observable.merge(addExerciseButtonIntent, exerciseTimeValidationIntent, exerciseBreakTimeValidationIntent, exerciseSetsValidationIntent)
            .bind(to: _intents.subject)
            .disposed(by: bag)
    }
    
    private func trigger(effect: Effect) {
        switch effect {
        default:
            break
        }
    }
    
    func render(state: ViewState) {
        title = state.chosenExercise.name
        exerciseDetailsView.setupView(category: state.chosenExercise.category)
        addExerciseButton?.isEnabled = state.isAddButtonEnabled
    }
}
