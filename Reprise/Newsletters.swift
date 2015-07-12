//
//  Newsletters.swift
//  Reprise
//
//  Created by Patrick Smith on 5/07/2015.
//  Copyright © 2015 Burnt Caramel. All rights reserved.
//

import Foundation


struct Newsletter {
	typealias Index = Int
	
	let issueIndex: Index
	let URL: NSURL
	//var datePublished: NSDate
}


protocol NewsletterArchiveType: SequenceType {
	typealias Element = Newsletter
	
	var endIssueIndex: Newsletter.Index { get }
	func newsletterAtIssueIndex(Newsletter.Index) -> Newsletter
}


class NewsletterArchiveGenerator<A: NewsletterArchiveType>: AnyGenerator<Newsletter> {
	private var sourceArchive: A
	private var currentIndex: Newsletter.Index = 1
	
	init(sourceArchive: A) {
		self.sourceArchive = sourceArchive
		
		super.init()
	}
	
	override func next() -> Newsletter? {
		if currentIndex > sourceArchive.endIssueIndex {
			return nil
		}
		
		return sourceArchive.newsletterAtIssueIndex(currentIndex++)
	}
}


struct NewsletterArchive: NewsletterArchiveType {
	typealias Index = Newsletter.Index
	
	var endIssueIndex: Index
	private var newsletterURLAtIssueIndex: (index: Index) -> NSURL
	
	init(endIssueIndex: Index, newsletterURLAtIssueIndex: (index: Index) -> NSURL) {
		self.endIssueIndex = endIssueIndex
		self.newsletterURLAtIssueIndex = newsletterURLAtIssueIndex
		
	}
	
	func newsletterAtIssueIndex(index: Index) -> Newsletter {
		return Newsletter(issueIndex: index, URL: newsletterURLAtIssueIndex(index: index))
	}
	
	typealias Generator = AnyGenerator<Newsletter>
	func generate() -> AnyGenerator<Newsletter> {
		return NewsletterArchiveGenerator(sourceArchive: self)
	}
	
	//static var allNewsletters: [Self] { get }
}


enum KnownNewsletter {
	case WebDevelopmentReadingList
	//case MacStoriesWeekly
	
	var archive: NewsletterArchive {
		switch self {
		case .WebDevelopmentReadingList:
			return NewsletterArchive(endIssueIndex: 95) { (index) -> NSURL in
				return NSURL(string: "https://wdrl.info/archive/\(index)/")!
			}
		}
	}
}
