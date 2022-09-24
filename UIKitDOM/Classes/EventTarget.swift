@objc protocol EventTarget {
  // Unlike DOM, we don't accept a boolean for the options param; the consumer
  // will have to convert any options to AddEventListenerOptions type.
  func addEventListener(_ type: NSString, _ callback: ((_ event: UIEvent) -> Bool)?, _ options: AddEventListenerOptions?)
  
  func dispatchEvent(_ event: UIEvent)
  
  // Unlike DOM, we don't accept a boolean for the options param; the consumer
  // will have to convert any options to AddEventListenerOptions type.
  func removeEventListener(_ type: NSString, _ callback: ((_ event: UIEvent) -> Bool)?, _ options: AddEventListenerOptions?)
}

@objc protocol EventListenerOptions {
  var capture: OptionalBool? { get set }
}

@objc protocol AddEventListenerOptions: EventListenerOptions {
  var once: OptionalBool? { get set }
  
  var passive: OptionalBool? { get set }
  
  // This is mainly here as a stub; I don't intend to support anything related
  // to AbortController anytime soon.
  var signal: AbortSignal? { get set }
}
