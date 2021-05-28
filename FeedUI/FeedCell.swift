//
//  FeedCell.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/05/24.
//

import UIKit

class FeedCell: UICollectionViewCell {
    public static let reuseIdentifier = "FeedCell"
    fileprivate var imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 6
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    } ()
    
    fileprivate var captionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
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
                         imageView.bottomAnchor.constraint(equalTo: captionLabel.topAnchor, constant: -6)])
        
        addSubview(captionLabel)
        layoutConstraints.append(
            contentsOf: [captionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
                         captionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                         captionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                         captionLabel.bottomAnchor.constraint(equalTo: bottomAnchor)])
        
        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var photo: Photo? {
        didSet {
            if let photo = photo {
                imageView.image = photo.image
                captionLabel.text = photo.caption
            }
        }
    }
}
