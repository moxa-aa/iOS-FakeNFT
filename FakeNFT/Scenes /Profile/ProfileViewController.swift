import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private let viewModel: ProfileViewModelProtocol
    
    // MARK: - UI Components
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .gray
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .segmentActive
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .segmentActive
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var websiteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        button.setTitleColor(.systemBlue, for: .normal)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(didTapWebsiteButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProfileCell")
        return tableView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Initialization
    
    init(viewModel: ProfileViewModelProtocol = ProfileViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        setupConstraints()
        bindViewModel()
        viewModel.fetchProfile()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        let editImage = UIImage(systemName: "square.and.pencil")
        let editButton = UIBarButtonItem(
            image: editImage,
            style: .plain,
            target: self,
            action: #selector(didTapEditButton)
        )
        editButton.tintColor = .segmentActive
        navigationItem.rightBarButtonItem = editButton
        
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = .segmentActive
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(websiteButton)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Avatar
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            
            // Name Label
            nameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 17),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Description Label
            descriptionLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Website Button
            websiteButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            websiteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            websiteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            websiteButton.heightAnchor.constraint(equalToConstant: 28),
            
            // Table View
            tableView.topAnchor.constraint(equalTo: websiteButton.bottomAnchor, constant: 40),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            // Activity Indicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.nameObservable.bind { [weak self] name in
            self?.nameLabel.text = name
        }
        viewModel.avatarUrlObservable.bind { [weak self] url in
            self?.loadAvatar(from: url)
        }
        viewModel.descriptionObservable.bind { [weak self] desc in
            self?.descriptionLabel.text = desc
        }
        viewModel.websiteUrlObservable.bind { [weak self] url in
            self?.websiteButton.setTitle(url?.absoluteString, for: .normal)
        }
        viewModel.myNftsCountObservable.bind { [weak self] _ in
            self?.tableView.reloadData()
        }
        viewModel.favoriteNftsCountObservable.bind { [weak self] _ in
            self?.tableView.reloadData()
        }
        viewModel.isLoadingObservable.bind { [weak self] isLoading in
            if isLoading {
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.stopAnimating()
            }
        }
    }
    
    private func loadAvatar(from url: URL?) {
        guard let url = url else {
            avatarImageView.image = UIImage(systemName: "person.crop.circle")
            return
        }
        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(systemName: "person.crop.circle")
        )
    }
    
    // MARK: - Actions
    
    @objc private func didTapEditButton() {
        let editVC = EditProfileViewController(viewModel: viewModel)
        editVC.modalPresentationStyle = .pageSheet
        present(editVC, animated: true)
    }
    
    @objc private func didTapWebsiteButton() {
        guard let url = viewModel.websiteUrlObservable.value else { return }
        openWebView(with: url)
    }
    
    private func openWebView(with url: URL) {
        let webVC = WebViewController(url: url)
        webVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(webVC, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
        
        let title: String
        switch indexPath.row {
        case 0:
            let count = viewModel.myNftsCountObservable.value
            title = "\(NSLocalizedString("Profile.myNfts", comment: "")) (\(count))"
        case 1:
            let count = viewModel.favoriteNftsCountObservable.value
            title = "\(NSLocalizedString("Profile.favoriteNfts", comment: "")) (\(count))"
        case 2:
            title = NSLocalizedString("Profile.aboutDeveloper", comment: "")
        default:
            title = ""
        }
        
        cell.textLabel?.text = title
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        cell.textLabel?.textColor = .segmentActive
        
        let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronImageView.tintColor = .segmentActive
        cell.accessoryView = chevronImageView
        
        cell.selectionStyle = .none
        
        let separator = UIView()
        separator.backgroundColor = .systemGray4
        separator.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(separator)
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            let myNftsViewModel = MyNftsViewModel(
                profileService: viewModel.profileService,
                nftIds: viewModel.myNftIds,
                favoriteIds: viewModel.favoriteNftIds
            )
            let myNftsVC = MyNftsViewController(viewModel: myNftsViewModel)
            myNftsVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(myNftsVC, animated: true)
        case 1:
            let favoritesViewModel = FavoritesViewModel(profileService: viewModel.profileService)
            let favoritesVC = FavoritesViewController(viewModel: favoritesViewModel)
            favoritesVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(favoritesVC, animated: true)

        case 2:
            if let url = viewModel.websiteUrlObservable.value {
                openWebView(with: url)
            }
        default:
            break
        }
    }
}
