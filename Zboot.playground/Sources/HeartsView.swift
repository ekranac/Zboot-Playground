import Foundation
import UIKit

class HeartsView: UIStackView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    public func setHearts(numberOfHearts hearts: Int) {
        self.subviews.forEach({ $0.removeFromSuperview() })
        for index in 0..<Constants.numberOfHearts {
            let heartLabel = UILabel()

            heartLabel.text = hearts > index ? "❤️" : ""
            heartLabel.textAlignment = .center
            heartLabel.font = UIFont(name: Constants.defaultFontName, size: 30.0)

            heartLabel.translatesAutoresizingMaskIntoConstraints = false
            heartLabel.heightAnchor.constraint(equalToConstant: self.frame.height).isActive = true
            heartLabel.widthAnchor.constraint(equalToConstant:
                self.frame.width / CGFloat(Constants.numberOfHearts)).isActive = true

            addArrangedSubview(heartLabel)
        }
    }

}
