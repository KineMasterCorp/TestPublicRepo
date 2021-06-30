//
//  FeedUIController.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/05/26.
//

import UIKit

class FeedUIController: UIViewController {
    private var layoutConstraints: [NSLayoutConstraint] = .init()
    
    private var viewModel: FeedUIViewModel
    
    private var videoCache = VideoCache()
    
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
    
    private lazy var imageCollectionView: FeedUIImageCollectionView = {
        let view = FeedUIImageCollectionView(viewModel: viewModel.imageCollectionViewModel, delegate: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func setupViews() {
        view.addSubview(headerView)
        view.addSubview(imageCollectionView)
        view.backgroundColor = FeedUI.backgroundColor
        
        let safeLayoutGuide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 52),
            imageCollectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            imageCollectionView.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
            imageCollectionView.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
            imageCollectionView.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor),
        ])
    }
    
    func setupBinder() {
        viewModel.$loadImageViewIfNeeded.bind = { [weak self] _ in
            guard let self = self else { return }
            self.imageCollectionView.reload(with: self.viewModel.imageCollectionViewModel)
        }
        
        viewModel.$updateImageViewIfNeeded.bind = { [weak self] _ in
            guard let self = self else { return }
            self.imageCollectionView.update(with: self.viewModel.imageCollectionViewModel)
        }
        
        viewModel.$headerViewModel.bind = { [weak self] headerViewModel in
            self?.headerView.update(with: headerViewModel)
        }
        
        viewModel.headerViewModel.$selectedCategory.bind = { [weak self] _ in
            guard let self = self else { return }
            self.imageCollectionView.setContentOffsetToZero()
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
        viewModel.defaultInitialCategoryIndex
    }
    
    func select(category: String) -> Void {
        viewModel.fetch(with: FeedDataRequest(target: category, type: .category))
    }
    
    func search(with text: String) -> Void {
        viewModel.fetch(with: FeedDataRequest(target: text, type: .tag))
    }
    
    func closeButtonTapped() {
        onDismiss?()
    }
}

extension FeedUIController: FeedInfoDelegate {
    func pullUpToRefresh() {
        viewModel.fetchNext()
    }
    
    func select(at index: Int) -> Void {        
        let controller = FeedViewController(videoManager: VideoCollectionViewModel(sources: viewModel.sources, start: index, videoCache: videoCache))

        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
}
