//
//  SearchViewController.swift
//  SearchAppStore
//
//  Created by manohara reddy p on 10/10/17.
//  Copyright © 2017 manohara reddy p. All rights reserved.
//

import Cocoa

class SearchViewController: NSViewController {

    @IBOutlet var arrayController: NSArrayController!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var searchBar: NSSearchField!
    
    @IBOutlet weak var searchIndicator: NSProgressIndicator!
    @objc dynamic var enableSearchButton = false
    var tracks:[Track] = []
    let queryService = QueryService()
   
    @IBAction func search(_ sender: NSButton) {
        searchiTunes()
    }
    
    func searchiTunes(){
        self.searchIndicator.isHidden = false
        self.searchIndicator.startAnimation(nil)
        let searchText = searchBar.stringValue
        queryService.getSearchResultsFor(searchText) { (result) in
            self.searchIndicator.isHidden = true
            self.searchIndicator.stopAnimation(nil)
            switch result {
            case .data(let tracks) :
                self.tracks = tracks
                self.arrayController.content = tracks
            case .error(let errorMessage):
                self.alertUser(with: errorMessage)
            }
        }
    }
    
    func alertUser(with message:String) {
        let alert = NSAlert.init()
        alert.messageText = "Error!"
        alert.informativeText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
   
}

//MARK:- NSSearchFieldDelegate
extension SearchViewController: NSSearchFieldDelegate {
    
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
      enableSearchButton = true
    }
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
      enableSearchButton = false
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            searchiTunes()
            return true
        }
        return false
    }
}

//MARK:- NSTableViewDelegate
extension SearchViewController : NSTableViewDelegate {
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let result = arrayController.selectedObjects.first as? Track else { return }
        result.loadImage()
    }
   
}


