private var eventListenerCount: Int = 0
private let recognizedEvents: Set<NSString> = ["tap"]

class CallbackAndOptions: NSObject {
  let callback: (EventProtocol) -> Void
  let options: AddEventListenerOptions
  
  init(callback: @escaping (EventProtocol) -> Void, options: AddEventListenerOptions) {
    self.callback = callback
    self.options = options
  }
}

@objc extension UIResponder: EventTarget, UIGestureRecognizerDelegate {
  @nonobjc private static let listenerMapAssociation = ObjectAssociation<Dictionary<NSString, Dictionary<Int, CallbackAndOptions>>>()
  // {
  //    [eventType: string]: {
  //      [id: number]: CallbackAndOptions;
  //    }
  // }
  var listenerMap: Dictionary<NSString, Dictionary<Int, CallbackAndOptions>> {
    get {
      // Lazily initialise.
      if let _listenerMap = UIResponder.listenerMapAssociation[self] {
        return _listenerMap
      }
      
      let _listenerMap = Dictionary<NSString, Dictionary<Int, CallbackAndOptions>>()
      UIResponder.listenerMapAssociation[self] = _listenerMap
      return _listenerMap
    }
    set { UIResponder.listenerMapAssociation[self] = newValue }
  }
  
  public func addEventListener(
    _ type: NSString,
    _ callback: ((EventProtocol) -> Void)? = nil,
    _ options: AddEventListenerOptions? = nil
  ) -> NSNumber {
    guard let callback = callback else { return 0 }
    let options = options ?? AddEventListenerOptions()
    guard !(options.signal?.aborted ?? false) else { return 0 }
    
    // Ideally we'd compare equality with existing callbacks, but that's not
    // possible in Swift.
    var listenersForType: Dictionary<Int, CallbackAndOptions> = listenerMap[type] ?? Dictionary()
    
    eventListenerCount += 1;
    let listenerId = eventListenerCount
    listenersForType.updateValue(CallbackAndOptions(callback: callback, options: options), forKey: listenerId)
    listenerMap.updateValue(listenersForType, forKey: type)
    
    self.listenForNativeEvent(type: type)
    
    // TODO: if the event is of type "tap":
    // - let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:_:))
    // - self.isUserInteractionEnabled = true
    // - self.addGestureRecognizer(tapRecognizer)
    // - implement handleTap(sender: UIButton, forEvent event: UIEvent) such that it:
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
    
    // Upon addEventListener, we could call
    // self.addGestureRecognizer(tapRecognizer) and the handleTap() action could
    // simply call dispatchEvent of a UIEvent with any extra info on it. That
    // extra info could include the default native callback to be called.
    //
    // See also "you can intercept incoming events by subclassing UIApplication
    // and overriding this method." on the UIApplication.sendEvent() docs:
    // https://developer.apple.com/documentation/uikit/uiapplication/1623043-sendevent
    
    // A gesture recognizer operates on touches hit-tested to a specific view
    // and all of that view’s subviews. It thus must be associated with that
    // view. To make that association you must call the UIView method
    // addGestureRecognizer(_:). A gesture recognizer doesn’t participate in the
    // view’s responder chain.
    // https://developer.apple.com/documentation/uikit/uigesturerecognizer
    
    return listenerId as NSNumber
  }
  
  func listenForNativeEvent(type: NSString, callback: ((EventProtocol) -> Void)? = nil){
    guard let self = self as? UIView else { return }
    
    if(type == "tap" || type == "doubletap"){
//      self.onTap = ClosureSleeve(callback)
      let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
      
//      UITapGestureRecognizer(target: self, { recognizer in
//        print("Hallo")
//      }
      
      tapRecognizer.delegate = self
      tapRecognizer.numberOfTapsRequired = type == "doubletap" ? 2 : 1
      self.addGestureRecognizer(tapRecognizer)
      
//      tapRecognizer.cancelsTouchesInView = false
//      self.isUserInteractionEnabled = true
      // self.addGestur
      // self.addGestureRecognizer(tapRecognizer)
      return
    }
    
//    if(type == "pan"){
//      let recognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:))
//    }
  }
  
