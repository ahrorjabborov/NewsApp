//
//  NetworkManager.swift
//  NewsApp
//
//  Created by Ahror Jabborov on 1/23/25.
//

import Foundation
import Combine

// this is main network manager

enum NewsEndpoint {
    case topHeadlines(
        country: String,
        category: String?,
        page: Int,
        pageSize: Int
    )
    case everything(
        query: String,
        page: Int,
        pageSize: Int,
        sortBy: String
    )
    
    private var baseURL: String {
        "https://newsapi.org/v2"
    }
    
    func urlRequest(apiKey: String) throws -> URLRequest {
        let urlString: String
        var queryItems = [URLQueryItem(name: "apiKey", value: apiKey)]
        
        switch self {
        case .topHeadlines(let country, let category, let page, let pageSize):
            urlString = baseURL + "/top-headlines"
            queryItems.append(contentsOf: [
                URLQueryItem(name: "country", value: country),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "pageSize", value: String(pageSize))
            ])
            if let category = category {
                queryItems.append(URLQueryItem(name: "category", value: category))
            }
            
        case .everything(let query, let page, let pageSize, let sortBy):
            urlString = baseURL + "/everything"
            queryItems.append(contentsOf: [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "pageSize", value: String(pageSize)),
                URLQueryItem(name: "sortBy", value: sortBy)
            ])
        }
        
        guard var urlComponents = URLComponents(string: urlString) else {
            throw URLError(.badURL)
        }
        
        urlComponents.queryItems = queryItems
        guard let finalURL = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        return request
    }
}

final class NewsAPIService {
    
    private let apiKey: String
    private let apiClient: APIClient
    
    init(apiKey: String, apiClient: APIClient = DefaultAPIClient()) {
        self.apiKey = apiKey
        self.apiClient = apiClient
    }
    
    func fetchTopHeadlines(
        country: String = "us",
        category: String? = nil,
        page: Int = 1,
        pageSize: Int = 20
    ) -> AnyPublisher<NewsAPIResponse, Error> {
        
        do {
            let request = try NewsEndpoint.topHeadlines(
                country: country,
                category: category,
                page: page,
                pageSize: pageSize
            ).urlRequest(apiKey: apiKey)
            
            return apiClient.run(request)
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    func fetchEverything(
        query: String,
        page: Int = 1,
        pageSize: Int = 20,
        sortBy: String = "publishedAt"
    ) -> AnyPublisher<NewsAPIResponse, Error> {
        
        do {
            let request = try NewsEndpoint.everything(
                query: query,
                page: page,
                pageSize: pageSize,
                sortBy: sortBy
            ).urlRequest(apiKey: apiKey)
            
            return apiClient.run(request)
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
}
