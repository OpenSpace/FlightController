//
//  MenuViewController.swift
//  FlightController
//
//  Created by Matthew Territo on 8/7/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit
import Foundation

class MenuViewController: ConfiguredViewController {
    @IBOutlet weak var focusPicker: UIPickerView!
    @IBOutlet weak var allPicker: UIPickerView!
    // MARK: UIViewController overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        focusPicker.delegate = self
        allPicker.delegate = self
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        focusPicker.backgroundColor = UIColor.black
        focusPicker.dataSource = self
        focusPicker.center = CGPoint(x: view.center.x/2, y: view.center.y)
        focusPicker.tag = PickerTags.FocusNode.hashValue
        focusPicker.bounds.size.width = view.center.x

        allPicker.backgroundColor = UIColor.black
        allPicker.dataSource = self
        allPicker.center = CGPoint(x: view.center.x + view.center.x/2,
                                   y: view.center.y)
        allPicker.tag = PickerTags.AllNodes.hashValue
        allPicker.bounds.size.width = view.center.x

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func changeFocus(name: String) {
        networkManager?.write(data: OpenSpaceData(topic: 1, payload: OpenSpacePayload(focusString: name)))
    }
}

extension MenuViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: UIPickerViewDataSource implementation

    enum PickerTags:Int {
        case FocusNode
        case AllNodes
    }

    enum NodePickerComponent:Int {
        case Name = 0
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let tag = PickerTags(rawValue: pickerView.tag) else {
            return 0
        }
        var nodes: [String:String?]?
        switch (tag) {
        case PickerTags.FocusNode:
            nodes = focusNodes
            break
        case PickerTags.AllNodes:
            nodes = allNodes
            break
        }

        return nodes?.count ?? 0
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch (pickerView.tag) {
        default:
            return 1
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let tag = PickerTags(rawValue: pickerView.tag) else {
            return ""
        }

        var unsorted: [String:String?]?
        switch (tag) {
        case PickerTags.FocusNode:
            unsorted = focusNodes
            break
        case PickerTags.AllNodes:
            unsorted = allNodes
            break
        }

        let nodes = unsorted?.sorted {
            return $0.key < $1.key
            } ?? []
        return nodes[row].key

    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        guard let tag = PickerTags(rawValue: pickerView.tag) else {
            return nil
        }

//        var unsorted: [String:String?]?
        var n: [String]?

        switch (tag) {
        case PickerTags.FocusNode:
        //    unsorted = focusNodes
            n = focusNodeNames
            break
        case PickerTags.AllNodes:
        //    unsorted = allNodes
            n = allNodeNames
            break
        }

//        let nodes = unsorted?.sorted {
//            return $0.key < $1.key
//            } ?? []

//        return NSAttributedString(string: nodes[row].key, attributes: [NSAttributedStringKey.foregroundColor:UIColor.darkGray])
        return NSAttributedString(string: n![row], attributes: [NSAttributedStringKey.foregroundColor:UIColor.darkGray])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        guard let tag = PickerTags(rawValue: pickerView.tag) else {
            return
        }

        switch (tag) {
        case PickerTags.FocusNode:
            changeFocus(name: focusNodeNames![row])
            break
        case PickerTags.AllNodes:
            changeFocus(name: allNodeNames![row])
            break
        }
    }
}
