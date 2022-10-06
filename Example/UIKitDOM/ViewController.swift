import UIKit
import UIKitDOM

class ViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let _ = self.view.addEventListener(
      "tap",
      {(event: UIKitDOM.Event) -> Void in
        print("Got a tap event during phase: \(event.eventPhase)")
        event.preventDefault()
        event.stopPropagation()
      },
      AddEventListenerOptions(capture: 1)
    )
    
    let event = UIEvent()
    event.initEvent("tap", true, true)
    self.view.dispatchEvent(event)
  }
}
