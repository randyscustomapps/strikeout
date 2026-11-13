import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        let root = WebShellViewController()
        window.rootViewController = root
        window.backgroundColor = UIColor(red: 0xF2 / 255, green: 0xDF / 255, blue: 0xA7 / 255, alpha: 1)
        self.window = window
        window.makeKeyAndVisible()
        if let url = connectionOptions.urlContexts.first?.url {
            root.queueImport(url)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url,
              let root = window?.rootViewController as? WebShellViewController else { return }
        root.queueImport(url)
    }
}
