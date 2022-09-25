@objc extension UIEvent: Event {
  @nonobjc private static let bubblesAssociation = ObjectAssociation<NSNumber>()
  var bubblesFlag: NSNumber? {
    get { return UIEvent.bubblesAssociation[self] }
    set { UIEvent.bubblesAssociation[self] = newValue }
  }
  var bubbles: Bool {
    get { return bubblesFlag == 1 }
    set { bubblesFlag = newValue ? 1 : 0 }
  }
  
  @nonobjc private static let cancelBubbleAssociation = ObjectAssociation<NSNumber>()
  var cancelBubbleFlag: NSNumber? {
    get { return UIEvent.cancelBubbleAssociation[self] }
    set { UIEvent.cancelBubbleAssociation[self] = newValue }
  }
  var cancelBubble: Bool {
    get { return cancelBubbleFlag == 1 }
    set { cancelBubbleFlag = newValue ? 1 : 0 }
  }
  
  @nonobjc private static let cancelableAssociation = ObjectAssociation<NSNumber>()
  var cancelableFlag: NSNumber? {
    get { return UIEvent.cancelableAssociation[self] }
    set { UIEvent.cancelableAssociation[self] = newValue }
  }
  var cancelable: Bool {
    get { return cancelableFlag == 1 }
    set { cancelableFlag = newValue ? 1 : 0 }
  }

  @nonobjc private static let composedAssociation = ObjectAssociation<NSNumber>()
  var composedFlag: NSNumber? {
    get { return UIEvent.composedAssociation[self] }
    set { UIEvent.composedAssociation[self] = newValue }
  }
  var composed: Bool {
    get { return composedFlag == 1 }
    set { composedFlag = newValue ? 1 : 0 }
  }
  
  @nonobjc private static let currentTargetAssociation = ObjectAssociation<EventTarget>()
  var currentTargetFlag: EventTarget? {
    get { return UIEvent.currentTargetAssociation[self] }
    set { UIEvent.currentTargetAssociation[self] = newValue }
  }
  var currentTarget: EventTarget? {
    get { return currentTargetFlag }
    set { currentTargetFlag = newValue }
  }
  
  @nonobjc private static let defaultPreventedAssociation = ObjectAssociation<NSNumber>()
  var defaultPreventedFlag: NSNumber? {
    get { return UIEvent.defaultPreventedAssociation[self] }
    set { UIEvent.defaultPreventedAssociation[self] = newValue }
  }
  var defaultPrevented: Bool {
    get { return defaultPreventedFlag == 1 }
    set { defaultPreventedFlag = newValue ? 1 : 0 }
  }
  
  @nonobjc private static let eventPhaseAssociation = ObjectAssociation<NSNumber>()
  var eventPhaseFlag: NSNumber? {
    get { return UIEvent.eventPhaseAssociation[self] }
    set { UIEvent.eventPhaseAssociation[self] = newValue }
  }
  var eventPhase: NSNumber {
    get { return eventPhaseFlag ?? self.NONE }
    set { eventPhaseFlag = newValue }
  }
  
  @nonobjc private static let isTrustedAssociation = ObjectAssociation<NSNumber>()
  var isTrustedFlag: NSNumber? {
    get { return UIEvent.isTrustedAssociation[self] }
    set { UIEvent.isTrustedAssociation[self] = newValue }
  }
  var isTrusted: Bool {
    get { return isTrustedFlag == 1 }
    set { isTrustedFlag = newValue ? 1 : 0 }
  }

  @nonobjc private static let returnValueAssociation = ObjectAssociation<NSNumber>()
  var returnValueFlag: NSNumber? {
    get { return UIEvent.returnValueAssociation[self] }
    set { UIEvent.returnValueAssociation[self] = newValue }
  }
  var returnValue: Bool {
    get { return returnValueFlag == 1 }
    set { returnValueFlag = newValue ? 1 : 0 }
  }
  
  @nonobjc private static let srcElementAssociation = ObjectAssociation<EventTarget>()
  var srcElementFlag: EventTarget? {
    get { return UIEvent.srcElementAssociation[self] }
    set { UIEvent.srcElementAssociation[self] = newValue }
  }
  var srcElement: EventTarget? {
    get { return srcElementFlag }
    set { srcElementFlag = newValue }
  }
  
  @nonobjc private static let targetAssociation = ObjectAssociation<EventTarget>()
  var targetFlag: EventTarget? {
    get { return UIEvent.targetAssociation[self] }
    set { UIEvent.targetAssociation[self] = newValue }
  }
  var target: EventTarget? {
    get { return targetFlag }
    set { targetFlag = newValue }
  }
  
  @nonobjc private static let timeStampAssociation = ObjectAssociation<NSDate>()
  var timeStampFlag: NSDate? {
    get { return UIEvent.timeStampAssociation[self] }
    set { UIEvent.timeStampAssociation[self] = newValue }
  }
  var timeStamp: NSDate {
    get { return timeStampFlag ?? NSDate.init(timeIntervalSinceNow: 0) }
    set { timeStampFlag = newValue }
  }
  
  @nonobjc private static let eventTypeAssociation = ObjectAssociation<NSString>()
  var eventTypeFlag: NSString? {
    get { return UIEvent.eventTypeAssociation[self] }
    set { UIEvent.eventTypeAssociation[self] = newValue }
  }
  var eventType: NSString {
    get { return eventTypeFlag ?? "" }
    set { eventTypeFlag = newValue }
  }
  
  func composedPath() -> [EventTarget] {
    guard let target = self.target as? UIResponder else { return [] }
    return getResponderChain(target).reversed()
  }
  
  func initEvent(_ type: NSString, _ bubbles: OptionalBool?, _ cancelable: OptionalBool?) {
    // stub, because it's a deprecated API in the first place.
  }
  
  func preventDefault() {
    defaultPrevented = true
  }
  
  func stopImmediatePropagation() {
    propagation = EventPropagation.stopImmediate
  }
  
  func stopPropagation() {
    propagation = EventPropagation.stop
  }
  
  @nonobjc private static let propagationAssociation = ObjectAssociation<NSNumber>()
  var propagationFlag: NSNumber? {
    get { return UIEvent.propagationAssociation[self] }
    set { UIEvent.propagationAssociation[self] = newValue }
  }
  var propagation: EventPropagation {
    get { return EventPropagation(rawValue: propagationFlag?.intValue ?? 0) ?? EventPropagation.resume }
    set { propagationFlag = NSNumber(value: newValue.rawValue) }
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
