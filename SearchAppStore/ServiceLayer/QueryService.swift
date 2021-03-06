//
//  QueryService.swift
//  SearchAppStore
//
//  Created by manohara reddy p on 10/10/17.
//  Copyright © 2017 manohara reddy p. All rights reserved.
//

import Foundation
import Cocoa

enum SearchResult<T> {
  case data([T])
  case error(String)
}

typealias JSONDictionary = [String: Any]


class QueryService {
    
    typealias QueryResult = (SearchResult<Track>) -> ()
    var dataTask: URLSessionDataTask?
    
    
    /// Creates URL using user searched text
    ///
    /// - Parameter searchText: user searched text
    /// - Returns: url if possible to create `else` `nil`
    private func urlFrom(_ searchText:String) -> URL? {
        
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format: "https://itunes.apple.com/search?media=music&entity=song&term=%@", escapedSearchText)
        return URL(string: urlString)
    }
    
    
    /// Makes API call to get tracks for searched text
    ///
    /// - Parameters:
    ///   - searchTerm: user searched text
    ///   - completion: returns error or array of Tracks
    func getSearchResultsFor(_ searchTerm: String, completion: @escaping QueryResult) {
        
        dataTask?.cancel()
        guard let url = urlFrom(searchTerm) else {return}
        dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            defer { self.dataTask = .none }
            if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                let result = self.createTacksFrom(data)
                DispatchQueue.main.async {
                    completion(result)
                }
            } else if let error = error {
                DispatchQueue.main.async {
                completion(.error(error.localizedDescription))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.error("Internal server error"))
                }
            }
        }
        dataTask?.resume()
    }
    
    /// Check for the results date
    ///
    /// - Parameter data: Received data
    /// - Returns: result which contains error or search results array
    func createTacksFrom(_ data: Data) -> SearchResult<Track> {
        
        guard let response = try? JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary,
            let tracks = response?["results"] as? [JSONDictionary] else {return .error("Dictionary does not contain results key\n") }
        return .data(tracks.map{Track(dictionary: $0)}.flatMap{$0})
    }
    
    
    /// Downloades Image for the URL string
    ///
    /// - Parameters:
    ///   - imageURL: url string received from the server
    ///   - completionHandler: returns image else nil for the URL
    static func downloadImage(_ imageURLString: String, completionHandler: @escaping (NSImage?) -> Void) {
        
        guard let url = URL(string: imageURLString) else {
            completionHandler(.none)
            return
        }
         URLSession.shared.dataTask(with: url){ (data, _, _) -> Void in
            completionHandler(data.flatMap({NSImage(data: $0)}))
        }.resume()
    }
}
