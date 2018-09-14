//
//  MenuViewController.swift
//  FlightController
//
//  Created by Matthew Territo on 8/7/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit

class MenuViewController: OpenSpaceViewController {
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
        focusPicker.bounds.size.width = view.center.x/2

        allPicker.backgroundColor = UIColor.black
        allPicker.dataSource = self
        allPicker.center = CGPoint(x: view.center.x + view.center.x/2,
                                   y: view.center.y)
        allPicker.tag = PickerTags.AllNodes.hashValue
        allPicker.bounds.size.width = view.center.x/2
    }

    func changeFocus(name: String) {
        NetworkManager.shared.write(data: OpenSpaceData(topic: 1, payload: OpenSpacePayload(focusString: name)))

        var d = DateComponents()
        d.year = 2011
        d.month = 08
        d.day = 06
        d.minute = 00
        d.hour = 00
        d.second = 00

        changeTime(date: &d)
        }

    func changeTime(date: inout DateComponents) {

        validate(date: &date)
        let funcHandle = "openspace.time.setTime"
        let formattedDate = String(format: "%04d %02d %02d %02d:%02d:%02d"
            , date.year!
            , date.month!
            , date.day!
            , date.hour!
            , date.minute!
            , date.second!)
        let script = "\(funcHandle)(\"\(formattedDate)\")"
        NetworkManager.shared.write(data: OpenSpaceData(topic: 1, payload: OpenSpacePayload(luaScript: script)))
    }

    func validate(date: inout DateComponents) {
        date.year = date.year ?? 2018
        date.month = date.month ?? 01
        date.day = date.day ?? 01
        date.minute = date.minute ?? 00
        date.hour = date.hour ?? 00
        date.second = date.second ?? 00
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
            nodes = OpenSpaceManager.shared.focusNodes
            break
        case PickerTags.AllNodes:
            nodes = OpenSpaceManager.shared.allNodes
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
            unsorted = OpenSpaceManager.shared.focusNodes
            break
        case PickerTags.AllNodes:
            unsorted = OpenSpaceManager.shared.allNodes
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

        var n: [String]?

        switch (tag) {
        case PickerTags.FocusNode:
            n = OpenSpaceManager.shared.focusNodeNames
            break
        case PickerTags.AllNodes:
            n = OpenSpaceManager.shared.allNodeNames
            break
        }

        guard let nodes = n, row < nodes.count else {
            return NSAttributedString(string: "----\(row)----", attributes: [NSAttributedStringKey.foregroundColor:UIColor.darkGray])
        }

        return NSAttributedString(string: nodes[row], attributes: [NSAttributedStringKey.foregroundColor:UIColor.darkGray])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        guard let tag = PickerTags(rawValue: pickerView.tag) else {
            return
        }

        switch (tag) {
        case PickerTags.FocusNode:
            guard let focusNodes = OpenSpaceManager.shared.focusNodeNames else {
                break
            }
            changeFocus(name: focusNodes[row])
            break
        case PickerTags.AllNodes:
            guard let allNodes = OpenSpaceManager.shared.allNodeNames else {
                break
            }
            changeFocus(name: allNodes[row])
            break
        }
    }
}
