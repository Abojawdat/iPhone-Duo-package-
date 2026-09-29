import Flutter
import ObjectiveC
import UIKit

/// Streams the iPhone Duo hinge, reserved regions, size classes and vertical
/// bar edge to Dart. iOS 27.1 types are looked up at runtime so any Xcode
/// builds this and older systems just report nothing.
public final class DuoDynamicSizingPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var sink: FlutterEventSink?
  private var probe: DuoProbe?
  private var interaction: NSObject?
  private var hasHinge: Bool?
  private var status = 0
  private var angle: Double?
  private var last: NSDictionary?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let plugin = DuoDynamicSizingPlugin()
    registrar.addMethodCallDelegate(
      plugin,
      channel: FlutterMethodChannel(
        name: "duo_dynamic_sizing", binaryMessenger: registrar.messenger()))
    FlutterEventChannel(
      name: "duo_dynamic_sizing/events", binaryMessenger: registrar.messenger()
    ).setStreamHandler(plugin)
    registrar.register(DuoGlassFactory(), withId: "duo_dynamic_sizing/glass")
    NotificationCenter.default.addObserver(
      plugin, selector: #selector(attach), name: UIWindow.didBecomeKeyNotification,
      object: nil)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "snapshot":
      attach()
      result(snapshot())
    case "describe":
      result(DuoRuntime.describe())
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func onListen(
    withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    sink = events
    last = nil
    attach()
    emit()
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    sink = nil
    return nil
  }

  // a clear probe over the Flutter view: its space is Flutter's, and its
  // layout pass is the only signal that regions moved
  @objc private func attach() {
    if probe?.window != nil { return }
    guard let host = Self.flutterView() else { return }
    probe?.removeFromSuperview()
    let probe = DuoProbe(frame: host.bounds)
    probe.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    probe.isUserInteractionEnabled = false
    probe.onChange = { [weak self] in self?.emit() }
    host.addSubview(probe)
    self.probe = probe
    interaction = DuoRuntime.addHinge(to: probe) { [weak self] hinge in
      self?.update(hinge)
    }
  }

  private func update(_ hinge: NSObject?) {
    hasHinge = hinge != nil
    let raw = hinge.flatMap { DuoRuntime.number($0, "status")?.intValue } ?? 0
    status = (0...3).contains(raw) ? raw : 0
    angle = hinge.flatMap { DuoRuntime.number($0, "angle") }.map {
      min(max($0.doubleValue * 180 / .pi, 0), 180)
    }
    emit()
  }

  private func emit() {
    guard let sink = sink else { return }
    let map = snapshot() as NSDictionary
    if map == last { return }
    last = map
    sink(map)
  }

  private func snapshot() -> [String: Any] {
    var map: [String: Any] = ["supported": DuoRuntime.hingeAvailable, "status": status]
    if let hasHinge = hasHinge { map["hinge"] = hasHinge }
    if let angle = angle { map["angle"] = angle }
    guard let probe = probe else { return map }
    let traits = probe.traitCollection
    map["hSize"] = traits.horizontalSizeClass.rawValue
    map["vSize"] = traits.verticalSizeClass.rawValue
    map["bar"] = Self.barSide(probe)
    // read during layout so UIKit reruns layout when they change
    map["regions"] = DuoRuntime.regions(in: probe)
    return map
  }

  // UIVerticalBarEdge is leading 1 / trailing 2, sent as physical left 1 / right 2
  private static func barSide(_ view: UIView) -> Int {
    guard let edge = DuoRuntime.number(view.traitCollection, "verticalBarEdge")?.intValue,
      edge == 1 || edge == 2
    else { return 0 }
    let rtl = view.effectiveUserInterfaceLayoutDirection == .rightToLeft
    return (edge == 2) != rtl ? 2 : 1
  }

  private static func flutterView() -> UIView? {
    let windows = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .sorted { $0.isKeyWindow && !$1.isKeyWindow }
    for window in windows {
      if let root = window.rootViewController, let view = find(in: root) { return view }
    }
    return nil
  }

  private static func find(in controller: UIViewController) -> UIView? {
    if let flutter = controller as? FlutterViewController { return flutter.viewIfLoaded }
    for child in controller.children {
      if let view = find(in: child) { return view }
    }
    return controller.presentedViewController.flatMap { find(in: $0) }
  }
}

final class DuoProbe: UIView {
  var onChange: (() -> Void)?

  override func layoutSubviews() {
    super.layoutSubviews()
    onChange?()
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()
    onChange?()
  }

  override func safeAreaInsetsDidChange() {
    super.safeAreaInsetsDidChange()
    onChange?()
  }

  override func traitCollectionDidChange(_ previous: UITraitCollection?) {
    super.traitCollectionDidChange(previous)
    onChange?()
  }
}

/// Every lookup is guarded, a missing or reshaped API turns the feature off
/// instead of crashing.
enum DuoRuntime {
  private typealias RegionsIMP =
    @convention(c) (AnyObject, Selector, AnyObject, UInt) -> Unmanaged<NSArray>?

