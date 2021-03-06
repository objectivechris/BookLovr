//
//  DiscoverViewController.swift
//  BookLovr
//
//  Created by Christopher Rene on 3/15/17.
//  Copyright © 2017 Christopher Rene. All rights reserved.
//

import UIKit
import CloudKit

private let reuseIdentifier = "DiscoverCell"

class DiscoverViewController: UICollectionViewController {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var books: [CKRecord] = []
    var imageCache = NSCache<CKRecord.ID, NSURL>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchRecordsFromCloud()
        
        spinner.hidesWhenStopped = true
        spinner.center = view.center
        collectionView?.addSubview(spinner)
        spinner.startAnimating()
        
        collectionView?.refreshControl = UIRefreshControl()
        collectionView?.refreshControl?.backgroundColor = UIColor.white
        collectionView?.refreshControl?.tintColor = UIColor.gray
        collectionView?.refreshControl?.addTarget(self, action: #selector(fetchRecordsFromCloud), for: .valueChanged)
    }

    @objc func fetchRecordsFromCloud() {
        
        books.removeAll()
        collectionView?.reloadData()
        
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Book", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["name", "image", "author"]
        queryOperation.queuePriority = .veryHigh
        queryOperation.resultsLimit = 50
        queryOperation.recordFetchedBlock = { (record) -> Void in
            self.books.append(record)
        }
        
        queryOperation.queryCompletionBlock = { (cursor, error) -> Void in
            if let error = error {
                print("Failed to get data from iCloud - \(error.localizedDescription)")
                return
            }
            
            print("Successfully retrieved the data from iCloud.")
            OperationQueue.main.addOperation {
                self.spinner.stopAnimating()
                self.collectionView?.reloadData()
            }
            
            DispatchQueue.main.async {
                if let refreshControl = self.collectionView?.refreshControl {
                    if refreshControl.isRefreshing {
                        refreshControl.endRefreshing()
                    }
                }
            }
        }
        
        publicDatabase.add(queryOperation)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return books.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverCell", for: indexPath) as! DiscoverCollectionViewCell
    
        let book = books[indexPath.row]
        cell.imageView.image = UIImage(named: "photoalbum")
        
        
        // Configure the cell
        cell.bookNameLabel.text = book.object(forKey: "name") as? String
        cell.bookAuthorLabel.text = book.object(forKey: "author") as? String
        
        if let imageFileURL = imageCache.object(forKey: book.recordID) {
            if let imageData = try? Data(contentsOf: imageFileURL as URL) {
                cell.imageView.image = UIImage(data: imageData)
            }
        } else {
            let publicDatabase = CKContainer.default().publicCloudDatabase
            let fetchRecordsImageOperation = CKFetchRecordsOperation(recordIDs: [book.recordID])
            fetchRecordsImageOperation.desiredKeys = ["image"]
            fetchRecordsImageOperation.queuePriority = .veryHigh
            
            fetchRecordsImageOperation.perRecordCompletionBlock = { (record, recordID, error) -> Void in
                if let error = error {
                    print("Failed to get book image: \(error.localizedDescription)")
                    return
                }
                
                if let bookRecord = record {
                    OperationQueue.main.addOperation {
                        if let image = bookRecord.object(forKey: "image") {
                            let imageAsset = image as! CKAsset
                            
                            if let fileURL = imageAsset.fileURL, let imageData = try? Data(contentsOf: fileURL) {
                                cell.imageView.contentMode = .scaleAspectFit
                                cell.imageView.image = UIImage(data: imageData)
                            }
                            
                            self.imageCache.setObject(imageAsset.fileURL! as NSURL , forKey: book.recordID)
                        }
                    }
                }
            }
            
            publicDatabase.add(fetchRecordsImageOperation)
        }
        
        return cell
    }

    // MARK: UICollectionViewDelegate
}
