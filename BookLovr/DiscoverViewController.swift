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
    
//    let columns: CGFloat = 2.0
//    let inset: CGFloat = 3.0
//    let spacing: CGFloat = 4.0
//    let lineSpacing: CGFloat = 4.0
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var books: [CKRecord] = []
    
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

    func fetchRecordsFromCloud() {
        
        books.removeAll()
        collectionView?.reloadData()
        
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Book", predicate: predicate)
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["name", "image"]
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
            
            if let refreshControl = self.collectionView?.refreshControl {
                if refreshControl.isRefreshing {
                    refreshControl.endRefreshing()
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
        
        // Configure the cell
        cell.bookNameLabel.text = book.object(forKey: "name") as? String
        cell.bookAuthorLabel.text = book.object(forKey: "author") as? String
    
        if let image = book.object(forKey: "image") {
            let imageAsset = image as! CKAsset
            
            if let imageData = try? Data.init(contentsOf: imageAsset.fileURL) {
                cell.imageView.contentMode = .scaleAspectFit
                cell.imageView.image = UIImage(data: imageData)
            }
        }
        
        return cell
    }

    // MARK: UICollectionViewDelegate

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        
//        let width = Int((collectionView.frame.width / columns) - (inset + spacing))
//        let height = Int((collectionView.frame.height))
//        return CGSize(width: width, height: height)
//    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return spacing
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return lineSpacing
//    }

}
