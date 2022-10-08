// UIResponder already implements the EventTarget protocol, so this extension is
// all about trying to get event capturing to work.

private let swizzle: (AnyClass, Selector, Selector) -> () = { forClass, originalSelector, swizzledSelector in
    guard
        let originalMethod = class_getInstanceMethod(forClass, originalSelector),
        let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)
    else { return }
    method_exchangeImplementations(originalMethod, swizzledMethod)
}

extension UIView {
  public static let swizzleDOM: Void = {
    // If we want to make sure this isn't a subclass
    // guard self === UIView.self else { return }
    let originalSelector = #selector(UIView.point(inside:with:))
    let swizzledSelector = #selector(UIView.swizzled_point(inside:with:))
    swizzle(UIView.self, originalSelector, swizzledSelector)
  }()
  
  @objc func swizzled_point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    print("[\(String(describing: type(of: self)))] swizzled_point(inside:point, with:\(String(describing: event).replacingOccurrences(of: "\n", with: "")))")
    // return false
    return swizzled_point(inside: point, with: event)
  }
}
