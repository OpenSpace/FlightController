//
//  ViewController.swift
//  FlightController
//
//  Created by Matthew Territo on 5/23/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let a: TuioServer! = TuioServer.init(host: "192.168.84.100", port: 3333)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

