//
//  HttpMethod.swift
//  Antonym
//
//  Created by 広瀬緑 on 2016/10/29.
//  Copyright © 2016年 midori hirose. All rights reserved.
//

import UIKit
import AVFoundation

final class NetworkEngine {
    var antonym = ""
    private let talker = AVSpeechSynthesizer()

    func getAsync(text: String) {
        let urlString = "http://antonym.herokuapp.com/api/antonyms/?phrase=" + uriEncode(text: text)
        guard let url = URL(string: urlString) else {
            return
        }
        var request = NSMutableURLRequest(url: url) as URLRequest
        request.httpMethod = "GET"
        
        // use NSURLSessionDataTask
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if (error == nil) {
                let json = try! JSONSerialization.jsonObject(with: data!, options: []) as? [String:[[String:AnyObject]]]
                guard let phrases = json?["phrases"] else {
                    return
                }
                for phrase in phrases {
                    guard let antonyma = phrase["antonym"]  as? String else {
                        return
                    }
                    self.antonym = antonyma
                    self.speech(text: self.antonym)
                    print(self.antonym)
                }
            } else {
                print(error)
            }
        })
        task.resume()
    }
    
//    func fetchData(text: String) -> String {
//        //Construct url object via string
//        let urlString = "http://antonym.herokuapp.com/api/antonyms/?phrase=" + uriEncode(text: text)
//        var url = NSURL(string: urlString)
//        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
//            guard error == nil else {
//                print(error)
//                return
//            }
//            guard let data = data else {
//                print("Data is empty")
//                return
//            }
//            
//            let json = try! JSONSerialization.jsonObject(with: data, options: [])
//            print(json)
//        }
//        task.resume()
//        return text
//    }
    
    func uriEncode(text: String) -> String {
        return text.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.alphanumerics)!
    }
    
    private func speech(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        setOptionsForSpeech(utterance: utterance)
        self.talker.speak(utterance)
    }
    
    private func setOptionsForSpeech(utterance: AVSpeechUtterance) {
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.pitchMultiplier = 0.8
        utterance.rate = 0.1
    }
}
