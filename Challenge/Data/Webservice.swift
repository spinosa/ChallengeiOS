//
//  Webservice.swift
//  Challenge
//
//  Created by Daniel Spinosa on 6/18/18.
//  Copyright © 2018 Cromulent Consulting, Inc. All rights reserved.
//

import Foundation

final class Webservice {

    let useCurrentUserAuthHeader:Bool
    static let forCurrentUser = Webservice(useCurrentUser: true)

    init(useCurrentUser: Bool = false) {
        self.useCurrentUserAuthHeader = useCurrentUser
    }

    func load<A>(_ resource: Resource<A>, completion: @escaping (A?) -> ()) {
        var urlRequest = URLRequest(url: resource.url)
        decorateHeaders(&urlRequest)

        URLSession.shared.dataTask(with: urlRequest) { (data, _, _) in
            let result = data.flatMap(resource.parse)
            completion(result)
        }.resume()
    }

    func post<A>(_ resource: Resource<A>, instance: A? = nil, completion: @escaping (A?, URLResponse?) -> ()) {
        var urlRequest = URLRequest(url: resource.url)
        decorateHeaders(&urlRequest)
        urlRequest.httpMethod = "POST"
        if let instance = instance {
            urlRequest.httpBody = resource.encode(instance)
        }

        URLSession.shared.dataTask(with: urlRequest) { (data, response, _) in
            let result = data.flatMap(resource.parse)
            completion(result, response)
        }.resume()
    }

    func patch<A>(_ resource: Resource<A>, instance: A, completion: @escaping (A?, URLResponse?) -> ()) {
        var urlRequest = URLRequest(url: resource.url)
        decorateHeaders(&urlRequest)
        urlRequest.httpMethod = "PATCH"
        urlRequest.httpBody = resource.encode(instance)

        URLSession.shared.dataTask(with: urlRequest) { (data, response, _) in
            let result = data.flatMap(resource.parse)
            completion(result, response)
            }.resume()
    }

    private func decorateHeaders(_ urlRequest: inout URLRequest) {
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if useCurrentUserAuthHeader,
            let user = User.currentUser,
            let jwt = user.authorizationHeader {
            urlRequest.setValue(jwt, forHTTPHeaderField: "Authorization")
        }
    }
}

struct Resource<A> {
    let url: URL
    let parse: (Data) -> A?
    let encode: (A) -> Data?
}

extension Resource where A: Codable {
    init(url: URL, parser: ((Data) -> A?)? = nil, encoder: ((A) -> Data?)? = nil) {
        self.url = url
        if let parser = parser {
            self.parse = parser
        }
        else {
            self.parse = {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                do {
                    let d = try decoder.decode(A.self, from: $0)
                    return d
                }
                catch {
                    print("error decoding!")
                    print(error)
                }
                return nil
            }
        }
        if let encoder = encoder {
            self.encode = encoder
        }
        else {
            self.encode = {
                let encoder = JSONEncoder()
                encoder.keyEncodingStrategy = .convertToSnakeCase
                encoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601Full)
                return try? encoder.encode($0)
            }
        }
    }
}
