//
//  EventsViewController.swift
//  EventsApp
//
//  Created by alex on 26.02.2021.
//  Copyright © 2021 washinson. All rights reserved.
//

import UIKit
import CoreData

class EventViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var container: NSPersistentContainer!
    
    let statuses = ["New", "In progress", "Successful"]
    
    var event: Event? = nil
    
    @IBOutlet weak var update: UIBarButtonItem!
    @IBOutlet weak var status: UIPickerView!
    @IBOutlet weak var date: UIDatePicker!
    @IBOutlet weak var text: UITextView!
    @IBOutlet weak var label: UITextField!
    
    @IBAction func updateEvent(_ sender: Any) {
        if (!inputDidTappedCorrect()) {
            return
        }
        
        if (event == nil) {
            event = Event(context: container.viewContext)
        }
        
        event!.date = date.date
        event!.title = label.text ?? ""
        event!.note = text.text
        event!.status = statuses[status.selectedRow(inComponent: 0)]
        
        saveContext()
        
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        status.delegate = self
        status.dataSource = self
        status.selectRow(1, inComponent: 0, animated: false)
        
        if (event != nil) {
            date.date = event!.date
            let index = statuses.firstIndex(of: event!.status)
            if (index != nil) {
                status.selectRow(index!, inComponent: 0, animated: false)
            }
            label.text = event?.title
            text.text = event?.note
            update.title = "Update"
        }
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
    
    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
