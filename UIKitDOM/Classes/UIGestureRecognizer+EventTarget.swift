// UIResponder already implements the EventTarget protocol, so this extension is
// all about trying to get event capturing to work.

private let swizzle: (AnyClass, Selector, Selector) -> () = { forClass, originalSelector, swizzledSelector in
    guard
        let originalMethod = class_getInstanceMethod(forClass, originalSelector),
        let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)
    else { return }
    method_exchangeImplementations(originalMethod, swizzledMethod)
}

extension UIGestureRecognizer {
  public static let swizzleDOM: Void = {
    swizzle(UIGestureRecognizer.self, #selector(UIGestureRecognizer.require(toFail:)), #selector(UIGestureRecognizer.swizzled_require(toFail:)))
  }()
  
  @objc func swizzled_require(toFail otherGestureRecognizer: UIGestureRecognizer) {
    
    return swizzled_require(toFail: otherGestureRecognizer)
  }
}