  @objc func handleTap(_ sender: UITapGestureRecognizer){
    // It's possible that self is not the UIView that the original
    // UITouchesEvent event was sent to - if
    
    // might merely have caught the event after it bubbled up from that target.
    
    print("[\(String(describing: type(of: self)))] HANDLE TAP. self is UIScrollView: \(self is UIScrollView)")
    guard let self = self as? UIView else { return }
    guard let window = self.window else { return }
    
    var touches: [CGPoint] = []
    for i in 0..<sender.numberOfTouches {
      touches.append(sender.location(ofTouch: i, in: self))
    }
    
    // We're too late to get the UITouchesEvent, I think.
    
    let locationInWindow = sender.location(ofTouch: 0, in: window)
    let locationInSelf = sender.location(ofTouch: 0, in: self)
    let event = MouseEvent("tap", true, true, window, 0, locationInWindow.x as NSNumber, locationInWindow.y as NSNumber, locationInSelf.x as NSNumber, locationInSelf.y as NSNumber, false, false, false, false, 0, nil)
    
    self.dispatchEvent(event)
  }
  
//  @nonobjc private static let onTapAssociation = ObjectAssociation<ClosureSleeve>()
//  var onTapBackingVar: ClosureSleeve? {
//    get { return UIResponder.onTapAssociation[self] }
//    set { UIResponder.onTapAssociation[self] = newValue }
//  }
//  public var onTap: ClosureSleeve? {
//    get { return onTapBackingVar }
//    set { onTapBackingVar = newValue }
//  }
  
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
//  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//    print("gestureRecognizer(\(NSStringFromClass(type(of: gestureRecognizer.view!))), shouldRequireFailureOf: \(NSStringFromClass(type(of: otherGestureRecognizer.view!))))")
//
//    // Requires that this gesturesRecognizer will only take a look if the other
//    // gestureRecognizer closer to the root already failed. This would allow us
//    // to let capturing listeners see the event first.
//    var nextResponder = self.next
//    while nextResponder != nil {
//      if(otherGestureRecognizer.view === nextResponder){
//        return true
//      }
//      nextResponder = nextResponder?.next
//    }
//
//    return false
//  }
  
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive event: UIEvent) -> Bool {
    // The current problem is that we never call the user's UIEvent -> ()
    // closure because there is no obvious delegate method that passes us the
    // UIEvent involved with the gesture.
    if(event.defaultPrevented){
      print("Blocking UIEvent from reaching gestureRecognizer, as it had defaultPrevented.")
      return false
    }
    return true
  }
  
//  public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//
//    return true
//  }
                                              
//  @objc func handlePan(_ sender: UITapGestureRecognizer){
//    guard let self = self as? UIView else { return }
//  }

  public func dispatchEvent(_ event: EventProtocol) {
    event.target = self
    // The chain is ordered from the first-captured responder to this one.
    let chain = getResponderChain(self)
    let eventType = event.eventType
    
    event.isTrusted = false
    
    // Capturing phase: the chain is ordered root -> target.
    event.eventPhase = event.CAPTURING_PHASE
    for responder in chain {
      event.currentTarget = responder
      
      guard var listenersForType = listenerMap[eventType] else { continue }
      
      handleEvent(
        listenersForType: &listenersForType,
        event: event
      )
      
      // In case we handled a "once" event, depleting this type's listeners.
      if(listenersForType.count == 0){
        listenerMap.removeValue(forKey: eventType)
      }
      
      guard event.propagation == EventPropagation.resume else { return }
    }
    
    // Bubbling phase: the (reversed) chain is ordered target -> root.
    // It's correct to dispatch the event to the target during both phases.
    event.eventPhase = event.BUBBLING_PHASE
    for responder in chain.reversed() {
      event.currentTarget = responder
      
      // FIXME: seems like listenersForType is populated on every responder in
      // the chain.
      guard var listenersForType = listenerMap[eventType] else { continue }
      
      handleEvent(
        listenersForType: &listenersForType,
        event: event
      )
      
      // In case we handled a "once" event, depleting this type's listeners.
      if(listenersForType.count == 0){
        listenerMap.removeValue(forKey: eventType)
      }
      
      guard event.propagation == EventPropagation.resume else { return }
      
      // If the event doesn't bubble, then we do dispatch it at the target but
      // don't let it propagate further.
      guard event.bubbles else { return }
      
      // Restore event phase in case it changed to AT_TARGET during handleEvent.
      event.eventPhase = event.BUBBLING_PHASE
    }
  }
  
  public func removeEventListenerById(_ type: NSString, _ id: NSNumber) {
    guard id != 0, var listenersForType: Dictionary<Int, CallbackAndOptions> = listenerMap[type] else { return }
    listenersForType.removeValue(forKey: Int(id.intValue))
    
    if(listenersForType.count == 0){
      listenerMap.removeValue(forKey: type)
    }
  }
}

/**
 Returns the responder chain, ordered from the root (first entry) to the most nested element, AKA "target" (last
 entry). Includes the responder itself as the final element in the array.
 - Example: [UIWindow, UITransitionView, UIDropShadowView, UIView, UIScrollView]
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

private func handleEvent(
  listenersForType: inout Dictionary<Int, CallbackAndOptions>,
  event: EventProtocol
){
  // Keep track of whether we're bubbling or capturing.
  let initialEventPhase = event.eventPhase
  
  for key in listenersForType.keys {
    guard let callbackAndOptions = listenersForType[key] else { continue }
    let callback = callbackAndOptions.callback
    let options = callbackAndOptions.options
    
    if(event.target === event.currentTarget){
      event.eventPhase = event.AT_TARGET
    }
    
    callback(event)
    if(options.once){
      listenersForType.removeValue(forKey: key)
    }
    guard event.propagation != EventPropagation.stopImmediate else { return }
    
    if(initialEventPhase == event.CAPTURING_PHASE && !options.capture){
      continue
    }
  }
}
