/**
    - Attention: Readonly properties have been made settable for the sake of the internal
                 implementation. I've also introduced the 'propagation' backing state.
 */
@objc protocol Event {
  var bubbles: Bool { get }
  var cancelBubble: Bool { get set }
  var cancelable: Bool { get }
  var composed: Bool { get }
  var currentTarget: EventTarget? { get set }
  var defaultPrevented: Bool { get }
  var eventPhase: NSNumber { get set }
  var isTrusted: Bool { get set }
  /** @deprecated */
  var returnValue: Bool  { get }
  /** @deprecated */
  var srcElement: EventTarget? { get }
  var target: EventTarget? { get }
  var timeStamp: NSDate { get }
  /**
      - Attention: Renamed from type to "type" to "eventType" to avoid nameclash with existing Obj-C property.
   */
  var eventType: NSString { get }
  func composedPath() -> [EventTarget]
  /** @deprecated */
  func initEvent(_ type: NSString, _ bubbles: OptionalBool?, _ cancelable: OptionalBool?)
  func preventDefault()
  func stopImmediatePropagation()
  func stopPropagation()
  var propagation: EventPropagation { get set }
  var AT_TARGET: NSNumber { get }
  var BUBBLING_PHASE: NSNumber { get }
  var CAPTURING_PHASE: NSNumber { get }
  var NONE: NSNumber { get }
}

@objc enum EventPropagation: Int {
    case resume, stop, stopImmediate
}