  static var hingeAvailable: Bool {
    NSClassFromString("UIHingeInteraction")?
      .instancesRespond(to: NSSelectorFromString("initWithUpdateHandler:")) ?? false
  }

  // KVC on a missing key raises, which Swift cant catch
  static func number(_ object: NSObject, _ key: String) -> NSNumber? {
    guard object.responds(to: NSSelectorFromString(key)) else { return nil }
    return object.value(forKey: key) as? NSNumber
  }

  static func addHinge(to view: UIView, onUpdate: @escaping (NSObject?) -> Void) -> NSObject? {
    guard hingeAvailable, let cls = NSClassFromString("UIHingeInteraction") else { return nil }
    let handler: @convention(block) (AnyObject?, AnyObject?) -> Void = { _, update in
      // nil hinge: no hinge here, or the view left a hinged hierarchy
      guard let update = update as? NSObject,
        update.responds(to: NSSelectorFromString("hinge"))
      else { return onUpdate(nil) }
      onUpdate(update.value(forKey: "hinge") as? NSObject)
    }
    // init and new are unavailable, only initWithUpdateHandler: works. alloc
    // hands its +1 to init, which returns +1 of its own
    guard
      let raw = (cls as AnyObject).perform(NSSelectorFromString("alloc"))?
        .takeUnretainedValue() as? NSObject,
      let made = raw.perform(
        NSSelectorFromString("initWithUpdateHandler:"), with: handler as AnyObject)?
        .takeRetainedValue() as? NSObject,
      let interaction = made as? UIInteraction
    else { return nil }
    view.addInteraction(interaction)
    return made
  }

  static func regions(in view: UIView) -> [[String: Any]] {
    let selector = NSSelectorFromString("reservedRegionsOfKind:options:")
    guard view.responds(to: selector),
      let imp = class_getMethodImplementation(type(of: view), selector)
    else { return [] }
    // options is a scalar NSUInteger, so perform(_:with:with:) cant pass it
    let call = unsafeBitCast(imp, to: RegionsIMP.self)
    var out: [[String: Any]] = []
    // the fold is inactive while flat but its place still matters, cameras
    // only while in use
    let kinds: [(String, String, UInt)] = [
      ("divisionRegionKind", "division", 1), ("occlusionRegionKind", "occlusion", 0),
    ]
    for (selectorName, label, options) in kinds {
      guard let kind = classValue("UIViewReservedRegionKind", selectorName),
        let regions = call(view, selector, kind, options)?.takeUnretainedValue()
          as? [NSObject]
      else { continue }
      for region in regions {
        guard let frame = boxed(region, "frame")?.cgRectValue else { continue }
        let margins = boxed(region, "margins")?.uiEdgeInsetsValue ?? .zero
        out.append([
          "kind": label,
          "x": Double(frame.minX), "y": Double(frame.minY),
          "w": Double(frame.width), "h": Double(frame.height),
          "ml": Double(margins.left), "mt": Double(margins.top),
          "mr": Double(margins.right), "mb": Double(margins.bottom),
          "active": number(region, "isActive")?.boolValue ?? true,
        ])
      }
    }
    return out
  }

  private static func boxed(_ object: NSObject, _ key: String) -> NSValue? {
    guard object.responds(to: NSSelectorFromString(key)) else { return nil }
    return object.value(forKey: key) as? NSValue
  }

  private static func classValue(_ className: String, _ selectorName: String) -> AnyObject? {
    let selector = NSSelectorFromString(selectorName)
    guard let cls = NSClassFromString(className) as AnyObject?, cls.responds(to: selector)
    else { return nil }
    return cls.perform(selector)?.takeUnretainedValue()
  }

  static func describe() -> String {
    var lines = [
      "iOS \(UIDevice.current.systemVersion)",
      "hinge interaction: \(hingeAvailable)",
      "reserved regions: \(UIView.instancesRespond(to: NSSelectorFromString("reservedRegionsOfKind:options:")))",
      "vertical bar edge: \(UITraitCollection.instancesRespond(to: NSSelectorFromString("verticalBarEdge")))",
    ]
    for name in [
      "UIHingeInteraction", "UIHingeInteractionUpdate", "UIHinge", "UIViewReservedRegion",
      "UIViewReservedRegionKind",
    ] {
      guard let cls = NSClassFromString(name) else {
        lines.append("\(name): missing")
        continue
      }
      let statics = object_getClass(cls).map { members($0).map { "+" + $0 } } ?? []
      lines.append("\(name): " + (statics + members(cls)).joined(separator: " "))
    }
    return lines.joined(separator: "\n")
  }

  private static func members(_ cls: AnyClass) -> [String] {
    var count: UInt32 = 0
    guard let list = class_copyMethodList(cls, &count) else { return [] }
    defer { free(list) }
    return (0..<Int(count))
      .map { NSStringFromSelector(method_getName(list[$0])) }
      .filter { !$0.hasPrefix("_") && !$0.hasPrefix(".") }
      .sorted()
  }
}
