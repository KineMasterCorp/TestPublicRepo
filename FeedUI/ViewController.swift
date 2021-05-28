//
//  ViewController.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/05/24.
//

import UIKit

protocol WaterfallLayoutDelegate: AnyObject {
        func numberOfColumns() -> Int
        func columnsSize(at indexPath: IndexPath) -> CGSize
        func columnSpace() -> CGFloat
}

class ViewController: UIViewController {
    enum Section {
        case main
    }
    
    struct Item: Hashable {
        let height: CGFloat
        let color: UIColor
        private let identifier = UUID()
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        static func == (lhs:Item, rhs:Item) -> Bool {
            return lhs.identifier == rhs.identifier
        }
    }
    
    var currentSnapshot: NSDiffableDataSourceSnapshot<Section, Item>!
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        waterfallLayout = self
        configureHierarchy()
        configureDataSource()
    }
    
    weak var waterfallLayout: WaterfallLayoutDelegate?
    
    lazy var collectionViewLayout: UICollectionViewCompositionalLayout = {
            return UICollectionViewCompositionalLayout { [unowned self] (section, environment) -> NSCollectionLayoutSection? in
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(environment.container.effectiveContentSize.height))
                let group = NSCollectionLayoutGroup.custom(layoutSize: groupSize) { [unowned self] (environment) -> [NSCollectionLayoutGroupCustomItem] in
                    var items: [NSCollectionLayoutGroupCustomItem] = []
                    var layouts: [Int: CGFloat] = [:]
                    let space: CGFloat = self.waterfallLayout.flatMap({ CGFloat($0.columnSpace()) }) ?? 1.0
                    let numberOfColumn: CGFloat = self.waterfallLayout.flatMap({ CGFloat($0.numberOfColumns()) }) ?? 2.0
                    let defaultSize = CGSize(width: 100, height: 100)

                    (0 ..< self.collectionView.numberOfItems(inSection: section)).forEach {
                        let indexPath = IndexPath(item: $0, section: section)

                        let size = self.waterfallLayout?.columnsSize(at: indexPath) ?? defaultSize
                        let aspect = CGFloat(size.height) / CGFloat(size.width)

                        let width = (environment.container.effectiveContentSize.width - (numberOfColumn - 1) * space) / numberOfColumn
                        let height = width * aspect

                        let currentColumn = $0 % Int(numberOfColumn)
                        let y = layouts[currentColumn] ?? 0.0 + space
                        let x = width * CGFloat(currentColumn) + space * (CGFloat(currentColumn) - 1.0)

                        let frame = CGRect(x: x, y: y + space, width: width, height: height)
                        let item = NSCollectionLayoutGroupCustomItem(frame: frame)
                        items.append(item)

                        layouts[currentColumn] = frame.maxY
                    }
                    return items
                }
                return NSCollectionLayoutSection(group: group)
            }
        }()
}

extension ViewController {
    
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleWidth]
        view.addSubview(collectionView)
    }
    
    func configureDataSource() {
        let reuseIdentifier = "cell-idententifier"
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
            cell.contentView.backgroundColor = item.color
            cell.contentView.layer.borderColor = UIColor.black.cgColor
            cell.contentView.layer.borderWidth = 1
            return cell
        }
        currentSnapshot = intialSnapshot()
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    
    func intialSnapshot() -> NSDiffableDataSourceSnapshot<Section, Item> {
        let itemCount = 20
        var items = [Item]()
        for _ in 0..<itemCount {
            let height = CGFloat.random(in: 200..<500)
            let color = UIColor(hue:CGFloat.random(in: 0.1..<0.9), saturation: 1.0, brightness: 1.0, alpha: 1.0)
            let item = Item(height: height, color: color)
            items.append(item)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        return snapshot
    }
}

extension ViewController: WaterfallLayoutDelegate {
    func numberOfColumns() -> Int {
        4
    }

    func columnsSize(at indexPath: IndexPath) -> CGSize {
        let width = CGFloat.random(in: 200..<500)
        let height = CGFloat.random(in: 200..<500)
        return CGSize(width: width, height: height)
    }

    func columnSpace() -> CGFloat {
        5.0
    }
}

