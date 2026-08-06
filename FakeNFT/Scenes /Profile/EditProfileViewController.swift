import UIKit
import Kingfisher

final class EditProfileViewController: UIViewController {
    
    private let viewModel: ProfileViewModelProtocol
    private var currentAvatarUrl: String = ""
    
    // MARK: - UI Components
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        if let image = UIImage(named: "close") {
            button.setImage(image, for: .normal)
        } else {
            button.setImage(UIImage(systemName: "xmark"), for: .normal)
        }
        button.tintColor = .segmentActive
        button.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        
        // Add gesture recognizer to change photo
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeAvatar))
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()
    
    private lazy var avatarOverlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black.withAlphaComponent(0.6)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var avatarOverlayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Сменить\nфото"
        label.textColor = .white
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    // Name field
    private lazy var nameTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Profile.edit.name", comment: "")
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .segmentActive
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 12
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.textColor = .segmentActive
        textField.setLeftPadding(16)
        textField.setRightPadding(16)
        textField.placeholder = NSLocalizedString("Profile.edit.placeholderName", comment: "")
        textField.delegate = self
        return textField
    }()
    
    // Description field
    private lazy var descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Profile.edit.description", comment: "")
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .segmentActive
        return label
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.cornerRadius = 12
        textView.font = .systemFont(ofSize: 17, weight: .regular)
        textView.textColor = .segmentActive
        textView.textContainerInset = UIEdgeInsets(top: 11, left: 12, bottom: 11, right: 12)
        return textView
    }()
    
    // Website field
    private lazy var websiteTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Profile.edit.website", comment: "")
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .segmentActive
        return label
    }()
    
    private lazy var websiteTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 12
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.textColor = .segmentActive
        textField.setLeftPadding(16)
        textField.setRightPadding(16)
        textField.placeholder = NSLocalizedString("Profile.edit.placeholderWebsite", comment: "")
        textField.delegate = self
        return textField
    }()
    
    // MARK: - Initialization
    
    init(viewModel: ProfileViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        populateData()
        setupKeyboardDismissal()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(closeButton)
        view.addSubview(avatarImageView)
        
        avatarImageView.addSubview(avatarOverlayView)
        avatarOverlayView.addSubview(avatarOverlayLabel)
        
        view.addSubview(nameTitleLabel)
        view.addSubview(nameTextField)
        view.addSubview(descriptionTitleLabel)
        view.addSubview(descriptionTextView)
        view.addSubview(websiteTitleLabel)
        view.addSubview(websiteTextField)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Close Button
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 42),
            closeButton.heightAnchor.constraint(equalToConstant: 42),
            
            // Avatar Image View
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            
            // Avatar Overlay View
            avatarOverlayView.topAnchor.constraint(equalTo: avatarImageView.topAnchor),
            avatarOverlayView.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            avatarOverlayView.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor),
            avatarOverlayView.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
            
            // Avatar Overlay Label
            avatarOverlayLabel.centerXAnchor.constraint(equalTo: avatarOverlayView.centerXAnchor),
            avatarOverlayLabel.centerYAnchor.constraint(equalTo: avatarOverlayView.centerYAnchor),
            avatarOverlayLabel.leadingAnchor.constraint(equalTo: avatarOverlayView.leadingAnchor, constant: 4),
            avatarOverlayLabel.trailingAnchor.constraint(equalTo: avatarOverlayView.trailingAnchor, constant: -4),
            
            // Name Section
            nameTitleLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 24),
            nameTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            nameTextField.topAnchor.constraint(equalTo: nameTitleLabel.bottomAnchor, constant: 8),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Description Section
            descriptionTitleLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            descriptionTextView.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 8),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 132),
            
            // Website Section
            websiteTitleLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 24),
            websiteTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            websiteTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            websiteTextField.topAnchor.constraint(equalTo: websiteTitleLabel.bottomAnchor, constant: 8),
            websiteTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            websiteTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            websiteTextField.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func populateData() {
        nameTextField.text = viewModel.currentName
        descriptionTextView.text = viewModel.currentDescription
        websiteTextField.text = viewModel.currentWebsite
        currentAvatarUrl = viewModel.currentAvatarUrl
        loadAvatar(from: URL(string: currentAvatarUrl))
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
    
    private func setupKeyboardDismissal() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    
    @objc private func didTapCloseButton() {
        // Save changes to ViewModel
        let updatedName = nameTextField.text ?? ""
        let updatedDescription = descriptionTextView.text ?? ""
        let updatedWebsite = websiteTextField.text ?? ""
        
        viewModel.updateProfile(
            name: updatedName,
            description: updatedDescription,
            website: updatedWebsite,
            avatarUrl: currentAvatarUrl
        )
        
        dismiss(animated: true)
    }
    
    @objc private func didTapChangeAvatar() {
        let alert = UIAlertController(
            title: NSLocalizedString("Profile.edit.avatar", comment: ""),
            message: NSLocalizedString("Profile.edit.placeholderAvatar", comment: ""),
            preferredStyle: .alert
        )
        
        alert.addTextField { [weak self] textField in
            textField.placeholder = "https://example.com/avatar.png"
            textField.text = self?.currentAvatarUrl
        }
        
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak self, weak alert] _ in
            guard let newUrlString = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  let url = URL(string: newUrlString) else { return }
            self?.currentAvatarUrl = newUrlString
            self?.loadAvatar(from: url)
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Profile.cancel", comment: ""), style: .cancel)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITextField Padding Extension

extension UITextField {
    func setLeftPadding(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPadding(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
