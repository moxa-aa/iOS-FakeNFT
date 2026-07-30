import UIKit

final class CollectionViewController: UIViewController {

    private let viewModel: CollectionViewModel

    init(viewModel: CollectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationItem.title = viewModel.header.title
    }
}
