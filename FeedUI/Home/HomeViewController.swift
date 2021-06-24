//
//  InitialViewController.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/05/28.
//

import UIKit

class HomeViewController: UIViewController {
    
//    private lazy var sequentialBackgroundView: SequentialBackgroundView = {
//        let view = SequentialBackgroundView(frame: view.frame)
//        return view
//    }()
    
    private lazy var feedButton: ActualGradientButton = {
        let button = ActualGradientButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "icFeed")
        button.setImage(image, for: .normal)
        button.addTarget(target, action: #selector(self.feedButtonTapped), for: .touchUpInside)
        button.setTitle("프로젝트 받기", for: .normal)
        return button
    } ()
    
    public var interactor: HomeInteractor?
    
    override func viewDidLoad() {
        setupSubviews()
    }
    
    private func setupSubviews() {
        //view.addSubview(sequentialBackgroundView)
        view.addSubview(feedButton)
        
        NSLayoutConstraint.activate([
            feedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            feedButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            feedButton.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    @objc private func feedButtonTapped() {
        interactor?.dispatch(.feed)
    }
    
    func update(with state: Home.ViewState) {
        //sequentialBackgroundView.setAnimatingState(state.animateBackground)
    }
}
