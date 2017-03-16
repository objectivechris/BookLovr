//
//  PhotoViewController.swift
//  BookLovr
//
//  Created by Christopher Rene on 3/16/17.
//  Copyright © 2017 Christopher Rene. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    
    var image:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Action methods
    
    @IBAction func save(sender: UIButton) {
    }

}
