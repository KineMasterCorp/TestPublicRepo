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
    
    private lazy var titleView: UILabel = {
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 52))
        title.textColor = .white
        title.textAlignment = .center
        title.text = "#" + viewModel.fetchRequest.target
        title.font = UIFont.systemFont(ofSize: 17)
        return title
    } ()
    
    func setupViews() {
        view.addSubview(imageCollectionView)
        view.backgroundColor = FeedUI.backgroundColor
        
        let safeLayoutGuide = view.safeAreaLayoutGuide
        var collectionViewTopAnchor = safeLayoutGuide.topAnchor
        
        if viewModel.fetchRequest.type == .category {
            view.addSubview(headerView)
            
            layoutConstraints.append(
                contentsOf: [headerView.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor),
                             headerView.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
                             headerView.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
                             headerView.heightAnchor.constraint(equalToConstant: 52)])
            
            collectionViewTopAnchor = headerView.bottomAnchor
        }
        
        layoutConstraints.append(
            contentsOf: [imageCollectionView.topAnchor.constraint(equalTo: collectionViewTopAnchor),
                         imageCollectionView.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
                         imageCollectionView.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
                         imageCollectionView.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor)])
        
        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    func setupNavigationBar() {
        navigationItem.titleView = titleView
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.topItem?.title = ""
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
        setupNavigationBar()
        
        if viewModel.fetchRequest.type == .tag {
            viewModel.fetch(with: viewModel.fetchRequest)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if viewModel.fetchRequest.type == .category {
            navigationController?.isNavigationBarHidden = true
        }
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
        guard viewModel.sources.indices.contains(index) else {
            print("FeedInfoDelegate.select: invalid index! \(index). video count: \(viewModel.sources.count)")
            return
        }
        
        let controller = FeedViewController(videoManager: VideoCollectionViewModel(sources: viewModel.sources, start: index, videoCache: videoCache))
        
        let interactor = FeedInteractorImpl(presenter: FeedPresenter(view: controller),
                                            navigator: FeedNavigatorImpl(viewController: controller))
        controller.interactor = interactor
                
        navigationController?.pushViewController(controller, animated: true)
    }
}
