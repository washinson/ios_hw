//
//  ShareViewController.swift
//  EventsShare
//
//  Created by alex on 26.02.2021.
//  Copyright © 2021 washinson. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData

@objc(ShareExtensionViewController)
class ShareViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var label: UITextField!
    @IBOutlet weak var text: UITextView!
    @IBOutlet weak var status: UIPickerView!
    @IBOutlet weak var date: UIDatePicker!

    var container: NSPersistentContainer!
    
    let statuses = ["New", "In progress", "Successful"]
    
    @IBAction func create(_ sender: Any) {
        if (!inputDidTappedCorrect()) {
            return
        }
        
        let event = Event(context: container.viewContext)
        
        event.date = date.date
        event.title = label.text ?? ""
        event.note = text.text
        event.status = statuses[status.selectedRow(inComponent: 0)]
        
        saveContext(container: container)
        
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    @IBAction func cancel(_ sender: Any) {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        container = NSPersistentContainer(name: "EventsApp")
        
        let storeURL = URL.storeURL(for: "group.events.core.data", databaseName: "Events")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores { storeDescription, error in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
        
        status.delegate = self
        status.dataSource = self
        status.selectRow(1, inComponent: 0, animated: false)
        
        self.handleSharedFile()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statuses.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statuses[row]
    }
    
    func inputDidTappedCorrect() -> Bool {
        if (label.text?.isEmpty != false) {
            label.backgroundColor = .red
            return false
        } else {
            label.backgroundColor = .white
        }
        
        return true
    }
    
    private func handleSharedFile() {
        // extracting the path to the URL that is being shared
        let attachments = (self.extensionContext?.inputItems.first as? NSExtensionItem)?.attachments ?? []
        let contentType = kUTTypeData as String
        for provider in attachments {
            // Check if the content type is the same as we expected
            if provider.hasItemConformingToTypeIdentifier(contentType) {
                provider.loadItem(forTypeIdentifier: contentType, options: nil) { [unowned self] (data, error) in
                    // Handle the error here if you want
                    guard error == nil else { return }
                    
                    if let text = data as? String {
                        self.text.text = text
                    } else {
                        fatalError("Impossible to get text")
                    }
                }}
        }
    }
}
