//
//  SliderViewCell.swift
//  FlightController
//
//  Created by Matthew Territo on 9/14/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit

class SliderViewCell: SettingsViewCell {
    var max: Double = 100.0
    var min: Double = 0.0
    var slider: UISlider = UISlider()
    var minLabel: UILabel = UILabel()
    var maxLabel: UILabel = UILabel()

    override func awakeFromNib() {
        super.awakeFromNib()
        minLabel.text = String(min)
        maxLabel.text = String(max)
        stackView.addSubview(minLabel)
        stackView.addSubview(slider)
        stackView.addSubview(maxLabel)

    }
}
