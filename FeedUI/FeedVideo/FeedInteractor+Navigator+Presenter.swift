//
//  FeedInteractor+Navigator+Presenter.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/08/10.
//

import Foundation

public protocol FeedInteractor: AnyObject {
    func dispatch(_ action: Feed.Action)
}

class FeedInteractorImpl: FeedInteractor {
    let navigator: FeedNavigator
    private let presenter: FeedPresenter
    
    init(presenter: FeedPresenter, navigator: FeedNavigator) {
        self.presenter = presenter
        self.navigator = navigator
        
        self.navigator.onEvent = { [weak self] event in
            self?.handleSceneEvent(event)
        }
    }
    
    func dispatch(_ action: Feed.Action) {
        presenter.present(action: action)
        
        switch action {
        case .touchTag(let tag, let wordType):
            navigator.present(.projectFeed(tag: tag, wordType: wordType))
        case .dismissModal:
            navigator.dismiss()
        case .viewWillAppear:
            break
        case .viewDidAppear:
            break
        case .viewDidDisappear:
            break
        }
    }
    
    private func handleSceneEvent(_ event: Feed.SceneEvent) {
        switch event {
        case .didDismissProjectFeed:
            self.dispatch(.dismissModal)
        }
    }
}

class FeedPresenter: NSObject {
    weak var view: FeedViewController?
    private var viewState: Feed.ViewState = .init()
    
    init(view: FeedViewController) {
        self.view = view
        super.init()
    }
    
    public func present(action: Feed.Action) {
        switch action {
        case .touchTag:
            viewState.play = false
        case .dismissModal:
            break
        case .viewWillAppear:
            viewState.play = true
        case .viewDidAppear:
            break
        case .viewDidDisappear:
            break
        }
        
        view?.update(with: viewState)
    }
}

enum FeedNavigatorDestination {
    case projectFeed(tag: String, wordType: wordType)
}

protocol FeedNavigator: AnyObject {
    func present(_ destination: FeedNavigatorDestination)
    func dismiss()
    
    typealias OnEvent = (Feed.SceneEvent) -> Void
    var onEvent: OnEvent? { get set }
}

public struct Feed {
    public enum Action {
        case viewWillAppear
        case viewDidAppear
        case viewDidDisappear
        
        case touchTag(tag: String, wordType: wordType)
        case dismissModal
    }
    
    public struct ViewState {
        public var play: Bool
        
        init(play: Bool = true) {
            self.play = play
        }
    }
    
    enum SceneEvent {
        case didDismissProjectFeed
    }
}

public class FeedNavigatorImpl: FeedNavigator {
    var onEvent: OnEvent?
    
    weak private(set) var viewController: FeedViewController?
    
    init(viewController: FeedViewController) {
        self.viewController = viewController
    }
    
    func present(_ destination: FeedNavigatorDestination) {
        switch destination {
        case .projectFeed(let tag, let wordType):
            presentProjectFeed(tag: tag, wordType: wordType)
        }
    }
    
    func dismiss() {
        viewController?.dismiss(animated: true)
    }
    
    func presentProjectFeed(tag: String, wordType: wordType) {
        if let controller = viewController {
            let modalView = FeedUIController(viewModel: FeedUIViewModel(fetchRequest: FeedDataRequest(target: tag, type: .tag)), onDismiss: { self.onEvent?(.didDismissProjectFeed) }
            )
            
            modalView.modalPresentationStyle = .fullScreen            
            controller.navigationController?.pushViewController(modalView, animated: true)
        }
    }
}

