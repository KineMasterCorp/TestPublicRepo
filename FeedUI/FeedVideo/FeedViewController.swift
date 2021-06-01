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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    func setDataSource(sources: VideoDataSource) {
        self.dataSource = sources
    }
}

extension FeedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.dataCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.identifier, for: indexPath) as! VideoCollectionViewCell
        cell.configure(with: dataSource, index: indexPath.row, delegate: self)        
        NSLog("Cell for \(indexPath) requested.")
        if currentIndex == -1 {
            currentIndex = indexPath.row
            cell.player?.play()
        }
        return cell
    }
}

extension FeedViewController: CellDelegate {
    func close() {
        dismiss(animated: true)
    }
}

extension FeedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        NSLog("willDisplay \(indexPath)")
    }    
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        NSLog("didEndDisplaying \(indexPath), CurrentIndex: \(scrollTo)")
        if let cell = cell as? VideoCollectionViewCell {
            cell.player?.pause()
            cell.player?.seek(to: .zero)
        }
        
        if scrollTo >= 0 && currentIndex != scrollTo {
            currentIndex = scrollTo
            
            for cell in collectionView.visibleCells {
                if let cell = cell as? VideoCollectionViewCell {
                    NSLog("didEndDisplaying: Visible cells: \(cell.index)")
                    if cell.index == currentIndex {
                        NSLog("didEndDisplaying: Start playing: \(currentIndex)")
                        cell.player?.play()
                    }
                }
            }
        }
    }
    
    // JT: scrollViewWillEndDragging is not called when scrolling very fast.
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = Int(round(targetContentOffset.pointee.x / UIScreen.main.bounds.size.width))
        NSLog("scrollViewWillEndDragging index: \(currentIndex) -> \(index)")
        if currentIndex != index {
            if let visibleCells = collectionView?.visibleCells {
                for cell in visibleCells {
                    if let cell = cell as? VideoCollectionViewCell {
                        NSLog("scrollViewWillEndDragging Visible cells: \(cell.index)")
                        if cell.index == index {
                            NSLog("scrollViewWillEndDragging: Start playing: \(index)")
                            cell.player?.play()
                            currentIndex = index
                        }
                    }
                }
            }
        }
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
