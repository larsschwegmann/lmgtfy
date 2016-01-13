//
//  main.swift
//  lmgtfy
//
//  Created by Lars on 13.01.16.
//  Copyright © 2016 larsschwegmann.com. All rights reserved.
//

//////////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////////

import Foundation
import CommandLine

#if os(OSX)
import AppKit
#endif

//////////////////////////////////////////////////////////////////////////////
// Start of CLT
//////////////////////////////////////////////////////////////////////////////

//Init CLI

let cli = CommandLine()

let searchQuery = StringOption(shortFlag: "q", longFlag: "query", required: false, helpMessage: "Search Query for the Google Search. \"lmgtfy <query>\" also works.")

let pasteToClipboard = BoolOption(shortFlag: "c", longFlag: "clipboard", required: false, helpMessage: "Option to copy generated link to clipboard. Defaults to Y.")

let feelingLucky = BoolOption(shortFlag: "l", longFlag: "feeling-lucky", required: false, helpMessage: "Option to use the \"I'm feeling lucky\" button.")

cli.addOptions(searchQuery, pasteToClipboard, feelingLucky)

//Parse CLI Options

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

let strayValues = cli.strayValues

if (!searchQuery.wasSet && strayValues.count == 0) {
    //No query supplied
    cli.printUsage()
    exit(EX_USAGE)
}

var query = ""

if (searchQuery.wasSet) {
    query = searchQuery.value!
} else {
    query = strayValues[0]
}

//Create lmgtfy URL
let escapedQuery = query.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!.stringByReplacingOccurrencesOfString("%20", withString: "+")
let baseURLString = "http://lmgtfy.com/?q="
var URLString = "\(baseURLString)\(escapedQuery)"

if (feelingLucky.wasSet && feelingLucky.value) {
    //Set "I'm feeling lucky" option
    URLString = URLString.stringByAppendingString("&l=1")
}

print(URLString)

if (!pasteToClipboard.wasSet || pasteToClipboard.value) {
    //Paste generated URL to system clipboard
#if os(OSX)
    var pasteBoard = NSPasteboard.generalPasteboard()
    pasteBoard.clearContents()
    pasteBoard.writeObjects([URLString])
    print("Link copied to clipboard!")
#endif
}
