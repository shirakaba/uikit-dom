@objc protocol EventTarget {
  /**
      Adds a callback for the given Event type and EventListener options.
      - Attention: Does not check equality with previous callbacks added (not possible in Swift/Obj-C).
      - Returns: The id of the added callback (or "0" if no callback was added).
  */
  func addEventListener(_ type: NSString, _ callback: ((_ event: Event) -> Void)?, _ options: AddEventListenerOptions?) -> NSString
  
  func dispatchEvent(_ event: Event)
  
  /**
      Removes the callback for the given id.
  */
  func removeEventListenerById(_ type: NSString, _ id: NSString)
}

@objc protocol EventListenerOptions {
  @objc optional var capture: Bool { get set }
}

@objc protocol AddEventListenerOptions: EventListenerOptions {
  @objc optional var once: Bool { get set }
  
  @objc optional var passive: Bool { get set }
  
  // This is mainly here as a stub; I don't intend to support anything related
  // to AbortController anytime soon.
  @objc optional var signal: AbortSignal { get set }
}
