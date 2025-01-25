//
//  APIService.swift
//  NewsApp
//
//  Created by Ahror Jabborov on 1/23/25.
//

import Combine
import Foundation

//generic api calling client 
protocol APIClient {
    func run<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error>
}

final class DefaultAPIClient: APIClient {
    
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func run<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        
        return urlSession.dataTaskPublisher(for: request)
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
