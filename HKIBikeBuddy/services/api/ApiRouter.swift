//
//  ApiRouter.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 22.4.2021.
//

import Foundation

class ApiRouter<T: Decodable> {

    private let session: URLSession

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }

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
                    Log.e("data check fail")
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
