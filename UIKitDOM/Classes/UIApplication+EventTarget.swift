// UIResponder already implements the EventTarget protocol, so this extension is
// all about trying to get event capturing to work.

private let swizzle: (AnyClass, Selector, Selector) -> () = { forClass, originalSelector, swizzledSelector in
    guard
        let originalMethod = class_getInstanceMethod(forClass, originalSelector),
        let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)
    else { return }
    method_exchangeImplementations(originalMethod, swizzledMethod)
}

extension UIApplication {
  public static let swizzleDOM: Void = {
    swizzle(UIApplication.self, #selector(UIApplication.sendEvent(_:)), #selector(UIApplication.swizzled_sendEvent(_:)))
    swizzle(UIApplication.self, #selector(UIApplication.sendAction(_:to:from:for:)), #selector(UIApplication.swizzled_sendAction(_:to:from:for:)))
    
    // #selector(UIApplication.sendGesturesForEvent)
  }()
  
  @objc func swizzled_sendEvent(_ event: UIEvent) {
//    if (self is UIWindow){
//      return swizzled_point(inside: point, with: event)
//    }
    
    // I'm guessing that this will be sent to the last UIView that responded `true` for point(inside:with:).
    // We could track assumedFirstResponder as a weak ref to the latest UIView to respond true.
    // We might clear it each time the root (UIWindow? AppDelegate?) ended up calling point(inside:with:).
    
    if let lastHitView = UIView.lastHitMap.object(forKey: event) {
      event.target = lastHitView
      print("[\(String(describing: type(of: self)))] swizzled_sendEvent(\(String(describing: event).replacingOccurrences(of: "\n", with: ""))) lastHitView: \(String(describing: type(of: lastHitView)))")
    }
  
    return swizzled_sendEvent(event)
  }
  
  @objc func swizzled_sendAction(
    _ action: Selector,
    to target: Any?,
    from sender: Any?,
    for event: UIEvent?
  ) -> Bool {
    let responderChain = getResponderChain(self).map { String(describing: type(of: $0)) }
    print("[\(String(describing: type(of: self)))] swizzled_sendEvent(\(String(describing: event).replacingOccurrences(of: "\n", with: ""))) responderChain: \(responderChain)")
    let result = swizzled_sendAction(action, to: target, from: sender, for: event)
    return result
  }
}
