import Flutter
import UIKit
import UserMessagingPlatform   // Funding Choices / UMP SDK

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Create request parameters
    let parameters = RequestParameters()
    parameters.isTaggedForUnderAgeOfConsent = false

    let consentInformation = ConsentInformation.shared
    consentInformation.requestConsentInfoUpdate(with: parameters) { [weak self] error in
      if let error = error {
        print("Error requesting consent info: \(error.localizedDescription)")
        return
      }

      guard consentInformation.formStatus == .available else { return }

      // UI must run on the main thread; with SceneDelegate, `self.window` is often nil here.
      DispatchQueue.main.async {
        guard let presenter = Self.viewControllerForConsent(from: self) else {
          print("UMP: consent form available but no root view controller (scene window not ready).")
          return
        }
        ConsentForm.loadAndPresentIfRequired(from: presenter) { formError in
          if let formError = formError {
            print("Error showing consent form: \(formError.localizedDescription)")
          } else {
            print("Consent form handled successfully.")
          }
        }
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// With `SceneDelegate`, the key window lives on `UIWindowScene`, not `UIApplicationDelegate.window`.
  private static func viewControllerForConsent(from appDelegate: AppDelegate?) -> UIViewController? {
    if let window = appDelegate?.window, let root = window.rootViewController {
      return topPresented(from: root)
    }
    for scene in UIApplication.shared.connectedScenes {
      guard let windowScene = scene as? UIWindowScene else { continue }
      let window = windowScene.windows.first { $0.isKeyWindow } ?? windowScene.windows.first
      if let root = window?.rootViewController {
        return topPresented(from: root)
      }
    }
    return nil
  }

  private static func topPresented(from root: UIViewController) -> UIViewController {
    var top = root
    while let presented = top.presentedViewController {
      top = presented
    }
    if let nav = top as? UINavigationController, let visible = nav.visibleViewController {
      return topPresented(from: visible)
    }
    if let tab = top as? UITabBarController, let selected = tab.selectedViewController {
      return topPresented(from: selected)
    }
    return top
  }
}