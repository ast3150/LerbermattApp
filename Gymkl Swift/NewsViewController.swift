//
//  NewsViewController.swift
//  Gymkl Swift
//
//  Created by Alain Stulz on 07.06.14.
//  Copyright (c) 2014 Alain Stulz. All rights reserved.
//

//  This controls the "Aktuelles"-Tab.

import UIKit
import SwiftyJSON
import SafariServices

class NewsViewController: UIViewController {
    
    // MARK: Variables
    var actInd = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    var containerView = UIView()
    var newsData: NSMutableData = NSMutableData()
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


// MARK: - Data controller
extension NewsViewController: NSURLSessionDataDelegate {
    func loadData() {
        self.showReloadIndicators()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { // This starts the following code block asynchronously as to not block up the main queue by downloading (app would become unresponsive while loading)
            
            // Initialize download task
            let newsBaseURL = NSURL(string: "https://gymkl-newsscraper-staging.herokuapp.com")
            let task = NSURLSession.sharedSession().dataTaskWithURL(newsBaseURL!, completionHandler: {(data: NSData?, response: NSURLResponse?, error: NSError?) in
                // This code is run when the download is completed
                
                // Check if download was successful
                guard let response = response where ((response as! NSHTTPURLResponse).statusCode == 200) else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.hideReloadIndicators(showNetworkErrorView: false, showNoDataErrorView: true)
                    })
                    print("ERROR: Received no response or response was not successful")
                    return
                }
                
                guard let data = data where data.length > 2 else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.hideReloadIndicators(showNetworkErrorView: false, showNoDataErrorView: true)
                    })
                    print("ERROR: Data was empty")
                    return
                }
                
                let jsonNewsArray = JSON(data: data)
                let htmlString = self.parseJSON(jsonNewsArray) // Parse the received data using method below
                    
                    // Tasks changing the displayed user interface should be performed on the main queue only
                    dispatch_async(dispatch_get_main_queue(), {
                        self.createWebView(htmlString)
                    })
            })
        
            task.resume() // Starts the download task that was set up above
        })
    }
    
    func parseJSON(jsonNewsArray: JSON) -> String {
        // Disassembles the received JSON object and creates an htmlString for displaying in the webView
        var htmlString = "<html><div align=\"center\">"
        
        if let newsItems = jsonNewsArray.array {
            for newsItem in newsItems {
                addHorizontalLineToString(&htmlString)
                if let newsItemElements = newsItem.array {
                    for newsItemElement in newsItemElements {
                        addObject(newsItemElement.dictionary!, toHTMLString: &htmlString)
                    }
                }
            }
            
        } else {
            // TODO: No data was found here!
        }
        
        htmlString += "</div></html>"
        return htmlString
    }
    
    func addHorizontalLineToString(inout htmlString: String) {
        if htmlString != "<html><div align=\"center\">" {
            htmlString += "<br><img src=\"\(horizontalLine)\" alt=\"\" width=\"\(screenWidth-40)\" height=\"1\"><br><br>"
        }
    }
    
    func addObject (object:Dictionary<String, JSON>, inout toHTMLString htmlString:String) {
        // Joins objects to the htmlString
        let type = object["type"]?.string
        
        switch type! {
        case "image":
            let link = object["link"]?.string
            htmlString += "<br><img src=\"http://www.koeniz-lerbermatt.ch/\(link!)\"><br>"
        case "boldLink":
            let link = object["link"]?.string
            let linkText = object["linkText"]?.string
            htmlString += "<a style=\"font-family: -apple-system-font; font-weight:bold; font-size: 15; color: #F57B7B\" href=\"http://www.koeniz-lerbermatt.ch/\(link!)\">\(linkText!)</a><br>"
        case "link":
            let link = object["link"]?.string
            let linkText = object["linkText"]?.string
            htmlString += "<a style=\"font-family: -apple-system-font; font-size: 15; color: #F57B7B\" href=\"http://www.koeniz-lerbermatt.ch/\(link!)\">\(linkText!)</a><br>"
        case "boldText":
            let text = object["text"]?.string
            htmlString += "<span style=\"font-family: -apple-system-font; font-weight:bold; font-size: 15\">"
            htmlString += "\(text!)</span><br>"
        case "text":
            let text = object["text"]?.string
            htmlString += "<span style=\"font-family: -apple-system-font; font-size: 15\">"
            htmlString += "\(text!)</span><br>"
        case "table":
            let text = object["text"]?.string
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
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if (request.URL!.scheme == "http" || request.URL!.scheme == "https" || request.URL!.scheme == "mailto" && navigationType == UIWebViewNavigationType.LinkClicked) {
            if #available (iOS 9.0, *) {
                let svc = SFSafariViewController(URL: request.URL!)
                self.presentViewController(svc, animated: true, completion: nil) // Presents URL in SafariViewController
            } else {
                app.openURL(request.URL!) // Opens URL in Safari
            }
        } else if (request.URL!.scheme == "mailto") {
            app.openURL(request.URL!) // Opens URL in Mail
        } else {
            return true // Loads content in webView
        }
        
        return false
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