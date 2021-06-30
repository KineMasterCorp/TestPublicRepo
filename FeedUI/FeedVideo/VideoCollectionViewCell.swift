//
//  VideoCollectionViewCell.swift
//  SeamlessSwitching
//
//  Created by JT3 on 2021/05/25.
//

import UIKit
import AVFoundation

class VideoCollectionViewCell: UICollectionViewCell {
    static let identifier = "VideoCollectionViewCell"

    private var playerLayer: AVPlayerLayer?
    private var videoManager: VideoCollectionViewModel!
    private var videoIndex = 0
    var tagTapCallBack: ((String, wordType) -> Void)?
    
    private lazy var vStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.tintColor = .white
        
        return stackView
    }()
        
    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        label.textColor = .white
        return label
    } ()
    
    private lazy var hashTagsView: AttrTextView = {
        let view = AttrTextView()
        
        view.isScrollEnabled = false
        view.isEditable = false
        view.isSelectable = false
        view.backgroundColor = .clear
        view.textAlignment = .left
        view.textContainerInset = UIEdgeInsets.zero
        view.textContainer.lineFragmentPadding = 0
        
        return view
    } ()
    
    private lazy var hBottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.tintColor = .white
        
        return stackView
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.textColor = .white
        
        return label
    } ()
    
    var ratioLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.textColor = .white
        return label
    } ()
    
    private lazy var downloadButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.backgroundColor = UIColor.hexStringToUIColor(hex: "#ff5b5b")
        button.setTitle("다운로드", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        button.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
        
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 6
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.masksToBounds = false

        return button
    } ()
    
    var opacityView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black.withAlphaComponent(0.1)
        return view
    } ()


    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .black
        contentView.clipsToBounds = true
        
        hBottomStackView.addArrangedSubview(timeLabel)
        hBottomStackView.addArrangedSubview(ratioLabel)
                
        vStackView.addArrangedSubview(titleLabel)
        vStackView.addArrangedSubview(hashTagsView)
        vStackView.addArrangedSubview(hBottomStackView)
        
        addSubview(downloadButton)
        addSubview(opacityView)
        addSubview(vStackView)
        
        let safeLayoutGuide = contentView.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            vStackView.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor),
            vStackView.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor, constant: 15),
            //titleLabel.bottomAnchor.constraint(equalTo: hashTagsView.topAnchor, constant: -12),
            timeLabel.widthAnchor.constraint(equalToConstant: 50),
            ratioLabel.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 10),
            
            opacityView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            opacityView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            opacityView.topAnchor.constraint(equalTo: contentView.topAnchor),
            opacityView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                        
            downloadButton.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor, constant: -18),
            downloadButton.widthAnchor.constraint(equalToConstant: 114),
            downloadButton.heightAnchor.constraint(equalToConstant: 44),
            downloadButton.bottomAnchor.constraint(equalTo: hashTagsView.bottomAnchor),
        ])

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("videoCell \(videoIndex) deinit")
    }
    
    public func configure(with videoManager: VideoCollectionViewModel, index: Int) {
        NSLog("videoCell configure index: \(index)")
        self.videoManager = videoManager
        videoIndex = index
        
        let player = videoManager.preparePlayer(index)
        
        configureSubviews(with: videoManager.getDataInfo(index))
        configureVideo(with: player)
    }
    
    private func configureSubviews(with dataInfo: FeedDataInfo?) {
        guard let dataInfo = dataInfo else { return }
        
        titleLabel.text = dataInfo.title
        
        let tags = dataInfo.tags.map { "#" + $0 }.joined(separator: " ")
        
        if !tags.isEmpty, let callback = tagTapCallBack {
            hashTagsView.setText(text: tags,
                                 withHashtagColor: .white,
                                 andMentionColor: .white,
                                 andCallBack: callback,
            normalFont: UIFont.systemFont(ofSize: 15, weight: .regular),
            hashTagFont: UIFont.systemFont(ofSize: 15, weight: .bold),
            mentionFont: UIFont.systemFont(ofSize: 15, weight: .semibold))
        }
        
        setImageLabel(uiLabel: timeLabel, imageName: "time", text: "00:20")
        setImageLabel(uiLabel: ratioLabel, imageName: "ratio", text: "16:9")
    }
    
    private func configureVideo(with player: AVPlayer) {
        playerLayer = AVPlayerLayer(player: player)
        playerLayer!.frame = contentView.bounds
        playerLayer!.videoGravity = .resizeAspect
        playerLayer!.backgroundColor = FeedUI.backgroundColor.cgColor
        
        contentView.layer.addSublayer(playerLayer!)
    }
    
    private func setImageLabel(uiLabel: UILabel, imageName: String, text: String) {
        let attributedString = NSMutableAttributedString(string: "")
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: imageName)
        imageAttachment.bounds = CGRect(x: 0, y: -4, width: 16, height: 16)
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        attributedString.append(NSAttributedString(string: text))
        
        uiLabel.attributedText = attributedString
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isUserInteractionEnabled else { return nil }
        guard !isHidden else { return nil }
        guard alpha >= 0.01 else { return nil }
        guard self.point(inside: point, with: event) else { return nil }
                
        // add one of these blocks for each button in our collection view cell we want to actually work
        if self.downloadButton.point(inside: convert(point, to: downloadButton), with: event) {
            return self.downloadButton
        }
        
        return super.hitTest(point, with: event)
    }

    
    @objc internal func downloadButtonTapped(_ sender: Any) {
        print("downloadButtonTapped")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        NSLog("prepareForReuse index: \(videoIndex)")

        videoManager?.doneUsingPlayer(videoIndex)
        playerLayer?.player = nil   // Workaround code for old devices like iPhone 5s.
                                    // If we scroll the screen very fast, only black screen is shown on the device with playing only audio.
        playerLayer?.removeFromSuperlayer()
    }
}
