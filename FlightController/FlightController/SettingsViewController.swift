//
//  SettingsViewController.swift
//  FlightController
//
//  Created by Matthew Territo on 9/14/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit
class SettingsViewController: OpenSpaceViewController {

    struct Slider {
        var max: Double = 100.0
        var min: Double = 0.0
        var label: String
    }
    var sliders: [Slider] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettings()

    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    private func loadSettings() {
        let collectionViews = view.subviews.filter{$0 is UICollectionView}
        collectionViews.forEach({
            guard let a = $0 as? UICollectionView else { return }
            a.register(SettingsViewCell.self, forCellWithReuseIdentifier: "settingsViewCell")
        })
        sliders.append(Slider(max: 50.0, min: 1.0, label: "Sensitivity"))
        sliders.append(Slider(max: 50.0, min: 1.0, label: "Dudes"))
        sliders.append(Slider(max: 50.0, min: 1.0, label: "Dorks"))
    }
 }

extension  SettingsViewController: UICollectionViewDelegate { }
extension SettingsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sliders.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "settingsViewCell", for: indexPath) as? SettingsViewCell else {
            fatalError("No settingsViewCell")
        }
        cell.label.text = store.
        return cell
    }
}
