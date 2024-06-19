import UIKit

public final class NavigationControllerRouter: ContainerViewControllerRouter<UINavigationController> {
  private var onPopClosures = [UIViewController: () -> Void]()
  
  public override init(rootViewController: UINavigationController) {
    super.init(rootViewController: rootViewController)
    rootViewController.delegate = self
  }
  
  public func push(viewController: UIViewController,
                   animated: Bool = true,
                   onPopClosures: (() -> Void)? = nil,
                   completion: (() -> Void)? = nil) {
    self.onPopClosures[viewController] = onPopClosures
    rootViewController.pushViewController(
      viewController,
      animated: animated,
      completion: completion)
  }
  
  public func pop(animated: Bool = true,
                  completion: (() -> Void)? = nil) {
    rootViewController.popViewController(
      animated: animated,
      completion: completion
    )
  }
  
  public func popToRoot(animated: Bool = true,
                        completion: (() -> Void)? = nil) {
    rootViewController.popToRootViewController(
      animated: animated,
      completion: completion
    )
  }
  
  public func popTo(viewController: UIViewController,
                    animated: Bool = true,
                    completion: (() -> Void)? = nil) {
    rootViewController.popToViewController(viewController,
                                           animated: animated,
                                           completion: completion)
  }
  
  public func setViewControllers(_ items: [ (viewController: UIViewController, onPopClosure: (() -> Void)?) ],
                                 animated: Bool = true,
                                 completion: (() -> Void)? = nil) {
    let viewControllers = items.map { $0.viewController }
    items.forEach {
      onPopClosures[$0.viewController] = $0.onPopClosure
    }
    rootViewController.setViewControllers(
      viewControllers,
      animated: animated,
      completion: completion)
  }
}

extension NavigationControllerRouter: UINavigationControllerDelegate {
  public func navigationController(_ navigationController: UINavigationController,
                                   didShow viewController: UIViewController,
                                   animated: Bool) {
    guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
          !navigationController.viewControllers.contains(fromViewController) else {
      return
    }
    
    onPopClosures[fromViewController]?()
    onPopClosures.removeValue(forKey: fromViewController)
  }
}

