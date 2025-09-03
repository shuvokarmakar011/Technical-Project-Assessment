//
//  NetworkService.swift
//  SecureUserDirectory
//
//  Created by Shuvo on 3/9/25.
//

import Foundation
import Combine

protocol NetworkServiceProtocol {
    func performRequest<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error>
}

class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func performRequest<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
