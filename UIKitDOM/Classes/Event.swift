/**
    - Attention: Readonly properties have been made settable for the sake of the internal
                 implementation. I've also introduced the 'propagation' backing state.
 */
@objc public protocol EventProtocol {
  var bubbles: Bool { get }
  var cancelBubble: Bool { get set }
  var cancelable: Bool { get }
  var composed: Bool { get }
  weak var currentTarget: EventTarget? { get set }
  var defaultPrevented: Bool { get }
  var eventPhase: NSNumber { get set }
  var isTrusted: Bool { get set }
  /** @deprecated */
  var returnValue: Bool  { get }
  /** @deprecated */
  weak var srcElement: EventTarget? { get }
  weak var target: EventTarget? { get set }
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

@objc public enum EventPropagation: Int {
    case resume, stop, stopImmediate
}

@objc public protocol UIEventProtocol: EventProtocol {
  var detail: NSNumber { get }
  weak var view: UIWindow? { get }
  /** @deprecated */
  var which: NSNumber { get }
  /** @deprecated */
  func initUIEvent(_ typeArg: NSString, _ bubblesArg: OptionalBool?, _ cancelableArg: OptionalBool?, _ viewArg: UIWindow?, _ detailArg: NSNumber?)
}

@objc public protocol MouseEventProtocol: UIEventProtocol {
  var altKey: Bool { get }
  var button: NSNumber { get }
  var buttons: NSNumber { get }
  var clientX: NSNumber { get }
  var clientY: NSNumber { get }
  var ctrlKey: Bool { get }
  var metaKey: Bool { get }
  var movementX: NSNumber { get }
  var movementY: NSNumber { get }
  var offsetX: NSNumber { get }
  var offsetY: NSNumber { get }
  var pageX: NSNumber { get }
  var pageY: NSNumber { get }
  weak var relatedTarget: EventTarget? { get }
  var screenX: NSNumber { get }
  var screenY: NSNumber { get }
  var shiftKey: Bool { get }
  var x: NSNumber { get }
  var y: NSNumber { get }
  func getModifierState(keyArg: NSString) -> Bool
  /** @deprecated */
  func initMouseEvent(_ typeArg: NSString, _ canBubbleArg: Bool, _ cancelableArg: Bool, _ viewArg: UIWindow, _ detailArg: NSNumber, _ screenXArg: NSNumber, _ screenYArg: NSNumber, _ clientXArg: NSNumber, _ clientYArg: NSNumber, _ ctrlKeyArg: Bool, _ altKeyArg: Bool, _ shiftKeyArg: Bool, _ metaKeyArg: Bool, _ buttonArg: NSNumber, _ relatedTargetArg: EventTarget?)
}
