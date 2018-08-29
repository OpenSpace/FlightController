//
//  FocusNodeCollectionViewController.swift
//  FlightController
//
//  Created by Matthew Territo on 8/28/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit

class FocusNodeCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var nodeLabel: UILabel!
}

class FocusNodeCollectionViewController: UICollectionViewController {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return OpenSpaceManager.shared.allNodes?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }

}
