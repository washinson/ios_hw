//
//  ShareViewController.swift
//  EventsShare
//
//  Created by alex on 26.02.2021.
//  Copyright © 2021 washinson. All rights reserved.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {

    let keyTextEvents = "textEvents"
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        let userDefaults = UserDefaults(suiteName: "group.events.core.data")!
        var textEvents = userDefaults.stringArray(forKey: keyTextEvents) ?? [String]()
        textEvents.append(contentText)
        
        userDefaults.set(textEvents, forKey: keyTextEvents)
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
