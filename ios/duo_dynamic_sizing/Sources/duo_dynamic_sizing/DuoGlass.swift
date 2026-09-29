import Flutter
import UIKit

final class DuoGlassFactory: NSObject, FlutterPlatformViewFactory {
  func create(
    withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?
  ) -> FlutterPlatformView {
    DuoGlassView(args as? [String: Any] ?? [:])
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
}

/// Liquid Glass on iOS 26+, system blur before it. Never takes touches.
final class DuoGlassView: NSObject, FlutterPlatformView {
  private let effectView: UIVisualEffectView

  init(_ args: [String: Any]) {
    let tint = (args["tint"] as? NSNumber).map { n -> UIColor in
      let v = n.uint32Value
      func c(_ shift: UInt32) -> CGFloat { CGFloat((v >> shift) & 0xFF) / 255 }
      return UIColor(red: c(16), green: c(8), blue: c(0), alpha: c(24))
    }
    effectView = UIVisualEffectView(effect: Self.effect(tint))
    effectView.isUserInteractionEnabled = false
    // the Flutter theme, which can differ from the system appearance
    if let dark = args["dark"] as? Bool {
      effectView.overrideUserInterfaceStyle = dark ? .dark : .light
    }
    effectView.layer.cornerRadius = CGFloat((args["radius"] as? NSNumber)?.doubleValue ?? 0)
    effectView.layer.cornerCurve = .continuous
    effectView.clipsToBounds = true
    super.init()
  }

  func view() -> UIView { effectView }

  private static func effect(_ tint: UIColor?) -> UIVisualEffect {
    // UIGlassEffect ships in the iOS 26 SDK, Swift 6.2 is Xcode 26
    #if compiler(>=6.2)
      if #available(iOS 26.0, *) {
        let glass = UIGlassEffect()
        glass.tintColor = tint
        return glass
      }
    #endif
    return UIBlurEffect(style: .systemThinMaterial)
  }
}
