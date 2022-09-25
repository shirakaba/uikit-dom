@objc extension UIEvent: Event {
  var bubbles: Bool {
    <#code#>
  }
  
  var cancelBubble: Bool {
    get {
      <#code#>
    }
    set {
      <#code#>
    }
  }
  
  var cancelable: Bool {
    <#code#>
  }
  
  var composed: Bool {
    <#code#>
  }
  
  var currentTarget: EventTarget? {
    get {
      <#code#>
    }
    set {
      <#code#>
    }
  }
  
  var defaultPrevented: Bool {
    <#code#>
  }
  
  var eventPhase: NSNumber {
    get {
      <#code#>
    }
    set {
      <#code#>
    }
  }
  
  var isTrusted: Bool {
    <#code#>
  }
  
  var returnValue: Bool {
    <#code#>
  }
  
  var srcElement: EventTarget? {
    <#code#>
  }
  
  var target: EventTarget? {
    <#code#>
  }
  
  var timeStamp: NSDate {
    <#code#>
  }
  
  var eventType: NSString {
    <#code#>
  }
  
  func composedPath() -> [EventTarget] {
    guard let target = self.target as? UIResponder else { return [] }
    return getResponderChain(target).reversed()
  }
  
  func initEvent(_ type: NSString, _ bubbles: OptionalBool?, _ cancelable: OptionalBool?) {
    // stub, because it's a deprecated API in the first place.
  }
  
  func preventDefault() {
    <#code#>
  }
  
  func stopImmediatePropagation() {
    <#code#>
  }
  
  func stopPropagation() {
    <#code#>
  }
  
  var propagation: EventPropagation {
    get {
      <#code#>
    }
    set {
      <#code#>
    }
  }
  
  var AT_TARGET: NSNumber {
    return 2
  }
  
  var BUBBLING_PHASE: NSNumber {
    return 3
  }
  
  var CAPTURING_PHASE: NSNumber {
    return 1
  }
  
  var NONE: NSNumber {
    return 0
  }
}
