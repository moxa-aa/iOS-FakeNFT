import UIKit

final class TabBarController: UITabBarController {

    var servicesAssembly: ServicesAssembly!

    private let catalogTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.catalog", comment: ""),
        image: UIImage(systemName: "square.stack.3d.up.fill"),
        tag: 0
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        let catalogController = CatalogAssembly(
            servicesAssembler: servicesAssembly
        ).build()
        let catalogNavigationController = UINavigationController(
            rootViewController: catalogController
        )
        catalogNavigationController.tabBarItem = catalogTabBarItem

        viewControllers = [catalogNavigationController]

        view.backgroundColor = .systemBackground
    }
}
