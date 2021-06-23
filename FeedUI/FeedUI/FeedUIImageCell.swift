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
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
        return label
    } ()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                        
        buildSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with cellModel: ImageCellModel) {
        titleLabel.text = cellModel.title
        
        cellModel.load { [weak self] image in
            self?.imageView.image = image
        }
    }
    
    func buildSubviews() {
        addSubview(imageView)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
