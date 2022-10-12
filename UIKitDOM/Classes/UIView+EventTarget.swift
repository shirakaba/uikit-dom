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
    swizzle(UIView.self, #selector(UIView.point(inside:with:)), #selector(UIView.swizzled_point(inside:with:)))
  }()
  
  public static let lastHitMap: NSMapTable<UIEvent, UIView> = NSMapTable.weakToWeakObjects()
  
  @objc func swizzled_point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    let result = swizzled_point(inside: point, with: event)
    
    if let event = event {
      // If the hit test succeeded, then keep a record of this view as being the
      // last-hit UIView that UIKit was traversing past with this event. We can
      // then ascertain what the target for the event is without access to private
      // APIs.
      if(result){
        UIView.lastHitMap.setObject(self, forKey: event)
      }
    }
    
    print("[\(String(describing: type(of: self))):\(result)] swizzled_point(inside:point, with:\(String(describing: event).replacingOccurrences(of: "\n", with: "")))")
    return result
  }
}
