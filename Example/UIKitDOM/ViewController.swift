import UIKit
import UIKitDOM

class ViewController: UIViewController {
  let button: UIButton = UIButton(frame: CGRect(x: 50, y: 100, width: 100, height: 40))
  let button2: UIButton = UIButton(frame: CGRect(x: 50, y: 400, width: 100, height: 40))
  let label: UILabel = UILabel(frame: CGRect(x: 50, y: 200, width: 100, height: 40))
  let textField: UITextField = UITextField(frame: CGRect(x: 50, y: 300, width: 100, height: 40))
  var scrollView: UIScrollView = UIScrollView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = UIColor.gray
    scrollView.backgroundColor = UIColor.yellow
    button.backgroundColor = UIColor.orange
    button2.backgroundColor = UIColor.red
    textField.backgroundColor = UIColor.cyan
    label.backgroundColor = UIColor.blue
    button.setTitle("The top UIButton", for: .normal)
    button2.setTitle("The bottom UIButton", for: .normal)
    label.text = "The UILabel"
    textField.text = "The UITextField"
    
    scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height / 2)
    scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    
    self.view.addSubview(scrollView)
    scrollView.addSubview(button)
    scrollView.addSubview(label)
    scrollView.addSubview(textField)
    scrollView.addSubview(button2)
    
    let _ = self.view.addEventListener(
      "tap",
      {(event: UIKitDOM.EventProtocol) -> Void in
        print("[UIView] Got a tap event during phase: \(event.eventPhase)")
//        event.preventDefault()
//        event.stopPropagation()
      },
      AddEventListenerOptions(capture: 1)
    )
    let _ = scrollView.addEventListener(
      "tap",
      {(event: UIKitDOM.EventProtocol) -> Void in
        print("[UIScrollView] Got a tap event during phase: \(event.eventPhase)")
//        event.preventDefault()
//        event.stopPropagation()
      },
      AddEventListenerOptions(capture: 1)
    )
    
    // It seems that the implicit gesture recognisers on UIControls swallow up
    // the events, so unless we can find a way to simultaneously recognise with
    // both the implicit recogniser and our added one (maybe by doing a class
    // extension of UIControl that implements UIGestureRecognizerDelegate?),
    // we'll have to add our own tap event listener onto any UIControl unless we
    // want to have holes in our ability to handle taps in capturing phase.
    let _ = button2.addEventListener(
      "tap",
      {(event: UIKitDOM.EventProtocol) -> Void in
        print("[UIButton 2] Got a tap event during phase: \(event.eventPhase)")
//        event.preventDefault()
//        event.stopPropagation()
      },
      AddEventListenerOptions(capture: 1)
    )
    let _ = textField.addEventListener(
      "tap",
      {(event: UIKitDOM.EventProtocol) -> Void in
        print("[UITextField] Got a tap event during phase: \(event.eventPhase)")
//        event.preventDefault()
//        event.stopPropagation()
      },
      AddEventListenerOptions(capture: 1)
    )
    
    let event = UIEvent()
    event.initEvent("tap", true, true)
    // scrollView.dispatchEvent(event)
  }
}
