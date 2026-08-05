import UIKit
import Kingfisher

final class FavoriteNftCell: UICollectionViewCell {
    static let identifier = "FavoriteNftCell"
    
    var onLikeTapped: (() -> Void)?
    
    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.backgroundColor = .imagePlaceholderBackground
        return imageView
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "like.active") ?? UIImage(systemName: "heart.fill")?.withTintColor(.heartActive, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .segmentActive
        return label
    }()
    
    private lazy var ratingStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 2
        stack.distribution = .fillEqually
        for _ in 0..<5 {
            let starView = UIImageView(image: UIImage(systemName: "star.fill"))
            starView.tintColor = .starInactive
            starView.contentMode = .scaleAspectFit
            stack.addArrangedSubview(starView)
        }
        return stack
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .segmentActive
        return label
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, ratingStackView, priceLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nftImageView.kf.cancelDownloadTask()
        nftImageView.image = nil
        onLikeTapped = nil
    }
    
    func configure(with nft: Nft) {
        nameLabel.text = nft.name
        priceLabel.text = "\(nft.price) ETH"
        updateRating(nft.rating)
        
        if let url = nft.images.first {
            nftImageView.kf.setImage(with: url)
        } else {
            nftImageView.image = nil
        }
    }
    
    private func updateRating(_ rating: Int) {
        for (index, view) in ratingStackView.arrangedSubviews.enumerated() {
            if let starView = view as? UIImageView {
                starView.tintColor = index < rating ? .ratingYellow : .starInactive
            }
        }
    }
    
    @objc private func likeTapped() {
        onLikeTapped?()
    }
    
    private func setupViews() {
        contentView.addSubview(nftImageView)
        contentView.addSubview(likeButton)
        contentView.addSubview(infoStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nftImageView.widthAnchor.constraint(equalToConstant: 80),
            nftImageView.heightAnchor.constraint(equalToConstant: 80),
            
            likeButton.topAnchor.constraint(equalTo: nftImageView.topAnchor, constant: -6),
            likeButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: 6),
            likeButton.widthAnchor.constraint(equalToConstant: 30),
            likeButton.heightAnchor.constraint(equalToConstant: 30),
            
            infoStackView.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: 12),
            infoStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            infoStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            ratingStackView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
}

