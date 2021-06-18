//
//  FeedUIImageCollectionView.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/05/24.
//

import UIKit

class FeedUIImageCollectionView: UIView {
    public weak var feedInfoDelegate: FeedInfoDelegate?
    
    private var viewModel: FeedUIViewModel?
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: PinterestLayout())
        view.register(FeedUIImageCell.self, forCellWithReuseIdentifier: FeedUIImageCell.reuseIdentifier)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = FeedUIController.backgroundColor
        
        return view
    }()
    
    init(viewModel: FeedUIViewModel) {
        super.init(frame: .zero)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.alwaysBounceVertical = true
                
        addSubview(collectionView)
        
        if let layout = collectionView.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
        
        let refreshControl = UIRefreshControl.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        refreshControl.triggerVerticalOffset = 50
        refreshControl.addTarget(self, action: #selector(paginateMore), for: .valueChanged)
        refreshControl.tintColor = .systemPink
        self.collectionView.bottomRefreshControl = refreshControl
        
        self.viewModel = viewModel        
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
        print("paginateMore")
        viewModel?.fetch() { [weak collectionView] in
            collectionView?.bottomRefreshControl?.endRefreshing()
        }
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    func update() {
        let lastInArray = collectionView.numberOfItems(inSection: 0)
        let newLastInArray = viewModel?.dataCount ?? lastInArray
        let indexPaths = Array(lastInArray..<newLastInArray).map{IndexPath(item: $0, section: 0)}
        collectionView.insertItems(at: indexPaths)
    }
    
    func setContentOffsetToZero() {
        collectionView.setContentOffset(.zero, animated: false)
    }
}

protocol FeedInfoDelegate: AnyObject {
    func select(at index: Int) -> Void
}

extension FeedUIImageCollectionView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.dataCount ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        feedInfoDelegate?.select(at: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedUIImageCell.reuseIdentifier, for: indexPath)
        if let feedCell = cell as? FeedUIImageCell {
            let dataInfo = viewModel?.getDataInfo(of: indexPath.item)
            feedCell.item = dataInfo?.imageItem
            feedCell.captionLabel.text = dataInfo?.title
            
            ImageCache.publicCache.load(url: feedCell.item!.url as NSURL, item: feedCell.item!) { (fetchedItem, image) in
                if let img = image, img != fetchedItem.image {
                    feedCell.imageView.image = image
                } else {
                    print("image load failed")
                }
            }
        }
        return cell
    }
}

extension FeedUIImageCollectionView: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        if let dataInfo = viewModel?.getDataInfo(of: indexPath.item) {
            if nil == dataInfo.imageItem.height {
                dataInfo.imageItem.height = CGFloat.random(in: 150...300)
            }
            
            return dataInfo.imageItem.height!
        }
        
        return 0
    }
}
