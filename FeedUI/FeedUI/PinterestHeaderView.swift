//
//  PinterestHeaderView.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/06/15.
//

import UIKit

class PinterestHeaderView: UIStackView {
    public var onDismiss: (() -> Void)?
    
    private lazy var hStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.tintColor = .white
        
        return stackView
    }()
    
    private lazy var tagLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
        return layout
    }()
    
    private lazy var tagCollectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: tagLayout)
        view.register(PinterestTagCell.self, forCellWithReuseIdentifier: PinterestTagCell.reuseIdentifier)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = PinterestUIController.backgroundColor
        return view
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        var image: UIImage?
        
        if #available(iOS 13, *) {
            image = UIImage(systemName: "magnifyingglass")
        } else {
            image = UIImage(named: "magnifyingglass")
        }
        
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white
        button.addTarget(target, action: #selector(searchButtonTapped), for: .touchUpInside)
        return button
    } ()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        
        searchBar.placeholder = "Search"
        searchBar.barTintColor = PinterestUIController.backgroundColor
        searchBar.showsCancelButton = true
        searchBar.tintColor = .white
        
        var magnifyingglass: UIImage?
        var xmark: UIImage?
        
        if #available(iOS 13, *) {
            magnifyingglass = UIImage(systemName: "magnifyingglass")?.withTintColor(.white)
            xmark = UIImage(systemName: "xmark")
        } else {
            magnifyingglass = UIImage(named: "magnifyingglass")
            xmark = UIImage(named: "xmark")
        }
                
        searchBar.setImage(magnifyingglass, for: UISearchBar.Icon.search, state: .normal)
        searchBar.setImage(xmark, for: .clear, state: .normal)
        
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            
            textfield.attributedPlaceholder = NSAttributedString(string: textfield.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
            
            textfield.textColor = UIColor.white
        }
        return searchBar
    } ()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        var image: UIImage?
        
        if #available(iOS 13, *) {
            image = UIImage(systemName: "xmark")
        } else {
            image = UIImage(named: "xmark")
        }
        
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.addTarget(target, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    } ()
    
    init (frame: CGRect, onDismiss: (() -> Void)?) {
        super.init(frame: frame)
        self.onDismiss = onDismiss
     
        hStackView.addArrangedSubview(tagCollectionView)
        hStackView.addArrangedSubview(searchBar)
        hStackView.addArrangedSubview(searchButton)
        hStackView.addArrangedSubview(closeButton)
        
        tagCollectionView.showsVerticalScrollIndicator = false
        tagCollectionView.showsHorizontalScrollIndicator = false
        tagCollectionView.alwaysBounceHorizontal = true
        
        searchBar.isHidden = true
        
        let searchBarConstraintLeading = searchBar.leadingAnchor.constraint(equalTo: hStackView.leadingAnchor)
        searchBarConstraintLeading.priority = UILayoutPriority(700)
        
        let searchBarConstraintTrailing = searchBar.trailingAnchor.constraint(equalTo: hStackView.trailingAnchor)
        searchBarConstraintTrailing.priority = UILayoutPriority(700)
        
//        layoutConstraints.append(
//            contentsOf: [
//                searchBarConstraintLeading,
//                searchBarConstraintTrailing
//                ]
//        )
//        
//        layoutConstraints.append(
//            contentsOf: [searchButton.widthAnchor.constraint(equalToConstant: 52)]
//        )
//        
//        layoutConstraints.append(
//            contentsOf: [closeButton.widthAnchor.constraint(equalToConstant: 52)]
//        )
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc internal func searchButtonTapped(_ sender: Any) {
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.isEnabled = true
        }
        
        searchBar.isHidden = false
        searchButton.isHidden = true
        closeButton.isHidden = true
    }
    
    @objc internal func closeButtonTapped(_ sender: Any) {
        onDismiss?()
    }
}

extension PinterestHeaderView: UISearchBarDelegate {
    func filterContentBy(category: String = "전체") {
//        feedCollectionViewController.filteredSources = FeedDataSource(videos: feedCollectionViewController.sources.videos.filter({(video : FeedDataInfo) -> Bool in
//            let doesCategoryMatch = (category == "전체") || (video.category == category)
//            return doesCategoryMatch
//        }))
//
//        feedCollectionView.reloadData()
    }
        
    func filterContentBy(searchText: String, category: String) {
//        feedCollectionViewController.filteredSources = FeedDataSource(videos: feedCollectionViewController.sources.videos.filter({(video : FeedDataInfo) -> Bool in
//            let doesCategoryMatch = (category == "전체") || (video.category == category)
//            if searchBarIsEmpty() {
//                return doesCategoryMatch
//            } else {
//                return doesCategoryMatch && video.title.lowercased().contains(searchText.lowercased())
//            }
//        }))
//
//        feedCollectionView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchBar.text?.isEmpty ?? true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //filterContentBy(searchText: searchText, category: currentTag)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
        
        searchBar.isHidden = true
        searchButton.isHidden = false
        closeButton.isHidden = false
    }
}
