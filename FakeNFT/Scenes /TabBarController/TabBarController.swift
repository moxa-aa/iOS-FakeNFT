import UIKit

final class TabBarController: UITabBarController {

    var servicesAssembly: ServicesAssembly!

    private let profileTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.profile", comment: ""),
        image: UIImage(systemName: "person.crop.circle.fill"),
        tag: 0
    )

    private let catalogTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.catalog", comment: ""),
        image: UIImage(systemName: "square.stack.3d.up.fill"),
        tag: 1
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        let profileController = ProfileViewController()
        let profileNavigationController = UINavigationController(rootViewController: profileController)
        profileNavigationController.tabBarItem = profileTabBarItem

        let catalogController = CatalogAssembly(
            servicesAssembler: servicesAssembly
        ).build()
        let catalogNavigationController = UINavigationController(
            rootViewController: catalogController
        )
        catalogNavigationController.tabBarItem = catalogTabBarItem

        viewControllers = [profileNavigationController, catalogNavigationController]

        view.backgroundColor = .systemBackground
    }
}
