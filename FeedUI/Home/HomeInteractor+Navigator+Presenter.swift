//
//  HomeInteractor+Navigator+Presenter.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/06/15.
//

import Foundation

public protocol HomeInteractor: AnyObject {
    func dispatch(_ action: Home.Action)
}

class HomeInteractorImpl: HomeInteractor {
    let navigator: HomeNavigator
    private let presenter: HomePresenter
    
    init(presenter: HomePresenter, navigator: HomeNavigator) {
        self.presenter = presenter
        self.navigator = navigator
        
        self.navigator.onEvent = { [weak self] event in
            self?.handleSceneEvent(event)
        }
    }
    
    func dispatch(_ action: Home.Action) {
        presenter.present(action: action)
        
        switch action {
        case .feed:
            navigator.present(.projectFeed)
        case .dismissModal:
            navigator.dismiss()
        }
    }
    
    private func handleSceneEvent(_ event: Home.SceneEvent) {
        switch event {
        case .didDismissProjectFeed:
            self.dispatch(.dismissModal)
        }
    }
}

class HomePresenter: NSObject {
    weak var view: HomeViewController?
    private var viewState: Home.ViewState = .init()
        
    init(view: HomeViewController) {
        self.view = view
        super.init()
    }
    
    public func present(action: Home.Action) {
        switch action {
        case .feed:
            viewState.animateBackground = false
        case .dismissModal:
            viewState.animateBackground = true
        }
        
        view?.update(with: viewState)
    }
}

enum HomeNavigatorDestination {
    case projectFeed
}

protocol HomeNavigator: AnyObject {
    func present(_ destination: HomeNavigatorDestination)
    func dismiss()
    
    typealias OnEvent = (Home.SceneEvent) -> Void
    var onEvent: OnEvent? { get set }
}

public struct Home {
    public enum Action {
        case feed
        case dismissModal
    }
    
    public struct ViewState {
        public var animateBackground: Bool
        
        init(animateBackground: Bool = true) {
            self.animateBackground = animateBackground
        }
    }
    
    enum SceneEvent {
        case didDismissProjectFeed
    }
}

public class HomeNavigatorImpl: HomeNavigator {
    var onEvent: OnEvent?
    
    weak private(set) var viewController: HomeViewController?
    
    init(viewController: HomeViewController) {
        self.viewController = viewController
    }
    
    func present(_ destination: HomeNavigatorDestination) {
        switch destination {
        case .projectFeed:
            presentProjectFeed()
        }
    }
    
    func dismiss() {
        viewController?.dismiss(animated: true)
    }
    
    func presentProjectFeed() {
        if let controller = viewController {
            let modalView = FeedUIController(viewModel: FeedUIViewModel(), onDismiss: {
                self.onEvent?(.didDismissProjectFeed)
            })
            
            modalView.modalPresentationStyle = .fullScreen
            controller.present(modalView, animated: true)            
        }
    }
}
