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

    //TODO: Refactor to take success & failure blocks (like post<A>)::::)
    func load<A>(_ resource: Resource<A>, completion: @escaping (A?) -> ()) {
        var urlRequest = URLRequest(url: resource.url)
        decorateHeaders(&urlRequest)

        URLSession.shared.dataTask(with: urlRequest) { (data, _, _) in
            let result = data.flatMap(resource.parse)
            completion(result)
        }.resume()
    }

    func post<A>(_ resource: Resource<A>, instance: A? = nil, success: @escaping (A, HTTPURLResponse) -> (), failure: @escaping (ErrorResponse) -> ()) {
        var urlRequest = URLRequest(url: resource.url)
        decorateHeaders(&urlRequest)
        urlRequest.httpMethod = "POST"
        if let instance = instance {
            urlRequest.httpBody = resource.encode(instance)
        }

        URLSession.shared.dataTask(with: urlRequest) { (data, response, _) in
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200..<300:
                    if let result = data.flatMap(resource.parse) {
                        success(result, httpResponse)
                    }
                    else {
                        assertionFailure("could not parse Resource included with valid response")
                        failure(ErrorResponse.unparsable)
                    }
                //TODO: Handle expired authorization
                default:
                    if let errorResult = ErrorResponse.parse(data) {
                        failure(errorResult)
                    }
                    else {
                        assertionFailure("could not parse ErrorResponse included with error response")
                        failure(ErrorResponse.unparsable)
                    }
                }
            }
            else {
                assertionFailure("expected HTTPSURLResponse")
                failure(ErrorResponse.generic)
            }

        }.resume()
    }

    //TODO: Refactor to take success & failure blocks (like post<A>)::::)
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

    //TODO: Refactor to take success & failure blocks (like post<A>)::::)
    func delete<A>(_ resource: Resource<A>, instance: A, completion: @escaping (URLResponse?) -> ()) {
        var urlRequest = URLRequest(url: resource.url)
        decorateHeaders(&urlRequest)
        urlRequest.httpMethod = "DELETE"
        urlRequest.httpBody = resource.encode(instance)

        URLSession.shared.dataTask(with: urlRequest) { (data, response, _) in
            //delete returns nil object or errors
            completion(response)
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

/// All API response errors are returned with a JSON body
struct ErrorResponse: Codable {
    // General errors
    var error: String?
    // Model/form errors, generally from ActiveRecord (ie. "email can't be blank")
    var errors: [String: [String]]?

    // A couple of terribly unhelpful errors
    // Should not be used unless the situation is an assertion failure (ie. programming error on API or in this app)
    static let unparsable = ErrorResponse(error: "Please make sure this app is updated and/or try again later.", errors: nil)
    static let generic = ErrorResponse(error: "Please make sure this app is updated and/or try again later.", errors: nil)

    static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        return d
    }()

    static func parse(_ data: Data?) -> ErrorResponse? {
        guard let data = data else { return nil }
        do {
            return try decoder.decode(self, from: data)
        }
        catch {
            print("error decoding error response.  heh.")
            print(error)
            return nil
        }
    }
}
