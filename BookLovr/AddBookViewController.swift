//
//  AddBookViewController.swift
//  BookLovr
//
//  Created by Christopher Rene on 3/11/17.
//  Copyright © 2017 Christopher Rene. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class AddBookViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet var bookNameTextField:UITextField!
    @IBOutlet var bookAuthorTextField:UITextField!
    @IBOutlet var bookGenreTextField:UITextField!
    @IBOutlet var bookLocationTextField:UITextField!
    @IBOutlet var yesButton:UIButton!
    @IBOutlet var noButton:UIButton!
    
    var haveRead = true
    var book: BookMO!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func saveRecordToCloud(book: BookMO!) {
        let record = CKRecord(recordType: "Book")
        record.setValue(book.name, forKey: "name")
        record.setValue(book.author, forKey: "author")
        record.setValue(book.genre, forKey: "genre")
        record.setValue(book.location, forKey: "location")
        
        let imageData = book.image! as Data
        
        // Resize the image
        let originalImage = UIImage(data: imageData)!
        let scalingFactor = (originalImage.size.width > 1024) ? 1024 / originalImage.size.width : 1.0
        let scaledImage = UIImage(data: imageData, scale: scalingFactor)!
        
        // Write the image to local file for temporary use
        let imageFilePath = NSTemporaryDirectory() + book.name!
        let imageFileURL = URL(fileURLWithPath: imageFilePath)
        try? UIImageJPEGRepresentation(scaledImage, 0.8)?.write(to: imageFileURL)
        
        // Create image asset for upload
        let imageAsset = CKAsset(fileURL: imageFileURL)
        record.setValue(imageAsset, forKey: "image")
        
        // Get the Public iCloud Database
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        // Save the record to iCloud
        publicDatabase.save(record, completionHandler: { (record, error) -> Void  in
            // Remove temp file
            try? FileManager.default.removeItem(at: imageFileURL)
        })
    }

    @IBAction func save(sender: AnyObject) {
        if bookNameTextField.text == "" || bookAuthorTextField.text == "" || bookGenreTextField.text == "" || bookLocationTextField.text == "" {
            let alertController = UIAlertController(title: "Oops", message: "We can't proceed because one of the fields is blank. Please note that all fields are required.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
        }
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            book = BookMO(context: appDelegate.persistentContainer.viewContext)
            book.name = bookNameTextField.text
            book.author = bookAuthorTextField.text
            book.genre = bookGenreTextField.text
            book.location = bookLocationTextField.text
            book.haveRead = haveRead
            
            if let bookImage = photoImageView.image {
                if let imageData = UIImagePNGRepresentation(bookImage) {
                    book.image = NSData(data: imageData)
                }
            }
            
            print("Saving data to context...")
            appDelegate.saveContext()
        }
        
        saveRecordToCloud(book: book)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func toggleBeenHereButton(sender: UIButton) {
        if sender == yesButton {
            haveRead = true
            yesButton.backgroundColor = UIColor(red: 218.0/255.0, green: 100.0/255.0, blue: 70.0/255.0, alpha: 1.0)
            noButton.backgroundColor = UIColor(red: 218.0/255.0, green: 223.0/255.0, blue: 225.0/255.0, alpha: 1.0)
            
        } else if sender == noButton {
            haveRead = false
            yesButton.backgroundColor = UIColor(red: 218.0/255.0, green: 223.0/255.0, blue: 225.0/255.0, alpha: 1.0)
            noButton.backgroundColor = UIColor(red: 218.0/255.0, green: 100.0/255.0, blue: 70.0/255.0, alpha: 1.0)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if photoImageView.image == UIImage(named: "photoalbum") {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .camera
                    
                    present(imagePicker, animated: true, completion: nil)
                }
            } else {
                let alertController = UIAlertController(title: "Delete Image", message: "Are you sure you want to delete this photo?", preferredStyle: .actionSheet)
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                    self.photoImageView.image = UIImage(named: "photoalbum")
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alertController.addAction(cancelAction)
                alertController.addAction(deleteAction)
                present(alertController, animated: true, completion: nil)
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            photoImageView.image = selectedImage
            photoImageView.contentMode = .scaleAspectFill
            photoImageView.clipsToBounds = true
        }
        
        let leadingConstraint = NSLayoutConstraint(item: photoImageView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: photoImageView.superview, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
        leadingConstraint.isActive = true
        
        let trailingConstraint = NSLayoutConstraint(item: photoImageView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: photoImageView.superview, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
        trailingConstraint.isActive = true
        
        let topConstraint = NSLayoutConstraint(item: photoImageView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: photoImageView.superview, attribute: NSLayoutAttribute.top, multiplier: 1,
                                               constant: 0)
        topConstraint.isActive = true
        let bottomConstraint = NSLayoutConstraint(item: photoImageView, attribute: NSLayoutAttribute.bottom, relatedBy:NSLayoutRelation.equal, toItem: photoImageView.superview, attribute: NSLayoutAttribute.bottom, multiplier: 1,
                                                  constant: 0)
        bottomConstraint.isActive = true
        
        dismiss(animated: true, completion: nil)
    }
}
