//
//  FeedViewController.swift
//  SeamlessSwitching
//
//  Created by JT3 on 2021/05/25.
//

import UIKit

class FeedViewController: UIViewController {
    
    //private var collectionView: UICollectionView?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = UIScreen.main.bounds.size
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.identifier)
        view.isPagingEnabled = true
        view.dataSource = self
        view.delegate = self
        view.prefetchDataSource = self
        view.contentInsetAdjustmentBehavior = .never
        
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        var image: UIImage?

        if #available(iOS 13, *) {
            image = UIImage(systemName: "xmark")
        } else {
            image = UIImage(named: "xmark")
        }

        button.frame = CGRect(x: view.frame.width - 100, y: 10, width: 52, height: 52)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .black.withAlphaComponent(0.3)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.clipsToBounds = true
        button.addTarget(target, action: #selector(closeButtonTapped), for: .touchUpInside)

        return button
    } ()
    
    private var currentIndex = -1
    private var scrollTo = -1
    private var viewModel: FeedVideoViewModel
        
    func setupViews() {
        view.addSubview(collectionView)
        view.addSubview(closeButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    init(viewModel: FeedVideoViewModel, startIndex: Array<FeedDataInfo>.Index) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        if viewModel.cellModels.indices.contains(startIndex) {
            self.currentIndex = startIndex
            viewModel.cellModel(for: IndexPath(row: startIndex, section: 0)).load()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc internal func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
                
        collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0),
                                    at: .centeredHorizontally, animated: false)
    }
    
    func playVideo(indexPath: IndexPath) {
        if let displayCell = collectionView.cellForItem(at: indexPath) as? VideoCollectionViewCell {
            currentIndex = indexPath.row
            displayCell.player?.play()
        }
    }
}

extension FeedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cellCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.identifier, for: indexPath) as! VideoCollectionViewCell
        
        cell.configure(with: viewModel.cellModel(for: indexPath))
        
        NSLog("Cell for \(indexPath) requested.")
        if currentIndex == indexPath.row {
            NSLog("cellForItemAt: Start playing: \(currentIndex)")
            cell.player?.play()
        }
        return cell
    }
}

extension FeedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        NSLog("willDisplay \(indexPath.row), CurrentIndex: \(currentIndex)")
        
        playVideo(indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        NSLog("didEndDisplaying \(indexPath.row), CurrentIndex: \(currentIndex), newIndex: \(scrollTo)")
        if let cell = cell as? VideoCollectionViewCell {
            cell.player?.pause()
            cell.player?.seek(to: .zero)
        }
        
        playVideo(indexPath: IndexPath(row: scrollTo, section: 0))
    }
    
    // JT: scrollViewWillEndDragging is not called when scrolling very fast.
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let newIndex = Int(round(targetContentOffset.pointee.x / UIScreen.main.bounds.size.width))
        NSLog("scrollViewWillEndDragging CurrentIndex: \(currentIndex), newIndex: \(newIndex)")
        //checkStartPlay(collectionView: collectionView!, newIndex: newIndex)
        
        playVideo(indexPath: IndexPath(row: newIndex, section: 0))
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollTo = Int(round(scrollView.contentOffset.x / UIScreen.main.bounds.size.width))
    }
}

extension FeedViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        NSLog("prefetchItemsAt \(indexPaths)")
        for indexPath in indexPaths {
            viewModel.cellModel(for: indexPath).load()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        NSLog("cancelPrefetchingForItemsAt \(indexPaths)")
    }
}
