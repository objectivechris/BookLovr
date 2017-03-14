//
//  BookTableViewController.swift
//  Bibliophile
//
//  Created by Christopher Rene on 3/9/17.
//  Copyright © 2017 Christopher Rene. All rights reserved.
//

import UIKit
import CoreData

class BookTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
        
    var books: [BookMO] = []
    var fetchResultController: NSFetchedResultsController<BookMO>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.hidesBarsOnSwipe = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        tableView.estimatedRowHeight = 90.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Fetch data from data store
        let fetchRequest: NSFetchRequest<BookMO> = BookMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                if let fetchedObjects = fetchResultController.fetchedObjects {
                    books = fetchedObjects
                }
            } catch {
                print(error)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = true
        tableView.reloadData()
    }
    
    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return books.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BookTableViewCell

        // Configure the cell...
        cell.nameLabel.text = books[indexPath.row].name
        cell.authorLabel.text = books[indexPath.row].author
        cell.genreLabel.text = books[indexPath.row].genre
        cell.locationLabel.text = books[indexPath.row].location
        cell.thumbnailImageView.image = UIImage(data: books[indexPath.row].image! as Data)
        cell.accessoryType = books[indexPath.row].haveRead ? .checkmark : .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            books.remove(at: indexPath.row)
        }
        
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let shareAction = UITableViewRowAction(style: .default, title: "Share") { (action, indexPath) in
            let defaultText = "Check out this book I read! - " + self.books[indexPath.row].name!
            if let imageToShare = UIImage(data: self.books[indexPath.row].image! as Data) {
                let activityController = UIActivityViewController(activityItems: [defaultText, imageToShare], applicationActivities: nil)
                self.present(activityController, animated: true, completion: nil)
            }
        }
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            
            self.books.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                let bookToDelete = self.fetchResultController.object(at: indexPath)
                context.delete(bookToDelete)
                appDelegate.saveContext()
            }
        }
        
        shareAction.backgroundColor = UIColor(red: 60.0/255.0, green: 155.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        deleteAction.backgroundColor = UIColor(red: 250.0/255.0, green: 56.0/255.0, blue: 56.0/255.0, alpha: 1.0)

        return [deleteAction, shareAction]
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBookDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! BookDetailViewController
                destinationController.book = books[indexPath.row]
            }
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate methods
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let newIndexPath = newIndexPath {
                tableView.deleteRows(at: [newIndexPath], with: .fade)
            }
        case .update:
            if let newIndexPath = newIndexPath {
                tableView.reloadRows(at: [newIndexPath], with: .fade)
            }
        default:
            tableView.reloadData()
        }
        
        if let fetchedObjects = controller.fetchedObjects {
            books = fetchedObjects as! [BookMO]
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
