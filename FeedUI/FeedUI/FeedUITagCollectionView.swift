//
//  FeedUITagCollectionView.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/06/16.
//

import UIKit

class FeedUITagCollectionView: UIView {
    private var items: [String]
    
    private lazy var tagLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: tagLayout)
        view.register(FeedUITagCell.self, forCellWithReuseIdentifier: FeedUITagCell.reuseIdentifier)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = FeedUIController.backgroundColor
        return view
    }()
    
    init(items: [String]) {
        self.items = items
        super.init(frame: .zero)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        
        addSubview(collectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
                
        let safeLayoutGuide = safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    
    public func select(at index: Int) {
        if index < collectionView.numberOfItems(inSection: 0) {
            collectionView(collectionView, didSelectItemAt: IndexPath(row: index, section: 0))
        }
    }
    
    private var selected: IndexPath? {
        didSet {
            if let path = oldValue, path != selected {
                if let prevCell = collectionView.cellForItem(at:path) as? FeedUITagCell {
                    prevCell.backgroundColor = defaultColor
                    prevCell.tagLabel.textColor = .white
                    prevCell.tagLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
                }
            }
        }
        
        willSet {
            if let path = newValue {
                if let tappedCell = collectionView.cellForItem(at:path) as? FeedUITagCell {
                    tappedCell.backgroundColor = selectedColor
                    tappedCell.tagLabel.textColor = .black
                    tappedCell.tagLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
                }
            }
        }
    }
    
    public func update(with items: [String]) {
        let lastInArray = self.items.count
        let newItems = items.filter { !self.items.contains($0) }
        self.items.append(contentsOf: newItems)
        let newLastInArray = self.items.count
        
        let indexPaths = Array(lastInArray..<newLastInArray).map{IndexPath(item: $0, section: 0)}
        
        self.collectionView.insertItems(at: indexPaths)
    }
    
    public weak var delegate: FeedUITagDelegate?
    
    private var selectedColor = UIColor.hexStringToUIColor(hex: "#ff5b5b")
    private var defaultColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.05)
}

extension FeedUITagCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedUITagCell.reuseIdentifier, for: indexPath) as! FeedUITagCell
        cell.configure(name: items[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selected = indexPath
        delegate?.select(tag: items[indexPath.item])
    }
}

extension FeedUITagCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return FeedUITagCell.fittingSize(name: items[indexPath.item])
    }
}
