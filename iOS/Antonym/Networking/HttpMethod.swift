//
//  HttpMethod.swift
//  Antonym
//
//  Created by 広瀬緑 on 2016/10/29.
//  Copyright © 2016年 midori hirose. All rights reserved.
//

import UIKit

final class NetworkEngine {
    
    func getAsync(text: String) {
        let urlDomainString = "http://townantonym.herokuapp.com/api/antonyms/?phrase=" + text
        guard let urlDomain = URL(string: urlDomainString) else {
            return
        }
        var request = NSMutableURLRequest(url: urlDomain) as URLRequest
        request.httpMethod = "GET"
        
        // use NSURLSessionDataTask
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if (error == nil) {
                let result = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
                print(result)
            } else {
                print(error)
            }
        })
        task.resume()
    }
}
