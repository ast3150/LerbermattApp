//
//  MensaViewController.swift
//  Gymkl Swift
//
//  Created by Alain Stulz on 07.06.14.
//  Copyright (c) 2014 Alain Stulz. All rights reserved.
//

//  Controls the "Mensa"-Tab

import UIKit
import SpriteKit

class MensaViewController: UIViewController, UIScrollViewDelegate, UIAlertViewDelegate {

    // MARK: Variables
    var actInd = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    var jsonError : NSError?
    var mensaData: NSMutableData = NSMutableData()
    var useAnimations = false
    var weekdayArray = [MensaDay]()
    
    // MARK: Outlets
    @IBOutlet var budgetDescriptionLabel : UILabel!
    @IBOutlet var budgetMenuLabel : UILabel!
    @IBOutlet var dateLabel : UILabel!
    @IBOutlet var horizontalLineView: UIImageView!
    @IBOutlet var meatDescriptionLabel : UILabel!
    @IBOutlet var meatMenuLabel : UILabel!
    @IBOutlet var networkErrorView : UIView!
    @IBOutlet var noDataErrorView: UIView!
    @IBOutlet var secondLineView: UIImageView!
    @IBOutlet var segmentedControl : UISegmentedControl!
    @IBOutlet var thirdLineView: UIImageView!
    @IBOutlet var vegetarianMenuLabel : UILabel!
    @IBOutlet var vegetarianDescriptionLabel : UILabel!

    // MARK: - Runtime Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        useAnimations = NSUserDefaults.standardUserDefaults().objectForKey("mensaAnimation")! as! Bool

        // Initialize GUI Elements
        if useAnimations {
            self.dimLabels(titles: false, descriptions: true, date: true, lines: false, segCtrl: true, alpha: 0.0)
        }
        else {
            self.dimLabels(titles: true, descriptions: true, date: true, lines: true, segCtrl: true, alpha: 0.0)
        }
        
        // Call loadData which controls the loading and parsing of JSON Content and calls the method to configure the UI
        self.loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: -
struct MensaDay {
    var buttonTitle = ""
    var date = ""
    var meatMenu = ""
    var meatDescription = ""
    var vegetarianMenu = ""
    var vegetarianDescription = ""
    var budgetMenu = ""
    var budgetDescription = ""
}

// MARK: - Data controller
extension MensaViewController: NSURLSessionDataDelegate {

    func loadData() { // This method controls the process of loading and parsing JSON Data
        
        showReloadIndicators()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let task = NSURLSession.sharedSession().dataTaskWithURL(mensaBaseURL!, completionHandler: {(data: NSData?, response: NSURLResponse?, error: NSError?) in
                if response != nil {
                    if let error = self.jsonError { // Handling network connection error
                        dispatch_async(dispatch_get_main_queue(), {
                            self.hideReloadIndicators(showNetworkErrorView: false, showNoDataErrorView: true)
                        })
                    }
                    else if (response as! NSHTTPURLResponse).statusCode == 200 && data!.length > 2 {
                        var jsonMensaArray = NSArray()
                        do {
                            jsonMensaArray = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSArray
                        } catch {
                            
                        }
                        self.parseJSON(jsonMensaArray) // Extracts JSON Data to Array
                        dispatch_async(dispatch_get_main_queue(), {
                            self.configureSegmentedControl(self.segmentedControl, weekdays: self.weekdayArray) // Configures the GUI
                        })
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.hideReloadIndicators(showNetworkErrorView: false, showNoDataErrorView: true)
                        })
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.hideReloadIndicators(showNetworkErrorView: true, showNoDataErrorView: false)
                    })
                }
            })
            task.resume()
        })
    }
    
    func parseJSON(array: NSArray) {
        for (index, object) in array.enumerate() {
            if let object = array[index] as? Dictionary<String, AnyObject> {
                var protoDay = MensaDay()
                protoDay.buttonTitle = fixString(object["buttonTitle"], dash: false)
                protoDay.date = fixString(object["date"], dash: false)
                protoDay.meatMenu = fixString(object["meatMenu"], dash: true)
                protoDay.meatDescription = fixString(object["meatDescription"], dash: false)
                protoDay.vegetarianMenu = fixString(object["vegetarianMenu"], dash: true)
                protoDay.vegetarianDescription = fixString(object["vegetarianDescription"], dash: false)
                protoDay.budgetMenu = fixString(object["budgetMenu"], dash: true)
                protoDay.budgetDescription = fixString(object["budgetDescription"], dash: false)
                weekdayArray.append(protoDay);
            }
        }
    }
    
    func fixString(stringObject: AnyObject?, dash: Bool) -> String {
        // Removes certain line breaks and dashes
        var string = stringObject as! String
        if dash {
//            return string.stringByReplacingOccurrencesOfString("\n", withString: " ", options: nil, range: nil).stringByReplacingOccurrencesOfString(" -", withString: "-", options: nil, range: nil)
            return string.stringByReplacingOccurrencesOfString(" -", withString: "-", options: .LiteralSearch, range: nil)
        }
        return string
//        return string.stringByReplacingOccurrencesOfString("\n", withString: " ", options: nil, range: nil)
    }
}

// MARK: - UI Controller
extension MensaViewController {
    
