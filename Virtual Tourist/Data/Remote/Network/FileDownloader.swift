//
//  FileDownloader.swift
//  Virtual Tourist
//
//  Created by Phuc Tran on 4/11/18.
//  Copyright © 2018 Phuc Tran. All rights reserved.
//

import Foundation
import UIKit

class FileDownloader {
    private var tasks: [String: URLSessionDataTask] = [:]
    var session = URLSession.shared
    
    
    func downloadImage(imageUrl: String, result: @escaping (_ result: Data?, _ error: NSError?) -> Void) {
        guard let url = URL(string: imageUrl) else {
            return
        }
        let task = taskForGETMethod(nil, url, parameters: [:]) { (data, error) in
            performUIUpdatesOnMain({
                result(data, error)
            })
            
            self.tasks.removeValue(forKey: imageUrl)
        }
        
        if tasks[imageUrl] == nil {
            tasks[imageUrl] = task
        }
    }
    
    func cancelDownload(_ imageUrl: String) {
        tasks[imageUrl]?.cancel()
        if tasks.removeValue(forKey: imageUrl) != nil {
            print("\(#function) task canceled: \(imageUrl)")
        }
    }
    
    func taskForGETMethod(
        _ method               : String? = nil,
        _ customUrl            : URL? = nil,
        parameters             : [String: String],
        completionHandlerForGET: @escaping (_ result: Data?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 2/3. Build the URL, Configure the request */
        let request: NSMutableURLRequest!
        if let customUrl = customUrl {
            request = NSMutableURLRequest(url: customUrl)
        } else {
            request = NSMutableURLRequest(url: buildURLFromParameters(parameters, withPathExtension: method))
        }
        
        showActivityIndicator(true)
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                self.showActivityIndicator(false)
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            if let error = error {
                
                // the request got canceled
                if (error as NSError).code == URLError.cancelled.rawValue {
                    completionHandlerForGET(nil, nil)
                } else {
                    sendError("There was an error with your request: \(error.localizedDescription)")
                }
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            self.showActivityIndicator(false)
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            completionHandlerForGET(data, nil)
            
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    private func showActivityIndicator(_ show: Bool) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = show
        }
    }
    
    private func buildURLFromParameters(_ parameters: [String: String], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = NetworkConstants.Flickr.APIScheme
        components.host = NetworkConstants.Flickr.APIHost
        components.path = NetworkConstants.Flickr.APIPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: value)
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    static let shared = FileDownloader()
}
