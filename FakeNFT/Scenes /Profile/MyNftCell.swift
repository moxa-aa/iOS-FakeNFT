import UIKit
import Kingfisher

final class MyNftCell: UITableViewCell {
    
    static let reuseIdentifier = "MyNftCell"
    
    var onLikeTapped: (() -> Void)?
    
    // MARK: - UI Components
    
    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        button.tintColor = .systemRed
        button.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .segmentActive
        return label
    }()
    
    private lazy var starsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 2
        stack.distribution = .fillEqually
        for _ in 0..<5 {
            let starView = UIImageView(image: UIImage(systemName: "star.fill"))
            starView.tintColor = .systemGray5
            starView.contentMode = .scaleAspectFit
            stack.addArrangedSubview(starView)
        }
        return stack
    }()
    
    private lazy var authorPrefixLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Profile.author", comment: "")
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .segmentActive
        return label
    }()
    
    private lazy var authorNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .segmentActive
        return label
    }()
    
    private lazy var authorStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [authorPrefixLabel, authorNameLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()
    
    private lazy var priceTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Profile.price", comment: "")
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .segmentActive
        return label
    }()
    
    private lazy var priceValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .segmentActive
        return label
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, starsStackView, authorStackView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()
    
    private lazy var priceStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [priceTitleLabel, priceValueLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        return stack
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        selectionStyle = .none
        contentView.addSubview(nftImageView)
        contentView.addSubview(likeButton)
        contentView.addSubview(infoStackView)
        contentView.addSubview(priceStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nftImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nftImageView.widthAnchor.constraint(equalToConstant: 108),
            nftImageView.heightAnchor.constraint(equalToConstant: 108),
            
            likeButton.topAnchor.constraint(equalTo: nftImageView.topAnchor, constant: 4),
            likeButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: -4),
            likeButton.widthAnchor.constraint(equalToConstant: 30),
            likeButton.heightAnchor.constraint(equalToConstant: 30),
            
            infoStackView.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: 16),
            infoStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            infoStackView.trailingAnchor.constraint(lessThanOrEqualTo: priceStackView.leadingAnchor, constant: -8),
            
            starsStackView.heightAnchor.constraint(equalToConstant: 12),
            
            priceStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            priceStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with nft: Nft, isLiked: Bool) {
        titleLabel.text = nft.name
        authorNameLabel.text = nft.author.host ?? nft.author.absoluteString
        priceValueLabel.text = String(format: "%.2f ETH", nft.price)
        
        let heartImage = isLiked ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: heartImage), for: .normal)
        likeButton.tintColor = isLiked ? .systemRed : .white
        
        updateRating(nft.rating)
        
        if let firstImageUrl = nft.images.first {
            nftImageView.kf.setImage(with: firstImageUrl, placeholder: UIImage(systemName: "photo"))
        } else {
            nftImageView.image = UIImage(systemName: "photo")
        }
    }
    
    private func updateRating(_ rating: Int) {
        for (index, subview) in starsStackView.arrangedSubviews.enumerated() {
            if let starView = subview as? UIImageView {
                starView.tintColor = index < rating ? UIColor(red: 254/255, green: 224/255, blue: 0/255, alpha: 1) : .systemGray5
            }
        }
    }
    
    @objc private func didTapLike() {
        onLikeTapped?()
    }
}
