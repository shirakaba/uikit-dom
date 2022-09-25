private var eventListenerCount: Int = 0

@objc extension UIResponder: EventTarget {
  @nonobjc private static let listenerMapAssociation = ObjectAssociation<NSMutableDictionary>()
  var listenerMap: NSMutableDictionary {
    get {
      // Lazily initialise.
      if let _listenerMap = UIResponder.listenerMapAssociation[self] {
        return _listenerMap
      }
      
      let _listenerMap = NSMutableDictionary()
      UIResponder.listenerMapAssociation[self] = _listenerMap
      return _listenerMap
    }
    set { UIResponder.listenerMapAssociation[self] = newValue }
  }
  
  public func addEventListener(_ type: NSString, _ callback: ((Event) -> Void)?, _ options: AddEventListenerOptions?) -> NSString {
    guard let callback = callback else { return "0" }
    
    let options = normalizeEventHandlerOptions(options)
    guard !(options.signal?.aborted ?? false) else { return "0" }
    
    // Ideally we'd compare equality with existing callbacks, but that's not
    // possible in Swift.
    let listenersForType: NSMutableDictionary = listenerMap.object(forKey: type) as? NSMutableDictionary ?? NSMutableDictionary()
    
    eventListenerCount += 1;
    let listenerId = String(eventListenerCount) as NSString
    listenersForType.setObject([callback, options], forKey: listenerId)
    listenerMap.setObject(listenersForType, forKey: type)
    
    // TODO: if the event is of type "tap":
    // - let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))
    // - self.isUserInteractionEnabled = true
    // - self.addGestureRecognizer(tapRecognizer)
    // - implement handleTap such that it:
    //   1) calls the callback
    //   2) permits the native behaviour (e.g. updating UISlider) only if
    //      defaultPrevented remains false. This will require reading up on
    //      native behaviour, which I think is only for UIKit controls, but may
    //      also have implications like swiping to pop UIViewControllers from
    //      UINavigationController.
    // We could pass in a closure instead of actioning a selector this way:
    //   https://stackoverflow.com/questions/26223944/uigesturerecognizer-with-closure
    // UIKit control native behaviours:
    // https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/coordinating_multiple_gesture_recognizers/attaching_gesture_recognizers_to_uikit_controls
    // UINavigationController's gesture recognizer:
    // https://developer.apple.com/documentation/uikit/uinavigationcontroller/1621847-interactivepopgesturerecognizer
    
    return listenerId
  }
  
  public func dispatchEvent(_ event: Event) {
    // The chain is ordered from the first-captured responder to this one.
    let chain = getResponderChain(self)
    let eventType = event.eventType
    
    event.isTrusted = false
    
    // Capturing phase: the chain is ordered root -> target.
    event.eventPhase = event.CAPTURING_PHASE
    for responder in chain {
      event.currentTarget = responder
      
      guard let listenersForType = listenerMap.object(forKey: eventType) as? NSMutableDictionary else { continue }
      
      handleEvent(
        listenersForType: listenersForType,
        event: event
      )
      guard event.propagation == EventPropagation.resume else { return }
    }
    
    // Bubbling phase: the (reversed) chain is ordered target -> root.
    // It's correct to dispatch the event to the target during both phases.
    event.eventPhase = event.BUBBLING_PHASE
    for responder in chain.reversed() {
      event.currentTarget = responder
      
      guard let listenersForType = listenerMap.object(forKey: eventType) as? NSMutableDictionary else { continue }
      
      handleEvent(
        listenersForType: listenersForType,
        event: event
      )
      guard event.propagation == EventPropagation.resume else { return }
      
      // If the event doesn't bubble, then we do dispatch it at the target but
      // don't let it propagate further.
      guard event.bubbles else { return }
      
      // Restore event phase in case it changed to AT_TARGET during handleEvent.
      event.eventPhase = event.BUBBLING_PHASE
    }
  }
  
  public func removeEventListenerById(_ type: NSString, _ id: NSString) {
    guard id != "0", let listenersForType: NSMutableDictionary = listenerMap.object(forKey: type) as? NSMutableDictionary else { return }
    listenersForType.removeObject(forKey: id)
    
    if(listenersForType.count == 0){
      listenerMap.removeObject(forKey: type)
    }
  }
}

/**
 Returns the responder chain, ordered from the root (first entry) to the most nested element, AKA "target" (last
 entry). Includes the responder itself as the final element in the array.
 */
func getResponderChain(_ responder: UIResponder) -> [UIResponder] {
  var chain = [responder]
  var nextResponder = responder.next
  while nextResponder != nil {
    chain.insert(nextResponder!, at: 0)
    nextResponder = nextResponder?.next
  }
  return chain
}

func handleEvent(
  listenersForType: NSMutableDictionary,
  event: Event
){
  // Keep track of whether we're bubbling or capturing.
  let initialEventPhase = event.eventPhase
  
  for key in listenersForType.allKeys {
    guard let listenersForTypeValue = listenersForType.object(forKey: key),
          let listenerTuple = listenersForTypeValue as? [AnyObject],
          let callback = listenerTuple[0] as? (Event) -> Void,
          let options = listenerTuple[1] as? AddEventListenerOptions
    else { continue }
    
    if(event.target === event.currentTarget){
      event.eventPhase = event.AT_TARGET
      callback(event)
      if(options.once ?? false){
        listenersForType.removeObject(forKey: key)
      }
      guard event.propagation != EventPropagation.stopImmediate else { return }
    }
    
    if(initialEventPhase == event.CAPTURING_PHASE && !(options.capture ?? false)){
      continue
    }
  }
}

func normalizeEventHandlerOptions(_ options: AddEventListenerOptions?) -> AddEventListenerOptions {
  var returnValue: [String: Any] = [
    "capture": options?.capture ?? false,
    "once": options?.once ?? false,
    "passive": options?.passive ?? false,
  ]
  
  if let signal = options?.signal {
    returnValue["signal"] = signal
  }

  return returnValue as! AddEventListenerOptions;
}
