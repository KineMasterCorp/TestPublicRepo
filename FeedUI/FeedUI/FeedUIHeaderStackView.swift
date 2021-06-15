//
//  FeedUIHeaderStackView.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/05/26.
//

import UIKit

protocol FeedUITagDelegate: AnyObject {
    func select(tag: String) -> Void
}

protocol FeedUISearchDelegate: AnyObject {
    func search(with text: String) -> Void
}

protocol FeedUIHeaderStackViewDelegate: FeedUITagDelegate, FeedUISearchDelegate {
    func closeButtonTapped()
}

class FeedUIHeaderStackView: UIView {
    private var items: [String]
    private weak var delegate: FeedUIHeaderStackViewDelegate?
    
    init(items: [String], delegate: FeedUIHeaderStackViewDelegate?) {
        self.items = items
        self.delegate = delegate
        
        super.init(frame: .zero)
        
        hStackView.addArrangedSubview(collectionView)
        hStackView.addArrangedSubview(searchBar)
        hStackView.addArrangedSubview(searchButton)
        hStackView.addArrangedSubview(closeButton)
        
        searchBar.isHidden = true
        
        addSubview(hStackView)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let searchBarConstraintLeading = searchBar.leadingAnchor.constraint(equalTo: hStackView.leadingAnchor)
        searchBarConstraintLeading.priority = UILayoutPriority(700)
        
        let searchBarConstraintTrailing = searchBar.trailingAnchor.constraint(equalTo: hStackView.trailingAnchor)
        searchBarConstraintTrailing.priority = UILayoutPriority(700)
        
        let safeLayoutGuide = safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            hStackView.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor),
            hStackView.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
            hStackView.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
            hStackView.heightAnchor.constraint(equalToConstant: 52),
            
            searchBarConstraintLeading,
            searchBarConstraintTrailing,
            
            searchButton.widthAnchor.constraint(equalToConstant: 52),
            closeButton.widthAnchor.constraint(equalToConstant: 52)
        ])
    }
    
    private lazy var hStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.tintColor = .white
        
        return stackView
    }()
    
    private lazy var collectionView: FeedUITagCollectionView = {
        let view = FeedUITagCollectionView(items: items)
        view.delegate = delegate
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
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        
        searchBar.placeholder = "Search"
        searchBar.barTintColor = FeedUIController.backgroundColor
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
    
    @objc internal func searchButtonTapped(_ sender: Any) {
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.isEnabled = true
        }
        
        searchBar.isHidden = false
        searchButton.isHidden = true
        closeButton.isHidden = true
    }
    
    @objc internal func closeButtonTapped(_ sender: Any) {
        delegate?.closeButtonTapped()
    }
    
    func selectItem(at index: Int) {
        collectionView.select(at: index)
    }
    
    func update(with items: [String]) {
        collectionView.update(with: items)
    }
}

extension FeedUIHeaderStackView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.search(with: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
        
        searchBar.isHidden = true
        searchButton.isHidden = false
        closeButton.isHidden = false
    }
}
