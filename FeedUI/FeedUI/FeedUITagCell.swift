//
//  FeedUITagCell.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/06/09.
//

import UIKit

final class FeedUITagCell: UICollectionViewCell {
    public static let reuseIdentifier = "FeedUITagCell"
    
    static func fittingSize(name: String?) -> CGSize {
        let cell = FeedUITagCell()
        cell.configure(name: name)
        
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.text = name
        label.sizeToFit()
        
        let size = label.frame.size
        
        return CGSize(width: size.width + 40, height: size.height + 16)
    }
        
    var tagLabel: UILabel = {
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
