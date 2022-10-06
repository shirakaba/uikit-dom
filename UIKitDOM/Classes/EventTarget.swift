@objc public protocol EventTarget {
  /**
      Adds a callback for the given Event type and EventListener options.
      - Attention: Does not check equality with previous callbacks added (not possible in Swift/Obj-C).
      - Returns: The id of the added callback (or "0" if no callback was added).
  */
  func addEventListener(_ type: NSString, _ callback: ((_ event: Event) -> Void)?, _ options: AddEventListenerOptions?) -> NSString
  
  func dispatchEvent(_ event: Event)
  
  /**
      Removes the callback for the given id (as Swift/Obj-C cannot compare equality of closures).
  */
  func removeEventListenerById(_ type: NSString, _ id: NSString)
}

@objc public class AddEventListenerOptions: NSObject {
  // Default false
  public var capture: Bool
  // Default false
  public var once: Bool
  // Default false
  public var passive: Bool
  // Default nil
  public var signal: AbortSignal?
  
  // As there is no optional Bool in Obj-C, we represent it using an optional NSNumber (true: 1, false: all other values)
  @objc public init(capture: NSNumber? = nil, once: NSNumber? = nil, passive: NSNumber? = nil, signal: AbortSignal? = nil) {
    self.capture = capture?.intValue == 1
    self.once = once?.intValue == 1
    self.passive = passive?.intValue == 1
    self.signal = signal
  }
}
