//
//  ApolloNetwokClient.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 1.4.2021.
//

import Foundation
import Apollo
import ApolloWebSocket

class ApolloNetworkClient {
    static let shared = ApolloNetworkClient()
    let url = "https://api.digitransit.fi/routing/v1/routers/hsl/index/graphql"
    private(set) lazy var apollo = ApolloClient(url: URL(string: url)!)
}
