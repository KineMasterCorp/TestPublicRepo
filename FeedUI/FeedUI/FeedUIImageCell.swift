//
//  FeedUIImageCell.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/05/24.
//

import UIKit

class FeedUIImageCell: UICollectionViewCell {
    public static let reuseIdentifier = "FeedUIImageCell"
    var imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 6
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    } ()
    
    var captionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
        return label
    } ()
    
    private var layoutConstraints: [NSLayoutConstraint]
    
    override init(frame: CGRect) {
        layoutConstraints = .init()
        super.init(frame: frame)
                        
        addSubview(imageView)
        layoutConstraints.append(
            contentsOf: [imageView.topAnchor.constraint(equalTo: topAnchor),
                         imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                         imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
                         imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)])
        
        addSubview(captionLabel)
        layoutConstraints.append(
            contentsOf: [captionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 6),
                         captionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                         captionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                         captionLabel.bottomAnchor.constraint(equalTo: bottomAnchor)])
        
        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var item: FeedUIImage? {
        didSet {
            if let item = item {
                imageView.image = item.image
            }
        }
    }    
}
