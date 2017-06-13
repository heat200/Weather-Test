//
//  ViewController.swift
//  Weather Test
//
//  Created by Bryan Mazariegos on 6/12/17.
//  Copyright © 2017 Bryan Mazariegos. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var weatherBackground:UIImageView!
    @IBOutlet var zipcodeTextField:UITextField!
    @IBOutlet var currentTempLabel:UILabel!
    @IBOutlet var highTempLabel:UILabel!
    @IBOutlet var lowTempLabel:UILabel!
    @IBOutlet var unitSelector: UISegmentedControl!
    
    var zipcode = "33193"
    var units = "imperial"
    var background = ""
    var tempLow:CGFloat = 0
    var tempCurrent:CGFloat = 0
    var tempHigh:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        zipcodeTextField.text = zipcode
        updateData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if self.view.point(inside: touch.location(in: self.view), with: nil) {
                if zipcodeTextField!.isFirstResponder {
                    zipcodeTextField.resignFirstResponder()
                    if zipcodeTextField.text?.characters.count != 5 {
                        zipcodeTextField.text = zipcode
                    }
                    updateData()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateUI() {
        weatherBackground.image = UIImage(named: background)
        currentTempLabel.text = "\(tempCurrent)°"
        highTempLabel.text = "\(tempHigh)°"
        lowTempLabel.text = "\(tempLow)°"
        
        if units == "imperial" {
            currentTempLabel.text?.append(" F")
            highTempLabel.text?.append(" F")
            lowTempLabel.text?.append(" F")
        } else {
            currentTempLabel.text?.append(" C")
            highTempLabel.text?.append(" C")
            lowTempLabel.text?.append(" C")
        }
    }
    
    @IBAction func updateData() {
        DispatchQueue.global().async {
            let data = self.pullData()
            DispatchQueue.main.async {
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)
                    let mainDict = (dictionary as AnyObject).object(forKey: "weather") as! [AnyObject]
                    self.background = mainDict[0].object(forKey: "main") as! String
                    
                    let tempDict = (dictionary as AnyObject).object(forKey: "main")!
                    self.tempCurrent = ((tempDict as AnyObject).value(forKey: "temp") as! CGFloat)
                    self.tempHigh = ((tempDict as AnyObject).value(forKey: "temp_max") as! CGFloat)
                    self.tempLow = ((tempDict as AnyObject).value(forKey: "temp_min") as! CGFloat)
                    self.updateUI()
                } catch {
                    print("Could not parse JSON: \(error)")
                }
            }
        }
    }

    func pullData() -> Data? {
        if zipcodeTextField.text?.characters.count == 5 {
            zipcode = zipcodeTextField.text!
        }
        
        if unitSelector != nil {
            if unitSelector.selectedSegmentIndex == 0 {
                units = "imperial"
            } else {
                units = "metric"
            }
        }
        
        let urlString = "http://api.openweathermap.org/data/2.5/weather?zip=\(zipcode),us&units=\(units)&APPID=626b4222b1f655ed8c4ebdd6017e9848"
        let returnData = try? Data(contentsOf: URL(string: urlString)!)
        
        return returnData
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

