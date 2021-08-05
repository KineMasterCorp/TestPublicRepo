//
//  FeedViewController.swift
//  SeamlessSwitching
//
//  Created by JT3 on 2021/05/25.
//

import UIKit

class FeedViewController: UIViewController {

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
    
    private var videoManager: VideoCollectionViewModel
    
    init(videoManager: VideoCollectionViewModel) {
        self.videoManager = videoManager
        currentIndex = videoManager.currentVideo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func setupViews() {
        view.addSubview(collectionView)
        view.addSubview(closeButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
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
        if let _ = collectionView.cellForItem(at: indexPath) as? VideoCollectionViewCell {
            currentIndex = indexPath.row
            videoManager.setCurrentVideo(currentIndex)
        }
    }
}

extension FeedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoManager.videoCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        NSLog("Cell for \(indexPath) requested.")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.identifier, for: indexPath) as! VideoCollectionViewCell

        cell.configure(with: videoManager, index: indexPath.row)
        
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
        
        playVideo(indexPath: IndexPath(row: scrollTo, section: 0))
    }
    
    // JT: scrollViewWillEndDragging is not called when scrolling very fast.
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let newIndex = Int(round(targetContentOffset.pointee.x / UIScreen.main.bounds.size.width))
        NSLog("scrollViewWillEndDragging CurrentIndex: \(currentIndex), newIndex: \(newIndex)")
       
        playVideo(indexPath: IndexPath(row: newIndex, section: 0))
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollTo = Int(round(scrollView.contentOffset.x / UIScreen.main.bounds.size.width))
    }
}