    func configureSegmentedControl (segmentedControl:UISegmentedControl, weekdays:Array<MensaDay>) {
        // Sets the segments according to the number of weekdays
        segmentedControl.removeAllSegments()
        for (index, object) in weekdays.enumerate() {
            segmentedControl.insertSegmentWithTitle((weekdays[index].buttonTitle).capitalizedString, atIndex: index, animated: false)
        }
        if segmentedControl.numberOfSegments == 1 {
            segmentedControl.removeFromSuperview()
        }
        segmentedControl.selectedSegmentIndex = 0
        configureLabels(0, weekdays:weekdays)
        hideReloadIndicators(showNetworkErrorView: false, showNoDataErrorView: false)
    }
    
    func configureLabels (index:Int, weekdays:Array<MensaDay>) {
        if useAnimations == true {
            UIView.animateWithDuration(0.5, delay: 1.25, options: [], animations: {
                self.dimLabels(titles: true, descriptions: true, date: false, lines: true, segCtrl: false, alpha: 0.0)
                }, completion: {_ in
                    self.setLabelText(index, weekdays: weekdays)
                    UIView.animateWithDuration(0.5, delay: 0.0, options: [], animations: {
                        self.dimLabels(titles: true, descriptions: true, date: true, lines: true, segCtrl: true, alpha: 1.0)
                        self.segmentedControl.tintColor = blueColor
                        self.segmentedControl.userInteractionEnabled = true
                        }, completion: {_ in})
            })
            useAnimations = false
        }
        else {
                self.setLabelText(index, weekdays: weekdays)
                self.dimLabels(titles: true, descriptions: true, date: true, lines: true, segCtrl: true, alpha: 1.0)
                self.segmentedControl.tintColor = blueColor
                self.segmentedControl.userInteractionEnabled = true
        }
    }
    
    func setLabelText(index: Int, weekdays:Array<MensaDay>) {
        self.meatMenuLabel.text = weekdays[index].meatMenu
        self.vegetarianMenuLabel.text = weekdays[index].vegetarianMenu
        self.budgetMenuLabel.text = weekdays[index].budgetMenu
        self.dateLabel.text = weekdays[index].date
        self.meatDescriptionLabel.text = weekdays[index].meatDescription
        self.meatDescriptionLabel.preferredMaxLayoutWidth = self.meatDescriptionLabel.alignmentRectForFrame(self.meatDescriptionLabel.frame).size.width
        self.vegetarianDescriptionLabel.text = weekdays[index].vegetarianDescription
        self.vegetarianDescriptionLabel.preferredMaxLayoutWidth = self.vegetarianDescriptionLabel.alignmentRectForFrame(self.vegetarianDescriptionLabel.frame).size.width
        self.budgetDescriptionLabel.text = weekdays[index].budgetDescription
        self.budgetDescriptionLabel.preferredMaxLayoutWidth = self.budgetDescriptionLabel.alignmentRectForFrame(self.budgetDescriptionLabel.frame).size.width
    }
    
    func dimLabels(titles titles: Bool, descriptions: Bool, date: Bool, lines: Bool, segCtrl: Bool, alpha: CGFloat) {
        if titles {
            self.meatMenuLabel.alpha = alpha
            self.vegetarianMenuLabel.alpha = alpha
            self.budgetMenuLabel.alpha = alpha
        }
        if descriptions {
            self.meatDescriptionLabel.alpha = alpha
            self.vegetarianDescriptionLabel.alpha = alpha
            self.budgetDescriptionLabel.alpha = alpha
        }
        if date {
            self.dateLabel.alpha = alpha
        }
        if lines {
            horizontalLineView.alpha = alpha
            secondLineView.alpha = alpha
            thirdLineView.alpha = alpha
        }
        
        if segCtrl {
            segmentedControl.alpha = alpha
        }
    }
    
    @IBAction func selectedSegmentDidChange(sender : AnyObject) {
        configureLabels(sender.selectedSegmentIndex, weekdays:weekdayArray)
    }
    
    @IBAction func didRecognizeSwipe(sender: UISwipeGestureRecognizer) {
        if networkErrorView.hidden && noDataErrorView.hidden {
            var index = segmentedControl.selectedSegmentIndex
            if sender.direction == .Left { ++index }
            else if sender.direction == .Right { --index }
            if (0 <= index && index < segmentedControl.numberOfSegments) {
                segmentedControl.selectedSegmentIndex = index
                setLabelText(index, weekdays: weekdayArray)
            }
        }
    }
    
}

// MARK: - Reload Controller
extension MensaViewController {
    func showReloadIndicators() {
        app.networkActivityIndicatorVisible = true
        mensaData.length = 0
        weekdayArray.removeAll(keepCapacity: false)
        jsonError = nil
        self.navigationItem.leftBarButtonItem?.customView = actInd
        actInd.startAnimating()
    }
    
    func hideReloadIndicators(showNetworkErrorView showNetworkErrorView: Bool, showNoDataErrorView: Bool) {
        networkErrorView.hidden = !showNetworkErrorView
        self.view.bringSubviewToFront(networkErrorView)
        noDataErrorView.hidden = !showNoDataErrorView
        self.view.bringSubviewToFront(noDataErrorView)
        app.networkActivityIndicatorVisible = false
        actInd.stopAnimating()
        let reloadButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "reloadPressed:")
        self.navigationItem.leftBarButtonItem = reloadButton
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.blackColor()
    }
    
    @IBAction func reloadPressed(sender: AnyObject) {
        self.loadData()
    }
}
