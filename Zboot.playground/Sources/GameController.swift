import Foundation
import UIKit

public class GameController: UIViewController {

    static var kvoContext: UInt = 1

    public var bucketIcon: UILabel!
    fileprivate var heartsView: HeartsView!
    fileprivate var scoreLabel: UILabel!
    fileprivate var candyRainTimer: Timer!
    fileprivate var itemsToFallAtOnce = 1
    fileprivate var messages: MessagesUtils!
    fileprivate var score = 0 {
        willSet {
            scoreLabel.text = String(newValue)
            if newValue == 1 {
                messages.removeViewWithTag(tag: MessagesUtils.tagInstructionsLabel)
            }
            if newValue != 0 && newValue % 10 == 0 {
                itemsToFallAtOnce = newValue / 10
                candyRainTimer.invalidate()
                let interval = TimeInterval(CGFloat(newValue / 10) / 2)
                candyRainTimer = scheduleNewCandyRainTimer(controller: self,
                                                           withTimeInterval: interval)
            }
        }
    }

    fileprivate var gameIsActive = false {
        willSet {
            if newValue == false {
                endGame()
            }
        }
    }

    fileprivate var heartsLeft: Int = 0 {
        willSet {
            if newValue == 0 {
                gameIsActive = false
            }
            heartsView.setHearts(numberOfHearts: newValue)

        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        guard let rootView = self.view else {
            return
        }
        setBoundsAndContent(rootView: rootView, completionHandler: {() in
            // Start the game & candy rain!
            guard let startGameButton = messages.getViewWithTag(tag: MessagesUtils.tagStartGameButton)
                as? UIButton else {
                return
            }

            startGameButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)
        })

    }

    func dragBucket(sender: UIPanGestureRecognizer) {
        if !gameIsActive {
            return
        }
        let translation = sender.translation(in: self.view)
        guard let senderView = sender.view, let rootView = senderView.superview else {
            print("Could not retrieve view")
            return
        }
        let currentOriginPositionX = senderView.frame.origin.x
        let newOriginPositionX = currentOriginPositionX + translation.x

        if newOriginPositionX > 0.0 && (newOriginPositionX+senderView.frame.width) < rootView.frame.width {
            senderView.center = CGPoint(x: senderView.center.x+translation.x, y: senderView.center.y)
            sender.setTranslation(CGPoint.zero, in: self.view)
        }

    }

    fileprivate func scheduleNewCandyRainTimer(controller: UIViewController,
                                               withTimeInterval interval: TimeInterval) -> Timer {
        guard let viewController = controller as? GameController else {
            return Timer()
        }
        return Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: {(_) in
            var lastDelay: Double = 0.0
            for _ in 0..<viewController.itemsToFallAtOnce {
                // Can't let multiple items fall at the same time, 
                // makes it pretty much impossible for the user to catch them
                lastDelay += (Double(arc4random() / UINT32_MAX) + 0.5)
                DispatchQueue.main.asyncAfter(deadline: .now() + lastDelay, execute: {() in
                    let rainingItem = RainingItem(controller: controller)
                    viewController.view.addSubview(rainingItem)
                    rainingItem.fall()
                    rainingItem.addObserver(controller,
                                            forKeyPath: "wasCaught",
                                            options: .new,
                                            context: &GameController.kvoContext)
                })
            }
        })
    }

    override public func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey : Any]?,
                                      context: UnsafeMutableRawPointer?) {
        guard context == &GameController.kvoContext, keyPath=="wasCaught", gameIsActive == true else {
            return
        }
        guard let wasCaught = change?[.newKey] as? Bool,
            let rainingItem = object as? RainingItem,
            let type = rainingItem.type else {
                return
        }

        if wasCaught {
            switch type {
            case .good:
                messages.showScreenMessage(didCatchCandy: true)
                score+=1
                break
            case .bad:
                messages.showScreenMessage(didCatchCandy: false)
                heartsLeft-=1
            }
        } else if !wasCaught && type == .good {
            messages.showScreenMessage(didCatchCandy: false)
            heartsLeft -= 1
        }
    }

    fileprivate func setBoundsAndContent(rootView: UIView, completionHandler completion: () -> Void) {
        rootView.frame = CGRect(x: 0, y: 0, width: Constants.screenWidth, height: Constants.screenHeight)
        rootView.backgroundColor = UIColor(rgb: 0xDBFFFF)

        bucketIcon = UILabel(frame: CGRect(x: rootView.frame.width/2 - 35.0, y: 577.0, width: 70.0, height: 70.0))
        let panRec = UIPanGestureRecognizer()
        panRec.addTarget(self, action: #selector(dragBucket(sender:)))
        bucketIcon.isUserInteractionEnabled = true
        bucketIcon.addGestureRecognizer(panRec)
        bucketIcon.textAlignment = .center
        bucketIcon.font = UIFont(name: Constants.defaultFontName, size: 60.0)
        bucketIcon.text = "🗑"
        bucketIcon.tag = Constants.bucketTag

        scoreLabel = UILabel(frame: CGRect(x: 0.0, y: 00.0, width: Constants.screenWidth, height: 60.0))
        guard let pixelatedFontUrl = Bundle.main.url(forResource: Constants.pixelatedFontName,
                                                     withExtension: "ttf") else {
            return
        }
        CTFontManagerRegisterFontsForURL(pixelatedFontUrl as CFURL, .process, nil)
        scoreLabel.font = UIFont(name: Constants.pixelatedFontName, size: 40.0)
        scoreLabel.textColor = UIColor(rgb: Constants.orangeColor)
        scoreLabel.textAlignment = .right
        scoreLabel.text = "0"
        scoreLabel.isHidden = true

        heartsView = HeartsView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 50.0))
        heartsView.isHidden = true

        rootView.addSubview(bucketIcon)
        rootView.addSubview(heartsView)
        rootView.addSubview(scoreLabel)

        messages = MessagesUtils(parentController: self)

        messages.showStartGame()

        completion()
    }

    func startGame() {
        messages.removeViewWithTag(tag: MessagesUtils.tagTitleLabel)
        messages.removeViewWithTag(tag: MessagesUtils.tagStartGameButton)
        messages.removeViewWithTag(tag: MessagesUtils.tagGameOverLabel)
        messages.removeViewWithTag(tag: MessagesUtils.tagRetryGameButton)
        score = 0
        heartsLeft = 3
        heartsView.isHidden = false
        scoreLabel.isHidden = false
        messages.showInstructions()

        gameIsActive = true
        candyRainTimer = scheduleNewCandyRainTimer(controller: self, withTimeInterval: 1.0)
    }

    fileprivate func endGame() {
        candyRainTimer.invalidate()
        messages.showGameOver()

        guard let retryButton = messages.getViewWithTag(tag: MessagesUtils.tagRetryGameButton) as? UIButton else {
            return
        }
        retryButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)
    }

}
