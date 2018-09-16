//
//  SettingsViewCell.swift
//  FlightController
//
//  Created by Matthew Territo on 9/14/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit

class SettingsViewCell: UICollectionViewCell {

    weak var label: UILabel!
    weak var stackView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        label = UILabel(frame: .zero)

        stackView = UIStackView(arrangedSubviews: [label])
        stackView.axis = .horizontal

        contentView.addSubview(stackView)

    }
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        label = UILabel(frame: .zero)
//
//        stackView = UIStackView(arrangedSubviews: [label])
//        stackView.axis = .horizontal
//
//        contentView.addSubview(stackView)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // Remove everything but the label
//        stackView.subviews.forEach( {
//            if $0 != label {
//                $0.removeFromSuperview()
//            }
//        })
//
//        // Clear the label text
//        label.text = nil
    }
}
