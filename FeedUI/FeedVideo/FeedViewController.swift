//
//  FeedViewController.swift
//  SeamlessSwitching
//
//  Created by JT3 on 2021/05/25.
//

import UIKit

class FeedViewController: UIViewController {
    
    private var collectionView: UICollectionView?
    private var currentIndex = -1
    private var scrollTo = -1
    private var dataSource: VideoDataSource!
    
    let closeButton: UIButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = UIScreen.main.bounds.size//CGSize(width: view.frame.size.width, height: view.frame.size.height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.identifier)
        collectionView?.isPagingEnabled = true
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.prefetchDataSource = self
        collectionView?.contentInsetAdjustmentBehavior = .never
        
        view.addSubview(collectionView!)
                
        var image: UIImage?
        
        if #available(iOS 13, *) {
            image = UIImage(systemName: "xmark")
        } else {
            image = UIImage(named: "xmark")
        }
        
        closeButton.frame = CGRect(x: view.frame.width - 100, y: 10, width: 52, height: 52)
        closeButton.setImage(image, for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = .black.withAlphaComponent(0.3)
        closeButton.layer.cornerRadius = 0.5 * closeButton.bounds.size.width
        closeButton.clipsToBounds = true
        closeButton.addTarget(target, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        view.addSubview(closeButton)
    }
    
    @objc internal func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    func setDataSource(sources: VideoDataSource) {
        self.dataSource = sources
    }
    
    private func checkStartPlay(collectionView: UICollectionView, newIndex: Int) {
        if newIndex >= 0 && currentIndex != newIndex {
            for cell in collectionView.visibleCells {
                if let cell = cell as? VideoCollectionViewCell {
                    NSLog("checkStartPlay: Visible cells: \(cell.index), currentIndex: \(currentIndex), newIndex: \(newIndex)")
                    if cell.index == newIndex {
                        NSLog("checkStartPlay: Start playing: \(newIndex)")
                        currentIndex = newIndex // Update currentIndex only when the current cell is included in the visibleCells.
                        cell.player?.play()
                    }
                }
            }
        }
    }
}

extension FeedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.dataCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.identifier, for: indexPath) as! VideoCollectionViewCell
        cell.configure(with: dataSource, index: indexPath.row)
        NSLog("Cell for \(indexPath) requested.")
        if currentIndex == -1 {
            currentIndex = indexPath.row
            NSLog("cellForItemAt: Start playing: \(currentIndex)")
            cell.player?.play()
        }
        return cell
    }
}

extension FeedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let newIndex = indexPath.row
        NSLog("willDisplay \(indexPath.row), CurrentIndex: \(currentIndex), newIndex: \(newIndex)")
        
        checkStartPlay(collectionView: collectionView, newIndex: newIndex)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        NSLog("didEndDisplaying \(indexPath.row), CurrentIndex: \(currentIndex), newIndex: \(scrollTo)")
        if let cell = cell as? VideoCollectionViewCell {
            cell.player?.pause()
            cell.player?.seek(to: .zero)
        }

        checkStartPlay(collectionView: collectionView, newIndex: scrollTo)
    }
    
    // JT: scrollViewWillEndDragging is not called when scrolling very fast.
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let newIndex = Int(round(targetContentOffset.pointee.x / UIScreen.main.bounds.size.width))
        NSLog("scrollViewWillEndDragging CurrentIndex: \(currentIndex), newIndex: \(newIndex)")
        checkStartPlay(collectionView: collectionView!, newIndex: newIndex)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollTo = Int(round(scrollView.contentOffset.x / UIScreen.main.bounds.size.width))
//        NSLog("scrollViewDidScroll: \(scrollTo), \(scrollView.contentOffset)")
    }
}

extension FeedViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        NSLog("prefetchItemsAt \(indexPaths)")
        for indexPath in indexPaths {
            dataSource.prepareSource(for: indexPath.row)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        NSLog("cancelPrefetchingForItemsAt \(indexPaths)")
    }
}
