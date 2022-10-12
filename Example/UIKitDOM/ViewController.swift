import UIKit
import UIKitDOM

class ViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let scrollView = UIScrollView(frame: self.view.frame)
    self.view.addSubview(scrollView)
    self.view.addSubview(UIButton())
    self.view.addSubview(UILabel())
    self.view.addSubview(UITextField())
    
    let _ = self.view.addEventListener(
      "tap",
      {(event: UIKitDOM.EventProtocol) -> Void in
        print("[UIView] Got a tap event during phase: \(event.eventPhase)")
        event.preventDefault()
        event.stopPropagation()
      },
      AddEventListenerOptions(capture: 1)
    )
    let _ = scrollView.addEventListener(
      "tap",
      {(event: UIKitDOM.EventProtocol) -> Void in
        print("[UIScrollView] Got a tap event during phase: \(event.eventPhase)")
        event.preventDefault()
        event.stopPropagation()
      },
      AddEventListenerOptions(capture: 1)
    )
    
    let event = UIEvent()
    event.initEvent("tap", true, true)
    scrollView.dispatchEvent(event)
  }
}
