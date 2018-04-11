//
//  NetworkClient.swift
//  Virtual Tourist
//
//  Created by Phuc Tran on 4/10/18.
//  Copyright © 2018 Phuc Tran. All rights reserved.
//

import Foundation
import UIKit
class NetworkClient: NSObject {
    
    // shared session
    var session = URLSession.shared
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    func makeRequest<T: Decodable>(_ request: APIRequest, type: T.Type, completion: @escaping (_ data: T?, _ error : String?) -> Void) -> URLSessionDataTask?{
        guard let urlRequest = request.urlRequest else { return nil}
        print(urlRequest)
        let task = session.dataTask(with: urlRequest) { data, response, error in
            
            func sendError(_ error: String) {
                print(error)
                performUIUpdatesOnMain {
                    completion(nil, error)
                }
                
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError(error!.localizedDescription)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                sendError("Request did not return a valid response.")
                return
            }
            
            switch (statusCode) {
            case 403:
                sendError("Please check your credentials and try again.")
                return
            case 200 ..< 299:
                break
            default:
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            let newData = data
            do {
                let photoObject = try JSONDecoder().decode(type, from: newData)
                performUIUpdatesOnMain {
                    completion(photoObject, nil)
                }
                print(String(data: newData, encoding: .utf8)!)
            } catch {
                
                completion(nil, error.localizedDescription)
            }
           

        }
        task.resume()
        return task
    }
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    
    func downloadImage(url: URL, imageView: UIImageView, result: @escaping (_ result: Data?, _ error: String?) -> Void) {
        print("Download Started")
        getDataFromUrl(url: url) { data, response, error in
            func sendError(_ error: String?) {
                
                performUIUpdatesOnMain {
                    result(nil, error)
                }
                
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError(error!.localizedDescription)
                return
            }
            
            performUIUpdatesOnMain {
                result(data, nil)
            }
        }
    }
    
    func doSearchPhotos(latitude: Double, longitude: Double, completion: @escaping (_ data: PhotosParser?, _ error : String?) -> Void) {
        makeRequest(.searchPhotos(latitude: latitude, longitude: longitude), type: PhotosParser.self, completion: completion)
    }
    
    static let shared = NetworkClient()
}
