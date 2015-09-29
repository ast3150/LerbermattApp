//
//  NewsViewController.swift
//  Gymkl Swift
//
//  Created by Alain Stulz on 07.06.14.
//  Copyright (c) 2014 Alain Stulz. All rights reserved.
//

//  This controls the "Aktuelles"-Tab.

import UIKit

class NewsViewController: UIViewController {
    
    // MARK: Variables
    var actInd = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    var containerView = UIView()
    var jsonError: NSError?
    var newsData: NSMutableData = NSMutableData()
    var newsArray = [NewsItem]()
    var webView = UIWebView()


    // MARK: Outlets
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var noDataErrorView: UIView!

    // MARK: - Runtime functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = hairlineColor
        
        webView.delegate = self
        webView.backgroundColor = UIColor.whiteColor()

        self.loadData()
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// Defines an object for storing the news
struct NewsItem {
    var text = ""
    var link = ""
    var linkText = ""
    var imagePath = ""
    var type = ""
}


// MARK: - Data controller
extension NewsViewController: NSURLSessionDataDelegate {
    func loadData() {
        self.showReloadIndicators()
        
        // This starts the following code block asynchronously as to not block up the main queue by downloading (app would become unresponsive while loading)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            // Reset data variables
            self.newsArray = []
            self.jsonError = nil
            
            // Initialize download task
            let task = NSURLSession.sharedSession().dataTaskWithURL(newsBaseURL!, completionHandler: {(data: NSData?, response: NSURLResponse?, error: NSError?) in
                // This code is run when the download is completed
                // Check if download was successful
                if response != nil {
                    // If there was an error parsing the received data
                    if let error = self.jsonError {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.hideReloadIndicators(showNetworkErrorView: false, showNoDataErrorView: true)
                        })
                    }
                        
                    // If the response was successful and data is complete
                    else if (response as! NSHTTPURLResponse).statusCode == 200 && data!.length > 2 {
                        
                        var jsonNewsArray = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &self.jsonError) as NSArray  // Converts NSData to JSON (Array of objects)
                        var htmlString = self.parseJSON(jsonNewsArray) // Parse the received data using method below
                        
                        // Tasks changing the displayed user interface should be performed on the main queue only
                        dispatch_async(dispatch_get_main_queue(), {
                            self.createWebView(htmlString)
                        })
                    }
                    
                    // If there was no error parsing data but no data was received either
                    else {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.hideReloadIndicators(showNetworkErrorView: false, showNoDataErrorView: true)
                        })
                    }
                }
                    
                // If there was no response at all
                else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.hideReloadIndicators(showNetworkErrorView: true, showNoDataErrorView: false)
                    })
                }
            })
            
            task.resume() // Starts the download task that was set up above
        })
    }
    
    func parseJSON(jsonNewsArray: NSArray) -> String {
        // Disassembles the received JSON object and creates an htmlString for displaying in the webView
        var htmlString = "<html><div align=\"center\">"
        
        for (index, object) in jsonNewsArray.enumerate() {
            
            if let object = jsonNewsArray[index] as? Dictionary<String, AnyObject> {
                if htmlString != "<html><div align=\"center\">" {
                    htmlString += "<br><img src=\"\(horizontalLine)\" alt=\"\" width=\"\(screenWidth-40)\" height=\"1\"><br><br>"
                }
                addObject(object, toHTMLString: &htmlString)
            }
            else if let array = jsonNewsArray[index] as? Array<AnyObject> {
                var protoArray = [NewsItem]()
                if htmlString != "<html><div align=\"center\">" {
                    htmlString += "<br><img src=\"\(horizontalLine)\" alt=\"\" width=\"\(screenWidth-40)\" height=\"1\"><br><br>"
                }
                for (index, object) in array.enumerate() {
                    if let object = array[index] as? Dictionary<String, AnyObject> {
                        addObject(object, toHTMLString: &htmlString)
                    }
                }
            }
        }
        htmlString += "</div></html>"
        return htmlString
    }
    
    func addObject (object:Dictionary<String, AnyObject>, inout toHTMLString htmlString:String) {
        // Joins objects to the htmlString
        let type = object["type"] as AnyObject? as! String
        let imagePath = object["imagePath"] as AnyObject? as! String?
        let link = object["link"] as AnyObject? as! String?
        let linkText = object["linkText"] as AnyObject? as! String?
        let text = object["text"] as AnyObject? as! String?
        switch type {
        case "image":
            htmlString += "<br><img src=\"http://www.koeniz-lerbermatt.ch/\(link!)\"><br>"
        case "boldLink":
            htmlString += "<a style=\"font-family: -apple-system-font; font-weight:bold; font-size: 15; color: #F57B7B\" href=\"http://www.koeniz-lerbermatt.ch/\(link!)\">\(linkText!)</a><br>"
        case "link":
            htmlString += "<a style=\"font-family: -apple-system-font; font-size: 15; color: #F57B7B\" href=\"http://www.koeniz-lerbermatt.ch/\(link!)\">\(linkText!)</a><br>"
        case "boldText":
            htmlString += "<span style=\"font-family: -apple-system-font; font-weight:bold; font-size: 15\">"
            htmlString += "\(text!)</span><br>"
        case "text":
            htmlString += "<span style=\"font-family: -apple-system-font; font-size: 15\">"
            htmlString += "\(text!)</span><br>"
        case "table":
            htmlString += text!
        default:
            print("")
        }
    }
}


// MARK: - WebView
extension NewsViewController: UIWebViewDelegate {
    
    // Makes webView and loads previously created htmlString
    func createWebView (htmlString: String) {
        webView.frame = CGRectMake(0, 0.5, screenWidth, screenHeight-113)
        webView.loadHTMLString(htmlString, baseURL: NSBundle.mainBundle().bundleURL)
        self.view.addSubview(webView)
        self.view.layoutIfNeeded()
        hideReloadIndicators(showNetworkErrorView: false, showNoDataErrorView: false)
    }

    // Called when user clicks a link in the webView
    func webView(webView: UIWebView!, shouldStartLoadWithRequest request: NSURLRequest!, navigationType: UIWebViewNavigationType) -> Bool {
        var requestURL = request.URL
        if (requestURL!.scheme == "http" || requestURL!.scheme == "https" || requestURL!.scheme == "mailto" && navigationType == UIWebViewNavigationType.LinkClicked) {
            app.openURL(requestURL!) // Opens URL in Safari or Mail.app
            return false
        }
        else {
            // Makes webView load the URL
            return true
        }
    }
}

// MARK: - Reload
extension NewsViewController {
    func showReloadIndicators() {
        self.navigationController?.setViewControllers([self], animated: false)
        app.networkActivityIndicatorVisible = true
        self.navigationItem.leftBarButtonItem?.customView = actInd
        actInd.startAnimating()
    }
    
    func hideReloadIndicators(showNetworkErrorView showNetworkErrorView: Bool, showNoDataErrorView: Bool) {
        // Handle showing/hiding error views according to loading success/failure
        networkErrorView.hidden = !showNetworkErrorView
        self.view.bringSubviewToFront(networkErrorView)
        noDataErrorView.hidden = !showNoDataErrorView
        self.view.bringSubviewToFront(noDataErrorView)
        
        app.networkActivityIndicatorVisible = false
        actInd.stopAnimating()
        let reloadButton  = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "reloadPressed:")
        self.navigationItem.leftBarButtonItem = reloadButton
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.blackColor()
    }
    
    @IBAction func reloadPressed(sender: AnyObject) {
        // Called when user presses Reload button
        self.loadData()
    }
}