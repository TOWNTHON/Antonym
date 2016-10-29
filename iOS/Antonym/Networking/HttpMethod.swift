//
//  HttpMethod.swift
//  Antonym
//
//  Created by 広瀬緑 on 2016/10/29.
//  Copyright © 2016年 midori hirose. All rights reserved.
//

enum HttpMethod<Body> {
    case get
    case post(Body)
}

extension HttpMethod {
    var string: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        }
    }
}

extension HttpMethod {
    func map<T> (f: (Body) -> T) -> HttpMethod<T> {
        switch self {
        case .get:
            return .get
        case .post(let body):
            return .post(f(body))
        }
    }
}
