//
//  MasterViewController.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/05/26.
//

import UIKit

class MasterViewController: UIViewController {
    private static let backgroundColor = UIColor(red: CGFloat(31.0/255),
                                                 green: CGFloat(33.0/255),
                                                 blue: CGFloat(38.0/255.0),
                                                 alpha: 1)
    
    private var layoutConstraints: [NSLayoutConstraint] = .init()
        
    private lazy var tagLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
        return layout
    }()
    
    private lazy var tagCollectionView: FeedTagView = {
        let view = FeedTagView(frame: CGRect.zero, collectionViewLayout: tagLayout)
        view.register(TagCell.self, forCellWithReuseIdentifier: TagCell.reuseIdentifier)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = view
        view.dataSource = view
        view.backgroundColor = MasterViewController.backgroundColor                
        return view
    }()
    
    private lazy var feedLayout: PinterestLayout = {
        let layout = PinterestLayout()
        return layout
    }()
    
    private lazy var feedCollectionView: FeedPreview = {
        let view = FeedPreview(frame: CGRect.zero, collectionViewLayout: feedLayout)
        view.register(FeedCell.self, forCellWithReuseIdentifier: FeedCell.reuseIdentifier)
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.dataSource = view
        view.backgroundColor = MasterViewController.backgroundColor
        if let layout = view.collectionViewLayout as? PinterestLayout {
            layout.delegate = view
        }
        
        return view
    }()
        
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold, scale: .large)
        let image = UIImage(systemName: "xmark", withConfiguration: symbolConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.addTarget(target, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    } ()
    
    @objc internal func closeButtonTapped(_ sender: Any) {
        print("onCloseButton")
    }
    
    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold, scale: .large)
        let image = UIImage(systemName: "magnifyingglass", withConfiguration: symbolConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.addTarget(target, action: #selector(searchButtonTapped), for: .touchUpInside)
        return button
    } ()
    
    @objc internal func searchButtonTapped(_ sender: Any) {
        print("onSearchButton")
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func setupHeaderViews() {
        view.addSubview(tagCollectionView)
        
        tagCollectionView.tagDelegate = self
        tagCollectionView.showsVerticalScrollIndicator = false
        tagCollectionView.showsHorizontalScrollIndicator = false
        
        let safeLayoutGuide = view.safeAreaLayoutGuide
        
        layoutConstraints.append(
            contentsOf: [
                tagCollectionView.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor),
                tagCollectionView.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
                tagCollectionView.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor),
                tagCollectionView.heightAnchor.constraint(equalToConstant: 52),
                ]
        )
              
        view.addSubview(searchButton)
        
        layoutConstraints.append(
            contentsOf: [
                searchButton.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor),
                searchButton.leadingAnchor.constraint(equalTo: tagCollectionView.trailingAnchor),
                searchButton.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor),
                searchButton.widthAnchor.constraint(equalToConstant: 52),
                searchButton.heightAnchor.constraint(equalToConstant: 52),
                ]
        )
        
        view.addSubview(closeButton)
        
        layoutConstraints.append(
            contentsOf: [
                closeButton.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor),
                closeButton.leadingAnchor.constraint(equalTo: searchButton.trailingAnchor),
                closeButton.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
                closeButton.widthAnchor.constraint(equalToConstant: 52),
                closeButton.heightAnchor.constraint(equalToConstant: 52),
                ]
        )
    }
    
    func setupFeedView() {
        view.addSubview(feedCollectionView)
        
        let safeLayoutGuide = view.safeAreaLayoutGuide
        
        layoutConstraints.append(
            contentsOf: [
                feedCollectionView.topAnchor.constraint(equalTo: tagCollectionView.bottomAnchor),
                feedCollectionView.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
                feedCollectionView.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
                feedCollectionView.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor),
                ]
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = MasterViewController.backgroundColor
                
        setupHeaderViews()
        setupFeedView()

        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tagCollectionView.collectionView(tagCollectionView, didSelectItemAt: IndexPath(row: 0, section: 0))
    }
}

extension MasterViewController: UISearchBarDelegate {
    func filterContentBy(category: String = "전체") {
        feedCollectionView.filteredPhotos = feedCollectionView.photos.filter({(photo : Photo) -> Bool in
            let doesCategoryMatch = (category == "전체") || (photo.category == category)
            return doesCategoryMatch
        })
        
        feedCollectionView.reloadData()
    }
}

extension MasterViewController: TagDelegate {
    func notify(tag: String) -> Void {
        
        filterContentBy(category: tag)
        feedCollectionView.setContentOffset(.zero, animated: false)
    }
}
