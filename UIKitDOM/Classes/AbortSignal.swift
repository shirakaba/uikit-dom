// This is mainly here as a stub; I don't intend to support anything related to
// AbortController anytime soon.
@objc public protocol AbortSignal: EventTarget {
  var aborted: Bool { get }
  
  @objc optional func onabort(_ event: UIEvent) -> AnyObject
  
  var reason: AnyObject { get }
  
  func throwIfAborted()
}
