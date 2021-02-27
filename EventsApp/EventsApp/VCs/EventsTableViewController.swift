//
//  EventsTableViewController.swift
//  EventsApp
//
//  Created by alex on 25.02.2021.
//  Copyright © 2021 washinson. All rights reserved.
//

import UIKit
import CoreData

class EventsTableViewController: UITableViewController {

    let keyTextEvents = "textEvents"
    
    var container: NSPersistentContainer!
    var events = [Event]()
    var eventPredicate: NSPredicate?
    
    @IBAction func didFilterPressed(_ sender: Any) {
        let ac = UIAlertController(title: "Filter events...", message: nil, preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Show new", style: .default)
        { [unowned self] _ in
            self.eventPredicate = NSPredicate(format: "status == 'New'")
            self.loadSavedData()
        })
        
        ac.addAction(UIAlertAction(title: "Show in process", style: .default)
        { [unowned self] _ in
            self.eventPredicate = NSPredicate(format: "status == 'In progress'")
            self.loadSavedData()
        })
        
        ac.addAction(UIAlertAction(title: "Show successful", style: .default)
        { [unowned self] _ in
            self.eventPredicate = NSPredicate(format: "status == 'Successful'")
            self.loadSavedData()
        })
        
        ac.addAction(UIAlertAction(title: "Show all", style: .default)
        { [unowned self] _ in
            self.eventPredicate = nil
            self.loadSavedData()
        })
        
        present(ac, animated: true)
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
        
        loadSavedData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Event", for: indexPath)

        let event = events[indexPath.row]
        cell.textLabel?.text = event.title
        cell.detailTextLabel?.text = event.note

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "EventController") as? EventViewController {
            vc.event = events[indexPath.row]
            vc.container = container
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadSavedData()
    }
    
    func loadSavedData() {
        let request = Event.createFetchRequest()
        request.predicate = eventPredicate
        
        do {
            events = try container.viewContext.fetch(request)
            tableView.reloadData()
        } catch {
            print("loading error")
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "eventSegue") {
            let destination = segue.destination as! EventViewController
            destination.container = container
        }
    }
    

}


