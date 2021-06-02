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
    private var currentTag: String = "전체"
        
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
        view.delegate = view
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
        let image = UIImage(named: "xmark")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.addTarget(target, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    } ()
    
    @objc internal func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "magnifyingglass")?.withRenderingMode(.alwaysTemplate)
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
        searchBar.barTintColor = MasterViewController.backgroundColor
        searchBar.showsCancelButton = true
        searchBar.tintColor = .white
        
        let magnifyingglass = UIImage(named: "magnifyingglass")
        searchBar.setImage(magnifyingglass, for: UISearchBar.Icon.search, state: .normal)
        
        let xmark = UIImage(named: "xmark")
        searchBar.setImage(xmark, for: .clear, state: .normal)
        
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            
            textfield.attributedPlaceholder = NSAttributedString(string: textfield.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
            
            textfield.textColor = UIColor.white
        }
        return searchBar
    } ()
    
    private lazy var hStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.tintColor = .white
        
        return stackView
    }()
    
    @objc internal func searchButtonTapped(_ sender: Any) {
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.isEnabled = true
        }
        
        searchBar.isHidden = false
        searchButton.isHidden = true
        closeButton.isHidden = true
    }
    
    func setupHeaderViews() {
        let safeLayoutGuide = view.safeAreaLayoutGuide
        
        view.addSubview(hStackView)
        
        layoutConstraints.append(
            contentsOf: [
                hStackView.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor),
                hStackView.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
                hStackView.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
                hStackView.heightAnchor.constraint(equalToConstant: 52),
                ]
        )
        
        hStackView.addArrangedSubview(tagCollectionView)
        hStackView.addArrangedSubview(searchBar)
        hStackView.addArrangedSubview(searchButton)
        hStackView.addArrangedSubview(closeButton)
        
        tagCollectionView.tagDelegate = self
        tagCollectionView.showsVerticalScrollIndicator = false
        tagCollectionView.showsHorizontalScrollIndicator = false
        
        tagCollectionView.items.append("전체")
        
        tagCollectionView.items.append(contentsOf: feedCollectionView.sources.videos.compactMap { video in
            video.category
        }.uniqued())
        
        searchBar.isHidden = true
        
        let searchBarConstraintLeading = searchBar.leadingAnchor.constraint(equalTo: hStackView.leadingAnchor)
        searchBarConstraintLeading.priority = UILayoutPriority(700)
        
        let searchBarConstraintTrailing = searchBar.trailingAnchor.constraint(equalTo: hStackView.trailingAnchor)
        searchBarConstraintTrailing.priority = UILayoutPriority(700)
        
        layoutConstraints.append(
            contentsOf: [
                searchBarConstraintLeading,
                searchBarConstraintTrailing
                ]
        )
        
        layoutConstraints.append(
            contentsOf: [searchButton.widthAnchor.constraint(equalToConstant: 52)]
        )
        
        layoutConstraints.append(
            contentsOf: [closeButton.widthAnchor.constraint(equalToConstant: 52)]
        )
    }
    
    func setupFeedView() {
        view.addSubview(feedCollectionView)
        
        feedCollectionView.feedInfoDelegate = self
        
        let safeLayoutGuide = view.safeAreaLayoutGuide
        
        layoutConstraints.append(
            contentsOf: [
                feedCollectionView.topAnchor.constraint(equalTo: hStackView.bottomAnchor),
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
        feedCollectionView.filteredSources = VideoDataSource(videos: feedCollectionView.sources.videos.filter({(video : VideoDataInfo) -> Bool in
            let doesCategoryMatch = (category == "전체") || (video.category == category)
            return doesCategoryMatch
        }))
        
        feedCollectionView.reloadData()
    }
    
    func filterSources(photo: Photo, category: String) -> VideoDataSource {
        let videoSource = VideoDataSource(videos: feedCollectionView.sources.videos.filter({(video : VideoDataInfo) -> Bool in
            let doesCategoryMatch = (category == "전체") || (video.category == category)
            return doesCategoryMatch
        }))
        
        if let index = videoSource.videos.firstIndex(where: {$0.title == photo.caption}), index != 0 {
            videoSource.videos.move(from: index, to: 0)
            print("title: \(videoSource.videos[0].title)")
        }
        
        return videoSource
    }
    
    func filterContentBy(searchText: String, category: String) {
        feedCollectionView.filteredSources = VideoDataSource(videos: feedCollectionView.sources.videos.filter({(video : VideoDataInfo) -> Bool in
            let doesCategoryMatch = (category == "전체") || (video.category == category)
            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && video.title.lowercased().contains(searchText.lowercased())
            }
        }))
        
        feedCollectionView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchBar.text?.isEmpty ?? true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentBy(searchText: searchText, category: currentTag)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
        
        searchBar.isHidden = true
        searchButton.isHidden = false
        closeButton.isHidden = false
    }
}

extension MasterViewController: TagDelegate {
    func notify(tag: String) -> Void {
        currentTag = tag
        filterContentBy(category: tag)
        feedCollectionView.setContentOffset(.zero, animated: false)
    }
}

extension MasterViewController: FeedInfoDelegate {
    func notify(photo: Photo) -> Void {
        let sources = filterSources(photo: photo, category: currentTag)
        
        let controller = FeedViewController()
        controller.setDataSource(sources: sources)
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
}

extension Array where Element: Equatable
{
    mutating func move(_ element: Element, to newIndex: Index) {
        if let oldIndex: Int = self.firstIndex(of: element) { self.move(from: oldIndex, to: newIndex) }
    }
}

extension Array
{
    mutating func move(from oldIndex: Index, to newIndex: Index) {
        // Don't work for free and use swap when indices are next to each other - this
        // won't rebuild array and will be super efficient.
        if oldIndex == newIndex { return }
        if abs(newIndex - oldIndex) == 1 { return self.swapAt(oldIndex, newIndex) }
        self.insert(self.remove(at: oldIndex), at: newIndex)
    }
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
