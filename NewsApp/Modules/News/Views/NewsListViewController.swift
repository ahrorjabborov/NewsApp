//
//  NewsListViewController.swift
//  NewsApp
//
//  Created by Ahror Jabborov on 1/23/25.
//

import UIKit
import Combine
import SnapKit

final class NewsListViewController: UIViewController {
    
    private let viewModel: NewsViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton(type: .system)
        let img = UIImage(systemName: "magnifyingglass")?.withRenderingMode(.alwaysTemplate)
        button.setImage(img, for: .normal)
        button.tintColor = UIColor(hex: "0A2D73")
        button.addTarget(self, action: #selector(didTapSearch), for: .touchUpInside)
        return button
    }()
    
    private lazy var headerContainerView: UIView = {
        let container = UIView()
        return container
    }()
    
    private lazy var firstLineStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [logoImageView, newsTitleLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "app_logo")?.withRenderingMode(.alwaysTemplate))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(hex: "0A2D73")
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }
        return imageView
    }()
    
    private lazy var newsTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .black
        label.text = "News"
        return label
    }()
    
    private lazy var secondLineLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = UIColor(hex: "A9A9A9")
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var titleStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [firstLineStack, secondLineLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 4
        return stack
    }()
    
    private lazy var tableView: UITableView = {
        let tbl = UITableView(frame: .zero, style: .plain)
        tbl.backgroundColor = .white
        tbl.separatorStyle = .none
        tbl.showsVerticalScrollIndicator = false
        tbl.register(NewsTableViewCell.self,
                     forCellReuseIdentifier: NewsTableViewCell.identifier)
        tbl.register(SkeletonNewsTableViewCell.self,
                     forCellReuseIdentifier: SkeletonNewsTableViewCell.identifier)
        
        tbl.dataSource = self
        tbl.delegate = self
        tbl.rowHeight = 180
        tbl.estimatedRowHeight = 180
        tbl.refreshControl = refreshControl
        return tbl
    }()
    
    private lazy var noResultsLabel: UILabel = {
        let label = UILabel()
        label.text = "No results to display."
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    // MARK: - Init
    
    init(viewModel: NewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupLayout()
        bindViewModel()
        
        // Initial fetch => default "politics" from VM
        viewModel.fetchNews { [weak self] errorMsg in
            self?.showAlert(title: "Error", message: errorMsg)
        }
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        // Header
        view.addSubview(headerContainerView)
        headerContainerView.addSubview(titleStackView)
        headerContainerView.addSubview(searchButton)
        
        headerContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        
        titleStackView.snp.makeConstraints { make in
            make.top.equalTo(headerContainerView.snp.top).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualTo(searchButton.snp.leading).offset(-8)
        }
        
        searchButton.snp.makeConstraints { make in
            make.centerY.equalTo(firstLineStack)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        headerContainerView.snp.makeConstraints { make in
            make.bottom.equalTo(titleStackView.snp.bottom).offset(8)
        }
        
        // Table
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerContainerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        // "No Results" label above the table, centered
        view.addSubview(noResultsLabel)
        noResultsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    // MARK: - ViewModel Binding
    
    private func bindViewModel() {
        
        // 1) Articles
        viewModel.$articles
            .receive(on: DispatchQueue.main)
            .sink { [weak self] articles in
                guard let self = self else { return }
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
                
                let isEmpty = articles.isEmpty
                let loading = self.viewModel.isLoading
                self.noResultsLabel.isHidden = !isEmpty || loading
            }
            .store(in: &cancellables)
        
        // 2) Visits
        viewModel.$visits
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        // 3) isLoading
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                self?.tableView.reloadData()
                
                if loading {
                    self?.noResultsLabel.isHidden = true
                } else {
                    let isEmpty = self?.viewModel.articles.isEmpty ?? false
                    self?.noResultsLabel.isHidden = !isEmpty
                }
            }
            .store(in: &cancellables)
        
        // 4) Offline/Online - for the title
        viewModel.$isOffline
            .receive(on: DispatchQueue.main)
            .sink { [weak self] offline in
                guard let self = self else { return }
                
                let df = DateFormatter()
                df.dateFormat = "MMMM d"
                let dateString = df.string(from: Date())
                let status = offline ? "Offline" : "Online"
                self.secondLineLabel.text = "\(dateString) - \(status)"
                
            }
            .store(in: &cancellables)
        
        // 5) fetchError => show alert
        viewModel.$fetchError
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errMsg in
                self?.showAlert(title: "Error", message: errMsg)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    @objc private func didPullToRefresh() {
        if viewModel.isOffline {
            refreshControl.endRefreshing()
            showAlert(title: "Error", message: "No Internet Connection")
            return
        }
        viewModel.fetchNews(reset: true) { [weak self] errorMsg in
            self?.refreshControl.endRefreshing()
            self?.showAlert(title: "Error", message: errorMsg)
        }
    }
    
    @objc private func didTapSearch() {
        let alert = UIAlertController(
            title: "Search",
            message: "Enter a news query",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "e.g. Apple, Economy, Sports"
        }
        
        let searchAction = UIAlertAction(title: "Search", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let text = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let q = text, !q.isEmpty {
                self.fetchWithCustomQuery(q)
            } else {
                // If empty, revert to "politics"
                self.fetchWithCustomQuery("politics")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(searchAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func fetchWithCustomQuery(_ query: String) {
        viewModel.fetchCustomQuery(query) { [weak self] errorMsg in
            self?.showAlert(title: "Error", message: errorMsg)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension NewsListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let articleCount = viewModel.articles.count
        // Skeleton rows for the next "page" while loading
        let skeletonCount = viewModel.skeletonCountForThisLoad
        
        if articleCount == 0 {
            return skeletonCount
        } else {
            return articleCount + skeletonCount
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let articleCount = viewModel.articles.count
        let skeletonCount = viewModel.skeletonCountForThisLoad
        
        if articleCount == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SkeletonNewsTableViewCell.identifier,
                for: indexPath
            ) as? SkeletonNewsTableViewCell else {
                return UITableViewCell()
            }
            cell.startShimmer()
            return cell
        }
        
        let lastArticleIndex = articleCount - 1
        
        if indexPath.row <= lastArticleIndex {
            // Normal article cell
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NewsTableViewCell.identifier,
                for: indexPath
            ) as? NewsTableViewCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            let article = viewModel.articles[indexPath.row]
            let count = viewModel.viewCount(for: article)
            cell.configure(with: article, viewCount: count)
            return cell
        } else {
            // Skeleton cell (for the "next page" load)
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SkeletonNewsTableViewCell.identifier,
                for: indexPath
            ) as? SkeletonNewsTableViewCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.startShimmer()
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension NewsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let articleCount = viewModel.articles.count
        // If tap on skeleton, ignore
        if indexPath.row >= articleCount {
            return
        }
        
        let article = viewModel.articles[indexPath.row]
        viewModel.selectArticle(article)
        
        let detailVC = NewsDetailViewController(viewModel: viewModel)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY + height >= contentHeight - 200,
           !viewModel.isLoading {
            // If offline, skip
            if viewModel.isOffline { return }
            
            viewModel.fetchNews(reset: false) { [weak self] errorMsg in
                self?.showAlert(title: "Error", message: errorMsg) // can be annoying due to api limitations
            }
        }
    }
}
