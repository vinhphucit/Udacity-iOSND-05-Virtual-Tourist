//
//  NetworkRequest.swift
//  Virtual Tourist
//
//  Created by Phuc Tran on 4/10/18.
//  Copyright © 2018 Phuc Tran. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case update = "UPDATE"
    case delete = "DELETE"
}

enum APIRequest {
    case searchPhotos(latitude: Double, longitude: Double, page: Int)
    // MARK: URL Request
    
    var urlRequest: URLRequest? {
        var request: URLRequest?
        
        if let url = components.url {
            var urlRequest = URLRequest(url: url)
            
            // add method
            urlRequest.httpMethod = method.rawValue
            
            // add headers
            for (key, value) in headers { urlRequest.addValue(value, forHTTPHeaderField: key) }
            
            // add http body
            if let httpBody = httpBody { urlRequest.httpBody = httpBody }
            
            request = urlRequest
        }
        
        return request
    }
    
    // MARK: HTTP body
    
    var httpBody: Data? {
        switch self {
        default:
            return nil
        }
    }
    
    // MARK: HTTP Method
    
    var method: HTTPMethod {
        switch self {
        default:
            return .get
        }
    }
    
    // MARK: Headers
    
    var headers: [String: String] {
        return [:]
    }
    
    // MARK: Components
    
    var components: URLComponents {
        var components = URLComponents()
        components.scheme = NetworkConstants.Flickr.APIScheme
        components.host = NetworkConstants.Flickr.APIHost
        components.path = NetworkConstants.Flickr.APIPath
        components.queryItems = queryItems
        
        return components
    }
    
    // MARK: Query Items
    
    var queryItems: [URLQueryItem] {
        var items = [URLQueryItem]()
        
        switch self {
        case .searchPhotos(let latitude, let longitude, let page):
            items.append(URLQueryItem(name: NetworkConstants.FlickrParamKeys.Method, value: NetworkConstants.FlickrParamValues.SearchMethod))
            items.append(URLQueryItem(name: NetworkConstants.FlickrParamKeys.APIKey, value: NetworkConstants.FlickrParamValues.APIKey))
            items.append(URLQueryItem(name: NetworkConstants.FlickrParamKeys.Extras, value: NetworkConstants.FlickrParamValues.MediumURL))
            items.append(URLQueryItem(name: NetworkConstants.FlickrParamKeys.Format, value: NetworkConstants.FlickrParamValues.ResponseFormat))
            items.append(URLQueryItem(name: NetworkConstants.FlickrParamKeys.SafeSearch, value: NetworkConstants.FlickrParamValues.UseSafeSearch))
            items.append(URLQueryItem(name: NetworkConstants.FlickrParamKeys.PhotosPerPage, value: String(NetworkConstants.FlickrParamValues.PhotosPerPage)))
            items.append(URLQueryItem(name: NetworkConstants.FlickrParamKeys.Page, value: "\(page)"))
             items.append(URLQueryItem(name: NetworkConstants.FlickrParamKeys.NoJSONCallback, value: NetworkConstants.FlickrParamValues.DisableJSONCallback))
            items.append(URLQueryItem(name: NetworkConstants.FlickrParamKeys.BoundingBox, value: MiscUtils.bboxString(latitude: latitude, longitude: longitude)))
        default:
            break
        }
        
        return items
    }
}

