import UIKit
import Kingfisher

protocol NftCollectionViewCellDelegate: AnyObject {
    func nftCellDidTapLike(_ cell: NftCollectionViewCell)
    func nftCellDidTapCart(_ cell: NftCollectionViewCell)
}

final class NftCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "NftCollectionViewCell"

    enum Layout {
        static let starSize: CGFloat = 12
        static let starSpacing: CGFloat = 2
        static let buttonSize: CGFloat = 40
        static let imageToRating: CGFloat = 8
        static let ratingToTitle: CGFloat = 4
        static let titleToPrice: CGFloat = 4
        static let titleHeight: CGFloat = 44
        static let priceHeight: CGFloat = 12

        static var contentHeightBelowImage: CGFloat {
            imageToRating + starSize + ratingToTitle + titleHeight + titleToPrice + priceHeight
        }

        static func height(forWidth width: CGFloat) -> CGFloat {
            width + contentHeightBelowImage
        }
    }

    weak var delegate: NftCollectionViewCellDelegate?

    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .segmentInactive
        return imageView
    }()

    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(resource: .nftHeart), for: .normal)
        button.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        return button
    }()

    private lazy var starViews: [UIImageView] = (0..<5).map { _ in
        let imageView = UIImageView(image: UIImage(resource: .nftStar))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private lazy var ratingStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: starViews)
        stack.axis = .horizontal
        stack.spacing = Layout.starSpacing
        return stack
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = .segmentActive
        label.numberOfLines = 2
        return label
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .caption3
        label.textColor = .segmentActive
        return label
    }()

    private lazy var infoStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, priceLabel])
        stack.axis = .vertical
        stack.spacing = Layout.titleToPrice
        stack.alignment = .leading
        return stack
    }()

    private lazy var cartButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(cartTapped), for: .touchUpInside)
        return button
    }()

    private lazy var cartIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .nftCart))
        imageView.tintColor = .segmentActive
        imageView.isUserInteractionEnabled = false
        return imageView
    }()

    private lazy var cartCrossView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .nftCartCross))
        imageView.tintColor = .segmentActive
        imageView.isUserInteractionEnabled = false
        imageView.transform = CGAffineTransform(rotationAngle: .pi / 4)
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }

    func configure(with model: NftCellViewModel) {
        titleLabel.text = model.name
        priceLabel.text = String(format: "%g ETH", model.price)

        nftImageView.kf.setImage(
            with: model.imageURL,
            placeholder: UIImage.coverPlaceholder
        )

        likeButton.tintColor = model.isLiked ? .nftLike : .white
        cartCrossView.isHidden = !model.isInCart

        for (index, star) in starViews.enumerated() {
            star.tintColor = index < model.rating ? .ratingActive : .segmentInactive
        }

        likeButton.isEnabled = !model.isActionInFlight
        cartButton.isEnabled = !model.isActionInFlight
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nftImageView.kf.cancelDownloadTask()
        nftImageView.image = nil
        titleLabel.text = nil
        priceLabel.text = nil
        likeButton.tintColor = .white
        cartCrossView.isHidden = true
        starViews.forEach { $0.tintColor = .segmentInactive }
        likeButton.isEnabled = true
        cartButton.isEnabled = true
    }

    @objc
    private func likeTapped() {
        delegate?.nftCellDidTapLike(self)
    }

    @objc
    private func cartTapped() {
        delegate?.nftCellDidTapCart(self)
    }

    private func setupLayout() {
        [nftImageView, likeButton, ratingStackView, infoStackView, cartButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        [cartIconView, cartCrossView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            cartButton.addSubview($0)
        }
        starViews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.widthAnchor.constraint(equalToConstant: Layout.starSize),
                $0.heightAnchor.constraint(equalToConstant: Layout.starSize)
            ])
        }

        NSLayoutConstraint.activate([
            nftImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nftImageView.heightAnchor.constraint(equalTo: nftImageView.widthAnchor),

            likeButton.topAnchor.constraint(equalTo: nftImageView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: Layout.buttonSize),
            likeButton.heightAnchor.constraint(equalToConstant: Layout.buttonSize),

            ratingStackView.topAnchor.constraint(
                equalTo: nftImageView.bottomAnchor,
                constant: Layout.imageToRating
            ),
            ratingStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ratingStackView.heightAnchor.constraint(equalToConstant: Layout.starSize),

            infoStackView.topAnchor.constraint(
                equalTo: ratingStackView.bottomAnchor,
                constant: Layout.ratingToTitle
            ),
            infoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            infoStackView.trailingAnchor.constraint(
                equalTo: cartButton.leadingAnchor,
                constant: -4
            ),
            infoStackView.bottomAnchor.constraint(
                lessThanOrEqualTo: contentView.bottomAnchor
            ),

            cartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cartButton.centerYAnchor.constraint(equalTo: infoStackView.centerYAnchor),
            cartButton.widthAnchor.constraint(equalToConstant: Layout.buttonSize),
            cartButton.heightAnchor.constraint(equalToConstant: Layout.buttonSize),

            cartIconView.centerXAnchor.constraint(equalTo: cartButton.centerXAnchor),
            cartIconView.centerYAnchor.constraint(equalTo: cartButton.centerYAnchor),
            cartIconView.widthAnchor.constraint(equalToConstant: 16),
            cartIconView.heightAnchor.constraint(equalToConstant: 18.5),

            cartCrossView.centerXAnchor.constraint(equalTo: cartIconView.centerXAnchor),
            cartCrossView.centerYAnchor.constraint(
                equalTo: cartIconView.centerYAnchor,
                constant: 2.7
            ),
            cartCrossView.widthAnchor.constraint(equalToConstant: 7),
            cartCrossView.heightAnchor.constraint(equalToConstant: 7)
        ])
    }
}
