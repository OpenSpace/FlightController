/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class that provides a sample set of color data.
*/

import UIKit

class ColorData {

    /// An initial set of colors.

    var colors = [
        ColorItem(name: "Red", color: #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1), starred: false),
        ColorItem(name: "Orange", color: #colorLiteral(red: 1, green: 0.5843137255, blue: 0, alpha: 1), starred: false),
        ColorItem(name: "Yellow", color: #colorLiteral(red: 1, green: 0.8, blue: 0, alpha: 1), starred: false),
        ColorItem(name: "Green", color: #colorLiteral(red: 0.2980392157, green: 0.8509803922, blue: 0.3921568627, alpha: 1), starred: false),
        ColorItem(name: "Teal Blue", color: #colorLiteral(red: 0.3529411765, green: 0.7843137255, blue: 0.9803921569, alpha: 1), starred: false),
        ColorItem(name: "Blue", color: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), starred: false),
        ColorItem(name: "Purple", color: #colorLiteral(red: 0.3450980392, green: 0.337254902, blue: 0.8392156863, alpha: 1), starred: false),
        ColorItem(name: "Pink", color: #colorLiteral(red: 1, green: 0.1764705882, blue: 0.3333333333, alpha: 1), starred: false)
    ]

    /// Delete a ColorItem object from the set of colors.

    func delete(_ colorItem: ColorItem) {
        guard let arrayIndex = colors.index(of: colorItem)
            else { preconditionFailure("Expected colorItem to exist in colors") }

        colors.remove(at: arrayIndex)

        // Send a notifications so that UI can be updated and pass the index where the colorItem was removed from.
        NotificationCenter.default.post(name: .colorItemDeleted, object: self, userInfo: [ "index": arrayIndex ])
    }

}
