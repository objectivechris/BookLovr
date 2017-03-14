//
//  Book.swift
//  BookLovr
//
//  Created by Christopher Rene on 3/9/17.
//  Copyright © 2017 Christopher Rene. All rights reserved.
//

import Foundation

class Book {
    var name = ""
    var author = ""
    var genre = ""
    var location = ""
    var image = ""
    var haveRead = false
    var rating = ""
    
    init(name: String, author: String, genre: String, location: String, image: String, haveRead: Bool) {
        self.name = name
        self.author = author
        self.genre = genre
        self.location = location
        self.image = image
        self.haveRead = haveRead
    }
}
