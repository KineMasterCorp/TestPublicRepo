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
        let view = FeedUIHeaderStackView(items: viewModel.getTags(), delegate: self)
        view.translatesAutoresizingMaskIntoConstraints = false        
        return view
    } ()
    
    private lazy var feedCollectionView: FeedUIImageCollectionView = {
        let view = FeedUIImageCollectionView(viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.feedInfoDelegate = self
        return view
    }()
    
    private var viewDidAppearOnce: Bool = false
    
    func setupHeaderViews() {
        view.addSubview(headerView)
        
        let safeLayoutGuide = view.safeAreaLayoutGuide
        
        layoutConstraints.append(
            contentsOf: [
                headerView.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor),
                headerView.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
                headerView.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
                headerView.heightAnchor.constraint(equalToConstant: 52),
                ]
        )
    }
    
    func setupFeedView() {
        view.addSubview(feedCollectionView)
        
        let safeLayoutGuide = view.safeAreaLayoutGuide

        layoutConstraints.append(
            contentsOf: [
                feedCollectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
                feedCollectionView.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
                feedCollectionView.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
                feedCollectionView.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor),
                ]
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = FeedUIController.backgroundColor
                
        setupHeaderViews()
        setupFeedView()
        
        NSLayoutConstraint.activate(layoutConstraints)
        
        self.viewModel.changedTag = { [weak self] in
            self?.feedCollectionView.setContentOffsetToZero()
        }
        
        self.viewModel.reloadedSources = { [weak self] in
            self?.feedCollectionView.reloadData()
        }
        
        self.viewModel.fetchedSources = { [weak self] in
            guard let self = self else { return }
            self.headerView.update(with: (self.viewModel.getTags()))
            self.feedCollectionView.update()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !viewDidAppearOnce { // workaround
            headerView.selectItem(at: 0)            
            viewDidAppearOnce = true
        }
    }
}

extension FeedUIController: FeedUIHeaderStackViewDelegate {
    func select(tag: String) -> Void {
        viewModel.filter(by: tag)        
    }
    
    func search(with text: String) -> Void {
        viewModel.filter(with: text)
    }
    
    func closeButtonTapped() {
        onDismiss?()
    }
}

extension FeedUIController: FeedInfoDelegate {
    func select(at index: Int) -> Void {
        let controller = FeedViewController()        
        controller.setDataSource(sources: viewModel.filteredSources, startIndex: index)
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
}
