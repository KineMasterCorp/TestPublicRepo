//
//  FeedViewController.swift
//  SeamlessSwitching
//
//  Created by JT3 on 2021/05/25.
//

import UIKit

class FeedViewController: UIViewController {

    public var interactor: FeedInteractor?
    
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
        
    override func viewWillAppear(_ animated: Bool) {
        interactor?.dispatch(.viewWillAppear)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        interactor?.dispatch(.viewDidAppear)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        interactor?.dispatch(.viewDidDisappear)
    }
    
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setNavigationBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        interactor?.dispatch(.applicationDidBecomeActive)
    }
    @objc func applicationDidEnterBackground(notification: NSNotification) {
        interactor?.dispatch(.applicationDidEnterBackground)
    }
    
    private func setNavigationBar() {
        navigationController?.isNavigationBarHidden = false
        
        let bar = navigationController?.navigationBar
        bar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        bar?.shadowImage = UIImage()
        bar?.backgroundColor = UIColor.clear
        bar?.topItem?.title = ""
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
    
    func update(with state: Feed.ViewState) {
        NSLog("current title: \(String(describing: videoManager.getDataInfo(currentIndex)?.title)), play: \(state.play), modal presented: \(state.modalPresented)")
        
        state.play ? videoManager.play() : videoManager.pause()        
    }
}

extension FeedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoManager.videoCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        NSLog("Cell for \(indexPath) requested.")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.identifier, for: indexPath) as! VideoCollectionViewCell

        cell.tagTapCallBack = { [weak self] (string, wordType) in
            self?.interactor?.dispatch(.touchTag(tag: string, wordType: wordType))
        }
        
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
