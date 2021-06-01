//
//  FeedTagViewController.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/05/26.
//

import UIKit

final class FeedTagView: UICollectionView {
    var items = [String]()
        
    private var selected: IndexPath? {
        didSet {
            if let path = oldValue, path != selected {
                if let prevCell = cellForItem(at:path) as? TagCell {
                    prevCell.backgroundColor = defaultColor
                    prevCell.tagLabel.textColor = .white
                    prevCell.tagLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
                }
            }
        }
        
        willSet {
            if let path = newValue {
                if let tappedCell = cellForItem(at:path) as? TagCell {
                    tappedCell.backgroundColor = selectedColor
                    tappedCell.tagLabel.textColor = .black
                    tappedCell.tagLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
                }
            }
        }
    }
    
    private var selectedColor = hexStringToUIColor(hex: "#ff5b5b")
    private var defaultColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.05)
    public weak var tagDelegate: TagDelegate?
}

protocol TagDelegate: AnyObject {
    func notify(tag: String) -> Void
}

extension FeedTagView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCell
        cell.configure(name: items[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selected = indexPath
        tagDelegate?.notify(tag: items[indexPath.item])
    }    
}

extension FeedTagView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return TagCell.fittingSize(name: items[indexPath.item])
    }
}

final class TagCell: UICollectionViewCell {
    public static let reuseIdentifier = "TagCell"
    
    static func fittingSize(name: String?) -> CGSize {
        let cell = TagCell()
        cell.configure(name: name)
        
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.text = name
        label.sizeToFit()
        
        let size = label.frame.size
        
        return CGSize(width: size.width + 40, height: size.height + 16)
    }
        
    fileprivate var tagLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .white
        return label
    } ()
    
    private var layoutConstraints: [NSLayoutConstraint]
    
    override init(frame: CGRect) {
        layoutConstraints = .init()
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    private func setupView() {
        backgroundColor = .init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.05)
        
        addSubview(tagLabel)
        
        layoutConstraints.append(
            contentsOf: [tagLabel.topAnchor.constraint(equalTo: topAnchor),
                         tagLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                         tagLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                         tagLabel.bottomAnchor.constraint(equalTo: bottomAnchor)])
        
        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    func configure(name: String?) {
        tagLabel.text = name
    }
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
