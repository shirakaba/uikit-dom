@objc extension UIResponder: EventTarget {
  private static var eventListenerCount: Int = 0;
  
  @nonobjc private static let association = ObjectAssociation<NSMutableDictionary>()
  var listenerMap: NSMutableDictionary? {
    get { return UIResponder.association[self] }
    set { UIResponder.association[self] = newValue }
  }
  
  func addEventListener(_ type: NSString, _ callback: ((UIEvent) -> Void)?, _ options: AddEventListenerOptions?) -> NSString {
    guard let callback = callback, let listenerMap = self.listenerMap else { return "0" }
    
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
  
  func dispatchEvent(_ event: UIEvent) {
    // TODO
  }
  
  func removeEventListenerById(_ type: NSString, _ id: NSString) {
    guard id != "0", let listenerMap = self.listenerMap, let listenersForType: NSMutableDictionary = listenerMap.object(forKey: type) as? NSMutableDictionary else { return }
    listenersForType.removeObject(forKey: id)
    
    if(listenersForType.count == 0){
      listenerMap.removeObject(forKey: type)
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
