//
//  XMLParser.swift
//  News Aggregator
//
//  Created by Minh Doan on 7/9/16.
//  Copyright © 2016 Paw Studio. All rights reserved.
//

import UIKit

@objc protocol XMLParserDelegate {
    func parsingWasFinished()
}

class XMLParser: NSObject, NSXMLParserDelegate {
    
    var arrParseData = [Dictionary<String, String>]()
    var currentDataDictionary = Dictionary<String, String>()
    var currentElement = ""
    var foundCharacter = ""
    var articleFound = false
    var isAtom = false
    
    var delegate : XMLParserDelegate?
    
    
    func startParsingContents(rssURL: NSURL) {
        let parser = NSXMLParser(contentsOfURL: rssURL)
        parser?.delegate = self
        parser?.parse()
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if (elementName == "entry") {
            isAtom = true
            articleFound = true
        }
        if (elementName == "item") {
            articleFound = true
        }
        currentElement = elementName
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if articleFound {
            if (isAtom) {
                if currentElement == "title" {
                    foundCharacter += string
                }
                if currentElement == "id" {
                    currentElement = "link"
                    foundCharacter += string
                }
                if currentElement == "updated" {
                    currentElement = "pubDate"
                    foundCharacter += string
                }
            } else {
                if currentElement == "title" ||
                    currentElement == "link" || currentElement == "pubDate" {
                    foundCharacter += string
                }
            }
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        foundCharacter = foundCharacter.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if (!foundCharacter.isEmpty) && (currentElement == "title" || currentElement == "link" || currentElement == "pubDate")  {
            print(foundCharacter)
            currentDataDictionary[currentElement] = foundCharacter
            foundCharacter = ""
            if currentDataDictionary.count == 3 {
                arrParseData.append(currentDataDictionary)
                currentDataDictionary.removeAll()
                articleFound = false
            }
        }
    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        print(parseError.description)
    }
    
    func parser(parser: NSXMLParser, validationErrorOccurred validationError: NSError) {
        print(validationError.description)
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        delegate?.parsingWasFinished()
    }

}
