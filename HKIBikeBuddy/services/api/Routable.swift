//
//  Routable.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 22.4.2021.
//

import Foundation

protocol Routable {

    var url: URL { get }
    var method: HTTPMethod { get }
    var endPoint: String { get }
    var headers: [String: String] { get }
    var body: Data? { get }
    var request: URLRequest { get }

}

enum HTTPMethod: String {
    case POST
    case GET
}
