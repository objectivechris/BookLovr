//
//  AboutTableViewController.swift
//  BookLovr
//
//  Created by Christopher Rene on 3/14/17.
//  Copyright © 2017 Christopher Rene. All rights reserved.
//

import UIKit
import SafariServices

class AboutTableViewController: UITableViewController {

    var sectionTitles = ["Leave Feedback", "Follow Me"]
    var sectionContent = [["Rate us on App Store", "Tell us your feedback"], ["Twitter", "Medium", "GitHub"]]
    var links = ["https://twitter.com/objectivechris", "https://medium.com/@objective_chris", "https://github.com/objectivechris"]
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sectionContent[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = sectionContent[indexPath.section][indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                if let url = URL(string: "http://www.apple.com/itunes/charts/paid-apps/") {
                    UIApplication.shared.open(url)
                }
            } else if indexPath.row == 1 {
                performSegue(withIdentifier: "showWebView", sender: self)
            }
        case 1:
            if let url = URL(string: links[indexPath.row]) {
                let safariController = SFSafariViewController(url: url)
                present(safariController, animated: true, completion: nil)
            }
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
