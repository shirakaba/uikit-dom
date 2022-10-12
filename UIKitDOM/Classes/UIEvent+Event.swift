@objc extension UIEvent: Event {
  @nonobjc private static let bubblesAssociation = ObjectAssociation<NSNumber>()
  var bubblesFlag: NSNumber {
    get { return UIEvent.bubblesAssociation[self] ?? 0 }
    set { UIEvent.bubblesAssociation[self] = newValue }
  }
  public var bubbles: Bool {
    get { return bubblesFlag == 1 }
    set { bubblesFlag = newValue ? 1 : 0 }
  }
  
  @nonobjc private static let cancelBubbleAssociation = ObjectAssociation<NSNumber>()
  var cancelBubbleFlag: NSNumber? {
    get { return UIEvent.cancelBubbleAssociation[self] }
    set { UIEvent.cancelBubbleAssociation[self] = newValue }
  }
  public var cancelBubble: Bool {
    get { return cancelBubbleFlag == 1 }
    set {
      cancelBubbleFlag = newValue ? 1 : 0
      propagation = EventPropagation.stop
    }
  }
  
  @nonobjc private static let cancelableAssociation = ObjectAssociation<NSNumber>()
  var cancelableFlag: NSNumber {
    get { return UIEvent.cancelableAssociation[self] ?? 0 }
    set { UIEvent.cancelableAssociation[self] = newValue }
  }
  public var cancelable: Bool {
    get { return cancelableFlag == 1 }
    set { cancelableFlag = newValue ? 1 : 0 }
  }

  @nonobjc private static let composedAssociation = ObjectAssociation<NSNumber>()
  var composedFlag: NSNumber {
    get { return UIEvent.composedAssociation[self] ?? 0 }
    set { UIEvent.composedAssociation[self] = newValue }
  }
  public var composed: Bool {
    get { return composedFlag == 1 }
    set { composedFlag = newValue ? 1 : 0 }
  }
  
  @nonobjc private static let currentTargetAssociation = ObjectAssociation<EventTarget>()
  var currentTargetFlag: EventTarget? {
    get { return UIEvent.currentTargetAssociation[self] }
    set { UIEvent.currentTargetAssociation[self] = newValue }
  }
  public var currentTarget: EventTarget? {
    get { return currentTargetFlag }
    set { currentTargetFlag = newValue }
  }
  
  @nonobjc private static let defaultPreventedAssociation = ObjectAssociation<NSNumber>()
  var defaultPreventedFlag: NSNumber {
    get { return UIEvent.defaultPreventedAssociation[self] ?? 0 }
    set { UIEvent.defaultPreventedAssociation[self] = newValue }
  }
  public var defaultPrevented: Bool {
    get { return defaultPreventedFlag == 1 }
    set { defaultPreventedFlag = newValue ? 1 : 0 }
  }
  
  @nonobjc private static let eventPhaseAssociation = ObjectAssociation<NSNumber>()
  var eventPhaseFlag: NSNumber {
    get { return UIEvent.eventPhaseAssociation[self] ?? self.NONE }
    set { UIEvent.eventPhaseAssociation[self] = newValue }
  }
  public var eventPhase: NSNumber {
    get { return eventPhaseFlag }
    set { eventPhaseFlag = newValue }
  }
  
  @nonobjc private static let isTrustedAssociation = ObjectAssociation<NSNumber>()
  var isTrustedFlag: NSNumber {
    get { return UIEvent.isTrustedAssociation[self] ?? 1 }
    set { UIEvent.isTrustedAssociation[self] = newValue }
  }
  public var isTrusted: Bool {
    get { return isTrustedFlag == 1 }
    set { isTrustedFlag = newValue ? 1 : 0 }
  }

  // Our implementation is not totally spec-compliant (we don't track a
  // 'canceled' attribute) but it's deprecated anyway.
  @nonobjc private static let returnValueAssociation = ObjectAssociation<NSNumber>()
  var returnValueFlag: NSNumber {
    get { return UIEvent.returnValueAssociation[self] ?? 1 }
    set { UIEvent.returnValueAssociation[self] = newValue }
  }
  public var returnValue: Bool {
    get { return returnValueFlag == 1 }
    set { returnValueFlag = newValue ? 1 : 0 }
  }
  
  @nonobjc private static let srcElementAssociation = ObjectAssociation<EventTarget>()
  var srcElementFlag: EventTarget? {
    get { return UIEvent.srcElementAssociation[self] }
    set { UIEvent.srcElementAssociation[self] = newValue }
  }
  public var srcElement: EventTarget? {
    get { return srcElementFlag }
    set { srcElementFlag = newValue }
  }
  
  @nonobjc private static let targetAssociation = ObjectAssociation<EventTarget>()
  var targetFlag: EventTarget? {
    get { return UIEvent.targetAssociation[self] }
    set { UIEvent.targetAssociation[self] = newValue }
  }
  public var target: EventTarget? {
    get { return targetFlag }
    set { targetFlag = newValue }
  }
  
  @nonobjc private static let timeStampAssociation = ObjectAssociation<NSDate>()
  var timeStampFlag: NSDate? {
    get { return UIEvent.timeStampAssociation[self] }
    set { UIEvent.timeStampAssociation[self] = newValue }
  }
  public var timeStamp: NSDate {
    get { return timeStampFlag ?? NSDate.init(timeIntervalSinceNow: 0) }
    set { timeStampFlag = newValue }
  }
  
  @nonobjc private static let eventTypeAssociation = ObjectAssociation<NSString>()
  var eventTypeFlag: NSString? {
    get { return UIEvent.eventTypeAssociation[self] }
    set { UIEvent.eventTypeAssociation[self] = newValue }
  }
  public var eventType: NSString {
    get { return eventTypeFlag ?? "" }
    set { eventTypeFlag = newValue }
  }
  
  public func composedPath() -> [EventTarget] {
    guard let target = self.target as? UIResponder else { return [] }
    return getResponderChain(target).reversed()
  }
  
  public func initEvent(_ type: NSString, _ bubbles: OptionalBool?, _ cancelable: OptionalBool?) {
    self.eventType = type
    self.bubbles = (bubbles ?? 0) == 1
    self.cancelable = (cancelable ?? 0) == 1
  }
  
  public func preventDefault() {
    defaultPrevented = true
    returnValue = false
    
    if let target = self.target as? UIView {
      let isUserInteractionEnabled = target.isUserInteractionEnabled
      target.isUserInteractionEnabled = false
      target.isUserInteractionEnabled = isUserInteractionEnabled
    }
  }
  
  public func stopImmediatePropagation() {
    propagation = EventPropagation.stopImmediate
  }
  
  public func stopPropagation() {
    propagation = EventPropagation.stop
  }
  
  @nonobjc private static let propagationAssociation = ObjectAssociation<NSNumber>()
  var propagationFlag: NSNumber {
    get { return UIEvent.propagationAssociation[self] ?? NSNumber(value: EventPropagation.resume.rawValue) }
    set { UIEvent.propagationAssociation[self] = newValue }
  }
  public var propagation: EventPropagation {
    get { return EventPropagation(rawValue: propagationFlag.intValue) ?? EventPropagation.resume }
    set { propagationFlag = NSNumber(value: newValue.rawValue) }
  }
  
  public var AT_TARGET: NSNumber {
    return 2
  }
  
  public var BUBBLING_PHASE: NSNumber {
    return 3
  }
  
  public var CAPTURING_PHASE: NSNumber {
    return 1
  }
  
  public var NONE: NSNumber {
    return 0
  }
}
