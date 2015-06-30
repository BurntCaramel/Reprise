//
//  FirstViewController.swift
//  Reprise
//
//  Created by Patrick Smith on 30/06/2015.
//  Copyright © 2015 Burnt Caramel. All rights reserved.
//

import UIKit
import SafariServices


enum LinkLoadingError: ErrorType {
	case ResourceNotFound
	case InvalidFile
}


struct Link {
	var title: String
	var URL: NSURL
}


class ItemTableViewCell: UITableViewCell {
	@IBOutlet var titleLabel: UILabel!
}


class FirstViewController: UITableViewController {
	
	var links = [Link]()
	var safariViewController: SFSafariViewController!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		do {
			try loadLinksFromJSON()
		}
		catch {
			
		}
	}
	
	func loadLinksFromJSON() throws {
		let bundle = NSBundle.mainBundle()
		guard let linkJSONURL = bundle.URLForResource("items", withExtension: "json") else {
			throw LinkLoadingError.ResourceNotFound
		}
		
		guard let data = NSData(contentsOfURL: linkJSONURL) else {
			throw LinkLoadingError.InvalidFile
		}
		
		guard let JSON = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? [String: AnyObject] else {
			throw LinkLoadingError.InvalidFile
		}
		
		guard let linksJSON = JSON["items"] as? [[String: AnyObject]] else {
			throw LinkLoadingError.InvalidFile
		}
		
		links.removeAll()
		for linkJSON in linksJSON {
			guard let
				title = linkJSON["title"] as? String,
				URLString = linkJSON["URL"] as? String,
				URL = NSURL(string: URLString)
				else
			{
				continue
			}
			
			let link = Link(title: title, URL: URL)
			links.append(
				link
			)
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func linkForIndexPath(indexPath: NSIndexPath) -> Link {
		return links[indexPath.indexAtPosition(1)]
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return links.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("link", forIndexPath: indexPath) as! ItemTableViewCell
		
		let link = linkForIndexPath(indexPath)
		cell.titleLabel.text = link.title
		
		return cell
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let link = linkForIndexPath(indexPath)
		
		print("didSelectRowAtIndexPath \(link)")
			
		safariViewController = SFSafariViewController(URL: link.URL, entersReaderIfAvailable: false)
		safariViewController.delegate = self
		presentViewController(safariViewController, animated: true, completion: nil)
	}
}

extension FirstViewController: SFSafariViewControllerDelegate {
	func safariViewControllerDidFinish(controller: SFSafariViewController) {
		controller.dismissViewControllerAnimated(true, completion: nil)
	}
}