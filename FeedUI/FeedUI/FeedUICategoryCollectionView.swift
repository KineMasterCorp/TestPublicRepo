//
//  FeedUICategoryCollectionView.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/06/16.
//

import UIKit

class FeedUICategoryCollectionView: UIView {
    private var cellModels: [CategoryCellModel]
    private weak var delegate: FeedUICategoryDelegate?
    private var selectedIndex: Int = -1
    
    private lazy var categoryLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: categoryLayout)
        view.register(FeedUICategoryCell.self, forCellWithReuseIdentifier: FeedUICategoryCell.reuseIdentifier)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = FeedUI.backgroundColor
        return view
    }()
    
    init(cellModels: [CategoryCellModel], delegate: FeedUICategoryDelegate?) {
        self.cellModels = cellModels
        self.delegate = delegate
        
        super.init(frame: .zero)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        
        selectedIndex = self.delegate?.initialSelectedIndex() ?? 0
        
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
    
    private var selectedCell: FeedUICategoryCell? {
        didSet {
            if let cell = oldValue, cell != selectedCell {
                cell.backgroundColor = FeedUI.Category.defaultColor
                cell.categoryLabel.textColor = .white
                cell.categoryLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            }
        }
        
        willSet {
            if let cell = newValue {
                cell.backgroundColor = FeedUI.Category.selectedColor
                cell.categoryLabel.textColor = .black
                cell.categoryLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
                delegate?.select(category: cellModels[selectedIndex].category)
            }
        }
    }
    public func update(with updatedViewModels: [CategoryCellModel]) {
        let lastInArray = self.cellModels.count
        let newItems = updatedViewModels.filter { !self.cellModels.contains($0) }
        self.cellModels.append(contentsOf: newItems)
        let newLastInArray = self.cellModels.count
        
        let indexPaths = Array(lastInArray..<newLastInArray).map{IndexPath(item: $0, section: 0)}
        
        self.collectionView.insertItems(at: indexPaths)
    }
}

extension FeedUICategoryCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedUICategoryCell.reuseIdentifier, for: indexPath) as! FeedUICategoryCell
        cell.configure(name: cellModels[indexPath.item].category)
        
        if selectedCell == nil, indexPath.item == selectedIndex {
            selectedCell = cell
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        selectedCell = collectionView.cellForItem(at:indexPath) as? FeedUICategoryCell
    }
}

extension FeedUICategoryCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return FeedUICategoryCell.fittingSize(name: cellModels[indexPath.item].category)
    }
}
