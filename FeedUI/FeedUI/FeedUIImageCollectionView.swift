//
//  FeedUIImageCollectionView.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/05/24.
//

import UIKit

class FeedUIImageCollectionView: UIView {
    public weak var feedInfoDelegate: FeedInfoDelegate?
        
    private var viewModel: FeedImageViewModel
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: PinterestLayout())
        view.register(FeedUIImageCell.self, forCellWithReuseIdentifier: FeedUIImageCell.reuseIdentifier)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = FeedUIController.backgroundColor
        
        return view
    }()
    
    init(viewModel: FeedImageViewModel, delegate: FeedInfoDelegate?) {
        self.viewModel = viewModel
        self.feedInfoDelegate = delegate
        
        super.init(frame: .zero)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.alwaysBounceVertical = true
        if let layout = collectionView.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
        
        addSubview(collectionView)
        
        setupRefreshControl()
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        refreshControl.triggerVerticalOffset = 20
        refreshControl.addTarget(self, action: #selector(paginateMore), for: .valueChanged)
        refreshControl.tintColor = .systemPink
        self.collectionView.bottomRefreshControl = refreshControl
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),            
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    @objc func paginateMore() {
        feedInfoDelegate?.pullUpToRefresh()
    }
    
    func setContentOffsetToZero() {
        collectionView.setContentOffset(.zero, animated: false)
    }
    
    func reload(with viewModel: FeedImageViewModel) {
        self.viewModel = viewModel
        collectionView.reloadData()
    }
    
    func update(with updatedViewModel: FeedImageViewModel?) {
        if let updatedViewModel = updatedViewModel {
            let lastInArray = viewModel.cellModels.count
            
            let newCells = updatedViewModel.cellModels.filter { newCell in
                !viewModel.cellModels.contains(where: { originCell in
                    originCell.url == newCell.url
                })
            }
            
            self.viewModel.cellModels.append(contentsOf: newCells)
            let newLastInArray = viewModel.cellModels.count
            
            let indexPaths = Array(lastInArray..<newLastInArray).map{IndexPath(item: $0, section: 0)}
            
            self.collectionView.insertItems(at: indexPaths)
            self.collectionView.bottomRefreshControl?.adjustBottomInset = true
        } else {
            self.collectionView.bottomRefreshControl?.adjustBottomInset = false
        }        
         
        self.collectionView.bottomRefreshControl?.endRefreshing()        
    }
}

protocol FeedInfoDelegate: AnyObject {
    func select(at index: Int) -> Void
    func pullUpToRefresh() -> Void
}

extension FeedUIImageCollectionView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cellCount
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        feedInfoDelegate?.select(at: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedUIImageCell.reuseIdentifier, for: indexPath)
        if viewModel.cellCount > indexPath.item, let feedCell = cell as? FeedUIImageCell {
            let cellModel = viewModel.cellModel(for: indexPath)
            feedCell.configure(with: cellModel)
        }
        
        return cell
    }
}

extension FeedUIImageCollectionView: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return viewModel.cellModel(for: indexPath).height
    }
}
