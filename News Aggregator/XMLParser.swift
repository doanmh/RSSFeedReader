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
        arrParseData.removeAll()
        currentDataDictionary.removeAll()
        currentElement = ""
        foundCharacter = ""
        articleFound = false
        isAtom = false
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
        if elementName == "media:content" && articleFound {
            var imgURL = attributeDict["url"]
            imgURL = imgURL!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            currentDataDictionary["media:content"] = imgURL
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
            if currentElement == "description" || currentElement == "content" {
                foundCharacter += string
                currentElement = "description"
                
                let newLine = try! NSRegularExpression(pattern: "\\n*", options: [.CaseInsensitive])
                let imageCharacter = foundCharacter
                let regex = try! NSRegularExpression(pattern: "(<([^>]+)>)", options: [.CaseInsensitive])
                
                foundCharacter = newLine.stringByReplacingMatchesInString(foundCharacter, options: [.ReportCompletion], range: NSMakeRange(0, foundCharacter.characters.count), withTemplate: "")
                foundCharacter = regex.stringByReplacingMatchesInString(foundCharacter, options: [.ReportCompletion], range: NSMakeRange(0, foundCharacter.characters.count), withTemplate: "")
                
                let image = try! NSRegularExpression(pattern: "<img(.*)>", options: [.CaseInsensitive])
                let result = image.firstMatchInString(imageCharacter, options: [.ReportCompletion], range: NSMakeRange(0, imageCharacter.characters.count))
                if (result != nil) {
                    let nssfoundCharacter = imageCharacter as NSString
                    let imageURL = result.map({nssfoundCharacter.substringWithRange($0.range)})
                    let src = try! NSRegularExpression(pattern: "src=\"([^\\s])*", options: [.CaseInsensitive])
                    let srcResult = src.firstMatchInString(imageURL!, options: [], range: NSMakeRange(0, imageURL!.characters.count))
                    let nsimageURL = imageURL! as NSString
                    var imageSRC = srcResult.map({nsimageURL.substringWithRange($0.range)})
                    imageSRC = imageSRC?.substringFromIndex(imageSRC!.startIndex.advancedBy(5))
                    imageSRC = imageSRC?.substringToIndex(imageSRC!.endIndex.advancedBy(-1))
                    currentDataDictionary["media:content"] = imageSRC
                }
            }
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        foundCharacter = foundCharacter.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let specialCharacter = try! NSRegularExpression(pattern: "&([^\\s])*;", options: [.CaseInsensitive])
        let multipleSpace = try! NSRegularExpression(pattern: "\\s\\s+", options: [])
        foundCharacter = specialCharacter.stringByReplacingMatchesInString(foundCharacter, options: [.ReportCompletion], range: NSMakeRange(0, foundCharacter.characters.count), withTemplate: "")
        foundCharacter = multipleSpace.stringByReplacingMatchesInString(foundCharacter, options: [.ReportCompletion], range: NSMakeRange(0, foundCharacter.characters.count), withTemplate: " ")
        if (!foundCharacter.isEmpty) && (currentElement == "title" || currentElement == "link" || currentElement == "pubDate" || currentElement == "description" || currentElement == "media:content")  {
            currentDataDictionary[currentElement] = foundCharacter
            foundCharacter = ""
        }
        if elementName == "item" || elementName == "entry" {
            arrParseData.append(currentDataDictionary)
            print(currentDataDictionary)
            currentDataDictionary.removeAll()
            articleFound = false
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
