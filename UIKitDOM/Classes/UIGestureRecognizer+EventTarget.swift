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


// A convenience extension to let me pass blocks as actions.
// https://stackoverflow.com/questions/26223944/uigesturerecognizer-with-closure
extension UIGestureRecognizer {
  typealias Action = ((UIGestureRecognizer) -> ())

  private struct Keys {
    static var actionKey = "ActionKey"
  }

  private var block: Action? {
    set {
      if let newValue = newValue {
        // Computed properties get stored as associated objects
        objc_setAssociatedObject(self, &Keys.actionKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
      }
    }
    get {
       let action = objc_getAssociatedObject(self, &Keys.actionKey) as? Action
       return action
    }
  }

  @objc func handleAction(recognizer: UIGestureRecognizer) {
    block?(recognizer)
  }

  convenience public  init(block: @escaping ((UIGestureRecognizer) -> ())) {
    self.init()
    self.block = block
    self.addTarget(self, action: #selector(handleAction(recognizer:)))
  }
}


extension UIGestureRecognizer {
  func addClosure(_ closure: @escaping()->()) {
    @objc class ClosureSleeve: NSObject {
      let closure:()->()
      init(_ closure: @escaping()->()) { self.closure = closure }
      @objc func invoke() { closure() }
    }
    let sleeve = ClosureSleeve(closure)
    self.addTarget(sleeve, action: #selector(ClosureSleeve.invoke))
    objc_setAssociatedObject(self, "\(UUID())", sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
  }
}
