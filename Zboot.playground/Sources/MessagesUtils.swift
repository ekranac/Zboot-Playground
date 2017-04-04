import Foundation
import UIKit

public class MessagesUtils {

    static let tagInstructionsLabel = 100
    static let tagScreenMessageLabel = 101
    static let tagTitleLabel = 102
    static let tagStartGameButton = 103
    static let tagGameOverLabel = 104
    static let tagRetryGameButton = 105

    fileprivate var parentController: UIViewController!
    fileprivate let goodMessages = ["Woop! 🙌", "👍👍👍", "Keep it up!", "Wow... 😮", "Nice catch 😃",
                                    "Not bad 👍", "Wow! 😱", "Get those 🍬🍬🍬", "Well done!", "😛", "You're a ⭐️", "⭐️⭐️⭐️⭐️⭐️"]
    fileprivate let badMessages = ["Whoops 🙄", "Oh no 😟", "Careful! 😳", "Not good👎", "🙄", "😟", "😳", "👎"]

    public init(parentController controller: UIViewController) {
        self.parentController = controller
    }

    public func showInstructions() {
        guard let parentView = parentController.view else {
            return
        }
        let instructionsLabel = UILabel(frame: CGRect(x: 0.0,
                                                      y: parentView.frame.height - 30.0,
                                                      width: parentView.frame.width,
                                                      height: 30.0))
        instructionsLabel.tag = MessagesUtils.tagInstructionsLabel
        instructionsLabel.text = "◀️ Drag the bucket to catch the candies! Avoid fruit & veggies! ▶️"
        instructionsLabel.textAlignment = .center
        instructionsLabel.font = UIFont(name: Constants.defaultFontName, size: 11.0)

        parentView.addSubview(instructionsLabel)
    }

    public func showStartGame() {
        guard let parentView = parentController.view else {
            return
        }
        let titleLabel = UILabel(frame: CGRect(x: 0.0,
                                               y: parentView.frame.height / 2 - 40.0,
                                               width: parentView.frame.width,
                                               height: 50.0))
        titleLabel.tag = MessagesUtils.tagTitleLabel
        titleLabel.text = "zboot"
        titleLabel.textAlignment = .center
        guard let pixelatedFontUrl = Bundle.main.url(forResource: Constants.pixelatedFontName,
                                                     withExtension: "ttf") else {
                                                        return
        }
        CTFontManagerRegisterFontsForURL(pixelatedFontUrl as CFURL, .process, nil)
        titleLabel.font = UIFont(name: Constants.pixelatedFontName, size: 40.0)

        let startGameButton = UIButton(frame: CGRect(x: 0.0,
                                                     y: parentView.frame.height / 2 + 20.0,
                                                     width: parentView.frame.width,
                                                     height: 20.0))
        startGameButton.tag = MessagesUtils.tagStartGameButton
        startGameButton.setTitle("START GAME", for: .normal)
        startGameButton.setTitleColor(UIColor(rgb: Constants.orangeColor), for: .normal)
        startGameButton.titleLabel?.font = UIFont(name: Constants.pixelatedFontName, size: 20.0)

        parentView.addSubview(titleLabel)
        parentView.addSubview(startGameButton)
    }

    public func showGameOver() {
        guard let parentView = parentController.view else {
            return
        }
        let gameOverLabel = UILabel(frame: CGRect(x: 0.0,
                                                  y: parentView.frame.height / 2,
                                                  width: parentView.frame.width,
                                                  height: 30.0))
        gameOverLabel.tag = MessagesUtils.tagGameOverLabel
        gameOverLabel.text = "GAME OVER :("
        gameOverLabel.textAlignment = .center
        guard let pixelatedFontUrl = Bundle.main.url(forResource: Constants.pixelatedFontName,
                                                     withExtension: "ttf") else {
            return
        }
        CTFontManagerRegisterFontsForURL(pixelatedFontUrl as CFURL, .process, nil)
        gameOverLabel.font = UIFont(name: Constants.pixelatedFontName, size: 20.0)

        let retryButton = UIButton(frame: CGRect(x: 0.0,
                                                     y: parentView.frame.height / 2 + 50.0,
                                                     width: parentView.frame.width,
                                                     height: 20.0))
        retryButton.tag = MessagesUtils.tagRetryGameButton
        retryButton.setTitle("RETRY", for: .normal)
        retryButton.setTitleColor(UIColor(rgb: Constants.orangeColor), for: .normal)
        retryButton.titleLabel?.font = UIFont(name: Constants.pixelatedFontName, size: 17.0)

        parentView.addSubview(gameOverLabel)
        parentView.addSubview(retryButton)
    }

    public func showScreenMessage(didCatchCandy caught: Bool) {
        guard let parentView = parentController.view else {
            return
        }

        if caught {
            // We don't want to show a message each time a user catches a candy
            let shouldShowMessage = arc4random_uniform(2) == 1
            if shouldShowMessage {
                // Remove label if still present
                removeViewWithTag(tag: MessagesUtils.tagScreenMessageLabel)

                let goodLabel = UILabel(frame: CGRect(x: 0.0,
                                                      y: parentView.frame.height - 200.0,
                                                      width: parentView.frame.width,
                                                      height: 40.0))
                goodLabel.tag = MessagesUtils.tagScreenMessageLabel
                goodLabel.textColor = UIColor(rgb: Constants.orangeColor)
                goodLabel.textAlignment = .center
                goodLabel.font = UIFont(name: Constants.defaultFontName, size: 16.0)
                goodLabel.text = goodMessages[Int(arc4random_uniform(UInt32(goodMessages.count)))]

                parentView.addSubview(goodLabel)

                Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: {(_) in
                    self.removeViewWithTag(tag: MessagesUtils.tagScreenMessageLabel)
                })
            }
        } else {
            // 'Bad' message is always shown as it can appear 3 times max 
            removeViewWithTag(tag: MessagesUtils.tagScreenMessageLabel)
            let badLabel = UILabel(frame: CGRect(x: 0.0,
                                                 y: parentView.frame.height - 200,
                                                 width: parentView.frame.width,
                                                 height: 40.0))
            badLabel.tag = MessagesUtils.tagScreenMessageLabel
            badLabel.textColor = .black
            badLabel.textAlignment = .center
            badLabel.font = UIFont(name: Constants.defaultFontName, size: 16.0)
            badLabel.text = badMessages[Int(arc4random_uniform(UInt32(badMessages.count)))]

            parentView.addSubview(badLabel)

            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: {(_) in
                self.removeViewWithTag(tag: MessagesUtils.tagScreenMessageLabel)
            })
        }

    }

    public func removeViewWithTag(tag: Int) {
        guard let view = parentController.view.viewWithTag(tag) else {
            // No view with such tag found in parent view or view isn't tagged
            return
        }

        view.removeFromSuperview()
    }

    public func getViewWithTag(tag: Int) -> UIView? {
        return parentController.view.viewWithTag(tag)
    }

}
