@objc extension UIResponder: EventTarget {
  private static var eventListenerCount: Int = 0;
  
  @nonobjc private static let association = ObjectAssociation<NSMutableDictionary>()
  var listenerMap: NSMutableDictionary? {
    get { return UIResponder.association[self] }
    set { UIResponder.association[self] = newValue }
  }
  
  func addEventListener(_ type: NSString, _ callback: ((Event) -> Void)?, _ options: AddEventListenerOptions?) -> NSString {
    guard let callback = callback,
          let listenerMap = self.listenerMap else { return "0" }
    
    let options = normalizeEventHandlerOptions(options)
    guard !(options.signal?.aborted ?? false) else { return "0" }
    
    // Ideally we'd compare equality with existing callbacks, but that's not
    // possible in Swift.
    let listenersForType: NSMutableDictionary = listenerMap.object(forKey: type) as? NSMutableDictionary ?? NSMutableDictionary()
    
    UIResponder.eventListenerCount += 1;
    let listenerId = String(UIView.eventListenerCount) as NSString
    listenersForType.setObject([callback, options], forKey: listenerId)
    listenerMap.setObject(listenersForType, forKey: type)
    
    return listenerId
  }
  
  func dispatchEvent(_ event: Event) {
    // The chain is ordered from the first-captured responder to this one.
    let chain = getResponderChain(self)
    let eventType = event.eventType
    event.isTrusted = false
    
    // Capturing phase: the chain is ordered root -> target.
    event.eventPhase = event.CAPTURING_PHASE
    for responder in chain {
      event.currentTarget = responder
      
      guard let listenerMap = responder.listenerMap,
            let listenersForType = listenerMap.object(forKey: eventType) as? NSMutableDictionary else { continue }
      
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
      
      guard let listenerMap = responder.listenerMap,
            let listenersForType = listenerMap.object(forKey: eventType) as? NSMutableDictionary else { continue }
      
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
  
  func removeEventListenerById(_ type: NSString, _ id: NSString) {
    guard id != "0",
          let listenerMap = self.listenerMap,
          let listenersForType: NSMutableDictionary = listenerMap.object(forKey: type) as? NSMutableDictionary else { return }
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
