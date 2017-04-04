import Foundation
import UIKit

public class RainingItem: UILabel {

    fileprivate var controller: GameController!
    fileprivate var rootView: UIView!

    fileprivate var displayLink: CADisplayLink!

    fileprivate let candies = ["🍬", "🍫", "🍩", "🍭", "🍪", "🍦", "🍰", "🍡"]
    fileprivate let fruitsAndVeggies = ["🥔", "🍐", "🥝", "🥑", "🥕", "🍆", "🍋"]

    dynamic var wasCaught = false
    var type: RainingItemType!

    public init(controller: UIViewController) {
        guard let gameController = controller as? GameController else {
            super.init(frame: CGRect(x: Double(Constants.screenWidth / 2.0),
                                     y: -Constants.rainingItemOffset,
                                     width: Constants.rainingItemDimen,
                                     height: Constants.rainingItemDimen))
            return
        }
        self.controller = gameController
        self.rootView = controller.view

        let randomXPosition = Double(arc4random_uniform(
            UInt32(rootView.frame.width - CGFloat(Constants.rainingItemDimen))))
        super.init(frame: CGRect(x: randomXPosition,
                                 y: -Constants.rainingItemOffset,
                                 width: Constants.rainingItemDimen,
                                 height: Constants.rainingItemDimen))
        self.textAlignment = .center
        self.font = UIFont(name: Constants.defaultFontName, size: 30.0)
        let isGood = arc4random_uniform(2) == 1
        if isGood {
            self.text = candies[Int(arc4random_uniform(UInt32(candies.count)))]
            self.type = .good
        } else {
            self.text = fruitsAndVeggies[Int(arc4random_uniform(UInt32(fruitsAndVeggies.count)))]
            self.type = .bad
        }

        // Register CADisplayLink to keep track of frame position
        displayLink = CADisplayLink(target: self, selector: #selector(animationDidUpdate))
        displayLink.add(to: .main, forMode: .defaultRunLoopMode)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        self.removeObserver(self.controller!, forKeyPath: "wasCaught", context: &GameController.kvoContext)
    }

    func fall() {
        UIView.animate(withDuration: 10.0, animations: {() in
            let translationY = Constants.screenHeight + CGFloat(Constants.rainingItemOffset)
            let translateTransform = CGAffineTransform.init(translationX: 0.0,
                                                            y: translationY)
            self.transform = translateTransform
        }, completion: { (didNotCatchWithBucket) in
            self.wasCaught = !didNotCatchWithBucket
            if didNotCatchWithBucket {
                self.removeFromSuperview()
            }
            self.displayLink.invalidate()
        })
    }

    func animationDidUpdate(displayLink: CADisplayLink) {
        guard let currentFrame = self.layer.presentation()?.frame else {
            return
        }

        if currentFrame.origin.y > 562.0  && currentFrame.origin.y < 582.0
            && controller.bucketIcon.frame.intersects(currentFrame) {
            self.removeFromSuperview()
        }
    }

    enum RainingItemType {
        case bad
        case good
    }
}
