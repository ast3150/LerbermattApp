//
//  Old MensaView Code.swift
//  Gymkl Swift
//
//  Created by Alain Stulz on 07.10.14.
//  Copyright (c) 2014 Alain Stulz. All rights reserved.
//

//  This document shows some old code that was used previous to the backend solution that is used now.
//  The Mensa website was loaded directly to the frontend and edited to extract the data from it.


/*

import Foundation
import UIKit

extension MensaViewController: UIWebViewDelegate {
    
    func loadWebView() {
        app.networkActivityIndicatorVisible = true
        self.mensaWebView.loadRequest(NSURLRequest(URL:mensaHomeURL))
    }
    
    func webViewDidFinishLoad(webView: UIWebView!) {
        // Autofill "Lerbermatt" into search field
        webView.stringByEvaluatingJavaScriptFromString("var inputFields = document.querySelectorAll(\"input[type='text']\"); for (var i = inputFields.length >>> 0; i--;) inputFields[i].value = 'Lerbermatt'")
        
        // Automatically push the necessary buttons to get the menu plan
        webView.stringByEvaluatingJavaScriptFromString("document.getElementsByClassName('search-restaurant-fulltext button-submit')[0].click();")
        webView.stringByEvaluatingJavaScriptFromString("document.getElementsByClassName('results-detail-showmenu button-submit')[0].click();")
        
        // Buffer time to make sure webView is completely loaded, then extract content
        var delayInSeconds: Double = 0.4
        var dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.app.networkActivityIndicatorVisible = false
            var currentWeek = MensaWeek(); var weekdays: Array<MensaDay> = []
            (currentWeek, weekdays) = self.extractInfo(webView)
            for var i = 0; i<(weekdays.count-1); i++ {
                self.checkMeatOrigins(webView, index:i)
            }
            self.configureSegmentedControl(self.segmentedControl, weekdays: weekdays, week:currentWeek)
        })
    }
    
    
    func webView(webView: UIWebView!, didFailLoadWithError error: NSError!) {
        activityView.stopAnimating()
        loadingView.hidden = true
        self.app.networkActivityIndicatorVisible = false;
        networkErrorView.hidden = false;
    }
    
}


// MARK: Extraction
extension MensaViewController {
    
    func extractInfo(webView:UIWebView) -> (MensaWeek, Array<MensaDay>) {
        for (index,weekday) in enumerate(weekdays) {
            getNumberOfWeekdays(webView)
        }
        for (index,weekday) in enumerate(weekdays) {
            getDateForDay(webView, index:index)
            getMenusForWeek(webView, index:index)
            getMeatOrigins(webView, index:index)
        }
        
        // printlnValues(weekdays)
        return (currentWeek, weekdays)
    } // Controlling method
    
    func getNumberOfWeekdays (webView:UIWebView) {
        var item = webView.stringByEvaluatingJavaScriptFromString("document.getElementsByTagName('li')[12].innerHTML")  // Get first button
        for weekday in weekdays {  // Check if it is "MO"
            if item.bridgeToObjectiveC().containsString(weekday.weekday) { break;}
            else {weekdays.removeAtIndex(0); currentWeek.weekdayCount = currentWeek.weekdayCount - 1 }
        }
    }
    
    
    func getDateForDay(webView: UIWebView, index:Int) {
        weekdays[index].date = webView.stringByEvaluatingJavaScriptFromString("document.getElementsByClassName('details-date')[\(index)].innerText;")
        weekdays[index].date = weekdays[index].date.bridgeToObjectiveC().substringFromIndex(countElements(weekdays[index].date) - 12)
        weekdays[index].date = weekdays[index].date.stringByReplacingOccurrencesOfString(" ", withString: "")
    }
    
    
    func getMenusForWeek (webView:UIWebView, index:Int) {
        var tempString = ""
        // Get meat menu for day
        weekdays[index].meatMenu = webView.stringByEvaluatingJavaScriptFromString("document.getElementsByClassName('details-menu-name')[\(index*3)].innerText;")
        tempString = webView.stringByEvaluatingJavaScriptFromString("document.getElementsByClassName('details-menu-trimmings')[\(index*3)].innerText;")
        weekdays[index].meatDescription = tempString.bridgeToObjectiveC().stringByReplacingOccurrencesOfString("\n\n", withString: "\n")
        
        // Get vegetarian menu for day
        weekdays[index].vegetarianMenu = webView.stringByEvaluatingJavaScriptFromString("document.getElementsByClassName('details-menu-name')[\(1+(index*3))].innerText;")
        tempString = webView.stringByEvaluatingJavaScriptFromString("document.getElementsByClassName('details-menu-trimmings')[\(1+(index*3))].innerText;")
        weekdays[index].vegetarianDescription = tempString.bridgeToObjectiveC().stringByReplacingOccurrencesOfString("\n\n", withString: "\n")
        
        // Get budget menu for day
        weekdays[index].budgetMenu = webView.stringByEvaluatingJavaScriptFromString("document.getElementsByClassName('details-menu-name')[\(2+(index*3))].innerText;")
        tempString = webView.stringByEvaluatingJavaScriptFromString("document.getElementsByClassName('details-menu-trimmings')[\(2+(index*3))].innerText;")
        weekdays[index].budgetDescription = tempString.bridgeToObjectiveC().stringByReplacingOccurrencesOfString("\n\n", withString: "\n")
    }
    
    func getMeatOrigins (webView:UIWebView, index:Int) {
        if overrideCorrection == false {
            if (weekdays[index].meatDescription == weekdays[index].vegetarianDescription) {
                weekdays[index].meatOrigin = ""
                weekdays[index].budgetOrigin = ""
                currentWeek.correction = currentWeek.correction - 1
            }
            else {
                // Need to correct order if not available for one day
                weekdays[index].meatOrigin = webView.stringByEvaluatingJavaScriptFromString("document.getElementsByClassName(\'details-menu-info\')[\(2*(currentWeek.correction+(index)))].innerText;")
                weekdays[index].budgetOrigin = webView.stringByEvaluatingJavaScriptFromString("document.getElementsByClassName(\'details-menu-info\')[\(2*(currentWeek.correction+(index))+1)].innerText;")
                println(weekdays[index].meatOrigin)
            }
        }
        else {
            weekdays[index].meatOrigin = webView.stringByEvaluatingJavaScriptFromString("document.getElementsByClassName(\'details-menu-info\')[\(index)].innerText;")
            weekdays[index].budgetOrigin = ""
        }
    }
    
    func checkMeatOrigins (webView:UIWebView, index:Int) {
        if (weekdays[index].budgetOrigin != weekdays[index+1].budgetOrigin?) {
            overrideCorrection = true
            for (index,weekday) in enumerate(weekdays) {
                getMeatOrigins(webView, index: index)
            }
        }
    }
    
    func printlnValues () {
        for weekday in weekdays {
            println("\(weekday.weekday), \(weekday.date)")
            println("\(weekday.meatMenu) - \(weekday.meatDescription) - \(weekday.meatOrigin?)")
            println("\(weekday.vegetarianMenu) - \(weekday.vegetarianDescription) - ")
            println("\(weekday.budgetMenu) - \(weekday.budgetDescription) - \(weekday.budgetOrigin?)")
        }
        
    }
    
}

*/