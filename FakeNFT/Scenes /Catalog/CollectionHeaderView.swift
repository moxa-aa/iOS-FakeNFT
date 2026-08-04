import UIKit
import Kingfisher

protocol CollectionHeaderViewDelegate: AnyObject {
    func collectionHeaderDidTapAuthor(_ header: CollectionHeaderView)
}

final class CollectionHeaderView: UICollectionReusableView {

    static let reuseIdentifier = "CollectionHeaderView"

    weak var delegate: CollectionHeaderViewDelegate?

    private enum Layout {
        static let coverHeight: CGFloat = 310
        static let coverCornerRadius: CGFloat = 12
        static let horizontalInset: CGFloat = 16
        static let titleTopSpacing: CGFloat = 16
        static let authorTopSpacing: CGFloat = 13
        static let authorNameSpacing: CGFloat = 4
        static let descriptionTopSpacing: CGFloat = 5
        static let bottomSpacing: CGFloat = 24
    }

    private static let sizingView = CollectionHeaderView()

    static func height(for model: CollectionHeaderViewModel, width: CGFloat) -> CGFloat {
        let sizingView = CollectionHeaderView.sizingView
        sizingView.applyText(from: model)
        sizingView.bounds.size.width = width
        let size = sizingView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return ceil(size.height)
    }

    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Layout.coverCornerRadius
        imageView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        imageView.backgroundColor = .segmentInactive
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .headline3
        label.textColor = .segmentActive
        label.numberOfLines = 0
        return label
    }()

    private lazy var authorPrefixLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .segmentActive
        label.text = NSLocalizedString("Collection.author", comment: "")
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private lazy var authorNameLabel: UILabel = {
        let label = UILabel()
        label.font = .caption1
        label.textColor = .link
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(authorTapped))
        )
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .segmentActive
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }

    func configure(with model: CollectionHeaderViewModel) {
        applyText(from: model)
        coverImageView.kf.setImage(
            with: model.coverURL,
            placeholder: UIImage.coverPlaceholder
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.kf.cancelDownloadTask()
        coverImageView.image = nil
        titleLabel.text = nil
        authorNameLabel.text = nil
        descriptionLabel.text = nil
    }

    @objc
    private func authorTapped() {
        delegate?.collectionHeaderDidTapAuthor(self)
    }

    private func applyText(from model: CollectionHeaderViewModel) {
        titleLabel.text = model.title
        authorNameLabel.text = model.authorName
        descriptionLabel.text = model.description
    }

    private func setupLayout() {
        [coverImageView, titleLabel, authorPrefixLabel, authorNameLabel, descriptionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: Layout.coverHeight),

            titleLabel.topAnchor.constraint(
                equalTo: coverImageView.bottomAnchor,
                constant: Layout.titleTopSpacing
            ),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.horizontalInset),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.horizontalInset),

            authorPrefixLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: Layout.authorTopSpacing
            ),
            authorPrefixLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            authorNameLabel.firstBaselineAnchor.constraint(equalTo: authorPrefixLabel.firstBaselineAnchor),
            authorNameLabel.leadingAnchor.constraint(
                equalTo: authorPrefixLabel.trailingAnchor,
                constant: Layout.authorNameSpacing
            ),
            authorNameLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: titleLabel.trailingAnchor
            ),

            descriptionLabel.topAnchor.constraint(
                equalTo: authorPrefixLabel.bottomAnchor,
                constant: Layout.descriptionTopSpacing
            ),
            descriptionLabel.topAnchor.constraint(
                greaterThanOrEqualTo: authorNameLabel.bottomAnchor,
                constant: Layout.descriptionTopSpacing
            ),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -Layout.bottomSpacing
            )
        ])
    }
}
