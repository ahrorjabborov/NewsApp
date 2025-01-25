//
//  NewsViewModel.swift
//  NewsApp
//
//  Created by Ahror Jabborov on 1/23/25.
//

import Combine
import Foundation
import Reachability

final class NewsViewModel: ObservableObject {
    
    @Published var articles: [Article] = []
    @Published var isLoading: Bool = false
    @Published private(set) var visits: [String: Int] = [:]
    @Published var selectedArticle: Article?
    @Published var fetchError: String? = nil
    
    @Published private(set) var isOffline = false
    
    private var currentPage = 1
    private let pageSize = 20
    
    private lazy var dateFormatter: ISO8601DateFormatter = {
        let format = ISO8601DateFormatter()
        return format
    }()
    
    // For counting visits
    private var viewCounts: [String: Int] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    private let newsService: NewsAPIService
    private let reachability = try? Reachability()
    
    // For persisting view counts
    private let userDefaultsKey = "ArticleVisitCounts"
    
    // For knowing if we've loaded everything
    private var totalResults = 0
    private var hasReachedEnd = false
    
    // So we only show the "No Internet" alert once
    private var hasShownOfflineAlert = false
    
    init(newsService: NewsAPIService) {
        self.newsService = newsService
        loadVisitsFromUserDefaults()
        setupReachabilityObserver()
    }
    
    // MARK: - Fetch Logic
    
    // uses query to search for specific keyword
    // reset works on all - query, articles, pagination
    
    func fetchNews(reset: Bool = false, onError: @escaping (String) -> Void) {
        
        // 1) If we're already loading, do nothing
        guard !isLoading else { return }
        
        // 2) If offline, show alert once
        if isOffline {
            if !hasShownOfflineAlert {
                onError("No Internet Connection")
                hasShownOfflineAlert = true
            }
            return
        }
        
        // 3) Handle reset scenario
        if reset {
            currentPage = 1
            articles.removeAll()
            hasReachedEnd = false
            totalResults = 0
        } else {
            if totalResults > 0 {
                let totalPages = Int(ceil(Double(totalResults) / Double(pageSize)))
                if currentPage > totalPages {
                    hasReachedEnd = true
                    return
                }
            }
            
            if hasReachedEnd {
                return
            }
        }
        
        isLoading = true
        fetchError = nil
        
        newsService.fetchEverything(query: "politics", page: currentPage, pageSize: pageSize)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.fetchError = error.localizedDescription
                    onError(error.localizedDescription)
                }
                
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                
                if let total = response.totalResults {
                    self.totalResults = total
                }
                
                let existingURLs = Set(self.articles.map(\.url))
                let incoming = response.articles.filter { !existingURLs.contains($0.url) }
                
                // If incoming is empty => no more content
                if incoming.isEmpty {
                    self.hasReachedEnd = true
                } else {
                    self.articles.append(contentsOf: incoming)
                    self.currentPage += 1
                }
                
                // If we've fetched everything
                if self.totalResults > 0, self.articles.count >= self.totalResults {
                    self.hasReachedEnd = true
                }
            }
            .store(in: &cancellables)
    }
    
    // sorting func, not needed anymore
    private func sortArticlesByDateDesc() {
        articles.sort { a, b in
            let dateA = dateFormatter.date(from: a.publishedAt ?? "") ?? .distantPast
            let dateB = dateFormatter.date(from: b.publishedAt ?? "") ?? .distantPast
            return dateA > dateB
        }
    }
    
    // MARK: - Visits
    
    func incrementViewCount(for article: Article) {
        viewCounts[article.url, default: 0] += 1
        visits = viewCounts
        saveVisitsToUserDefaults()
    }
    
    func viewCount(for article: Article) -> Int {
        viewCounts[article.url, default: 0]
    }
    
    func selectArticle(_ article: Article) {
        selectedArticle = article
        incrementViewCount(for: article)
    }
    
    // MARK: - Persistence
    
    private func loadVisitsFromUserDefaults() {
        if let saved = UserDefaults.standard.dictionary(forKey: userDefaultsKey) as? [String: Int] {
            viewCounts = saved
            visits = saved
        }
    }
    
    private func saveVisitsToUserDefaults() {
        UserDefaults.standard.setValue(viewCounts, forKey: userDefaultsKey)
    }
    
    // MARK: - Reachability
    
    private func setupReachabilityObserver() {
        reachability?.whenReachable = { [weak self] _ in
            self?.isOffline = false
            self?.hasShownOfflineAlert = false
        }
        reachability?.whenUnreachable = { [weak self] _ in
            self?.isOffline = true
        }
        try? reachability?.startNotifier()
    }
    
    // MARK: - Skeleton Helpers
    
    var skeletonCountForThisLoad: Int {
        if hasReachedEnd || !isLoading {
            return 0
        }
        
        guard totalResults > 0 else {
            return pageSize
        }
        let remaining = totalResults - articles.count
        return max(0, min(pageSize, remaining))
    }
    
    // MARK: - Detail VC Helpers
    
    var detailTitle: String {
        selectedArticle?.title ?? ""
    }
    var detailDescription: String? {
        selectedArticle?.description
    }
    var detailImageURL: String? {
        selectedArticle?.urlToImage
    }
    var detailPublishDate: String {
        selectedArticle?.publishedAt ?? ""
    }
    var detailSourceName: String {
        selectedArticle?.source.name ?? ""
    }
    var detailFullArticleURL: String {
        selectedArticle?.url ?? ""
    }
}

extension NewsViewModel {
    // for using default queries
    func fetchCustomQuery(_ newQuery: String, onError: @escaping (String) -> Void) {
        // 1) Reset
        self.currentPage = 1
        self.articles.removeAll()
        self.hasReachedEnd = false
        self.totalResults = 0
        
        // 2) call the same fetch but with the custom query
        isLoading = true
        fetchError = nil
        
        newsService.fetchEverything(query: newQuery, page: currentPage, pageSize: pageSize)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.fetchError = error.localizedDescription
                    onError(error.localizedDescription)
                }
                
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                
                if let total = response.totalResults {
                    self.totalResults = total
                }
                
                let incoming = response.articles
                if incoming.isEmpty {
                    self.hasReachedEnd = true
                } else {
                    self.articles = incoming
                    self.currentPage += 1
                }
                
                if self.totalResults > 0, self.articles.count >= self.totalResults {
                    self.hasReachedEnd = true
                }
            }
            .store(in: &cancellables)
    }
}
