//
//  FeedUIController.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/05/26.
//

import UIKit

class FeedUIController: UIViewController {
    static let backgroundColor = UIColor(red: CGFloat(31.0/255),
                                                 green: CGFloat(33.0/255),
                                                 blue: CGFloat(38.0/255.0),
                                                 alpha: 1)
        
    private var layoutConstraints: [NSLayoutConstraint] = .init()
    
    private var viewModel: FeedUIViewModel
    public var onDismiss: (() -> Void)?
    
    init(viewModel: FeedUIViewModel, onDismiss: (() -> Void)?) {
        self.viewModel = viewModel
        self.onDismiss = onDismiss
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var headerView: FeedUIHeaderStackView = {
        let view = FeedUIHeaderStackView(viewModel: viewModel.headerViewModel, delegate: self)
        view.translatesAutoresizingMaskIntoConstraints = false        
        return view
    } ()
    
    private lazy var feedCollectionView: FeedUIImageCollectionView = {
        let view = FeedUIImageCollectionView(viewModel: viewModel.imageViewModel, delegate: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func setupViews() {
        view.addSubview(headerView)
        view.addSubview(feedCollectionView)
        view.backgroundColor = FeedUIController.backgroundColor
        
        let safeLayoutGuide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 52),
            feedCollectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            feedCollectionView.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
            feedCollectionView.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
            feedCollectionView.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor),
        ])
    }
    
    func setupBinder() {
        viewModel.$loadImageViewIfNeeded.bind = { [weak self] _ in
            guard let self = self else { return }
            self.feedCollectionView.reload(with: self.viewModel.imageViewModel)
        }
        
        viewModel.$updateImageViewIfNeeded.bind = { [weak self] _ in
            guard let self = self else { return }
            self.feedCollectionView.update(with: self.viewModel.imageViewModel)
        }
        
        viewModel.$headerViewModel.bind = { [weak self] headerViewModel in
            self?.headerView.update(with: headerViewModel)
        }
        
        viewModel.headerViewModel.$selectedCategory.bind = { [weak self] _ in
            guard let self = self else { return }
            self.feedCollectionView.setContentOffsetToZero()
            self.feedCollectionView.reload(with: self.viewModel.imageViewModel)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupViews()
        setupBinder()
    }
}

extension FeedUIController: FeedUIHeaderStackViewDelegate {
    func initialSelectedIndex() -> Int {
        0
    }
    
    func select(category: String) -> Void {
        viewModel.updateImageViewModel(byFiltering: category)
    }
    
    func search(with text: String) -> Void {
        viewModel.updateImageViewModel(with: text)
    }
    
    func closeButtonTapped() {
        onDismiss?()
    }
}

extension FeedUIController: FeedInfoDelegate {
    func pullUpToRefresh() {
        viewModel.fetchFeedSources()
    }
    
    func select(at index: Int) -> Void {
        
        let controller = FeedViewController(viewModel: viewModel.videoViewModel, startIndex: index)        
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
}
