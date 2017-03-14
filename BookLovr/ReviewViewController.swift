//
//  ReviewViewController.swift
//  BookLovr
//
//  Created by Christopher Rene on 3/10/17.
//  Copyright © 2017 Christopher Rene. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var bookReviewImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    var book: BookMO!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)
        
        containerView.transform = CGAffineTransform.init(scaleX: 0, y: 0)
        
        bookReviewImageView.image = UIImage(data: book.image! as Data)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: { 
             self.containerView.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}
