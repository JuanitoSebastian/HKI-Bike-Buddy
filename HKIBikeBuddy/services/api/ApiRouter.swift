//
//  ApiRouter.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 22.4.2021.
//

import Foundation

/// A class for performing API requests and decoding the responses to custom types
class ApiRouter<T: Decodable> {

    private let session: URLSession

    /// - Parameter session: The URLSession to use. Defaults to .shared isntance.
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    /// Request data from API and check for errors
    /// - Parameter router: A Routable object providing request data
    /// - Parameter completion: A completion handler for handling possible data and possible errors
    func requestData(
        router: Routable,
        completion: @escaping (_ model: T?, _ error: Error?) -> Void
    ) {
        collectionsRequest(router: router) { (data: Data?, error: Error?) in

            guard error == nil else {
                completion(nil, error)
                return
            }

            guard let properData = data else {
                completion(nil, nil)
                return
            }

            do {
                let model = try JSONDecoder().decode(T.self, from: properData)
                completion(model, nil)
            } catch let error {
                completion(nil, error)
            }

        }
    }

    /// Calls a URLSession dataTask asynchronously with parameters from the router
    /// - Parameter router: A Routable object providing request data
    /// - Parameter completion: A completion handler for handling possible data and possible errors
    private func collectionsRequest(
        router: Routable,
        completion: @escaping (_ data: Data?, _ error: Error?) -> Void
    ) {
        DispatchQueue(label: "NetworkThread").async {
            self.session.dataTask(with: router.request)
            let task = self.session.dataTask(with: router.request, completionHandler: { (data, _, error) in
                completion(data, error)
            })
            task.resume()
        }
    }
}
