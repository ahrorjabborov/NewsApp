//
//  NewsDetailViewController.swift
//  NewsApp
//
//  Created by Ahror Jabborov on 1/23/25.
//

import UIKit
import SnapKit
import Kingfisher

// this is the detail view
final class NewsDetailViewController: UIViewController {
    
    private let viewModel: NewsViewModel
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .gray
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .gray
        label.textAlignment = .right
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.italicSystemFont(ofSize: 18)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private let linkLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(hex: "0A2D73")
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.textAlignment = .left
        return label
    }()
    
    private let readMoreButton: UIButton = {
        let button = UIButton()
        button.setTitle("Read Full Article", for: .normal)
        button.backgroundColor = UIColor(hex: "0A2D73")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()
    
    private lazy var shareBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareTapped))
    }()
    
    // MARK: - Init
    
    init(viewModel: NewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .never
        setupNavigationBar()
        setupLayout()
        configureUI()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        navigationItem.title = viewModel.detailSourceName
        navigationItem.rightBarButtonItems = [shareBarButtonItem]
    }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        view.addSubview(readMoreButton)
        
        scrollView.addSubview(contentView)
        
        readMoreButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
            make.height.equalTo(50)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(readMoreButton.snp.top).offset(-8)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        let padding: CGFloat = 16
        
        contentView.addSubview(newsImageView)
        newsImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.trailing.equalToSuperview().inset(padding)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(newsImageView.snp.bottom).offset(padding)
            make.leading.trailing.equalToSuperview().inset(padding)
        }
        
        contentView.addSubview(sourceLabel)
        sourceLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(padding)
            make.leading.equalToSuperview().offset(padding)
        }
        
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(sourceLabel.snp.top)
            make.trailing.equalToSuperview().inset(padding)
        }
        
        contentView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(sourceLabel.snp.bottom).offset(padding)
            make.leading.trailing.equalToSuperview().inset(padding)
        }
        
        contentView.addSubview(linkLabel)
        linkLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(padding)
            make.leading.trailing.equalToSuperview().inset(padding)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLink))
        linkLabel.addGestureRecognizer(tapGesture)
        
        readMoreButton.addTarget(self, action: #selector(didTapReadMore), for: .touchUpInside)
    }
    
    // MARK: - Configure
    
    private func configureUI() {
        titleLabel.text = viewModel.detailTitle
        descriptionLabel.text = viewModel.detailDescription
        sourceLabel.text = viewModel.detailSourceName
        dateLabel.text = viewModel.formatDate(from: viewModel.detailPublishDate)
        linkLabel.text = viewModel.detailFullArticleURL
        
        if let urlString = viewModel.detailImageURL {
            newsImageView.isHidden = false
            loadImage(from: urlString)
        } else {
            newsImageView.isHidden = true
            
        }
    }
    
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            //            newsImageView.image = UIImage(systemName: "photo")
            return
        }
        
        newsImageView.kf.setImage(
            with: url,
            options: [
                .processor(RoundCornerImageProcessor(cornerRadius: 12)),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ],
            completionHandler: { [weak self] result in
                switch result {
                case .success(let value):
                    self?.newsImageView.isHidden = false
                    self?.adjustImageViewConstraints(for: value.image)
                case .failure:
                    self?.newsImageView.image = UIImage(systemName: "photo")
                    self?.newsImageView.isHidden = true
                }
            }
        )
    }
    
    // here I am changing constraint for the image because they are all different sizes
    private func adjustImageViewConstraints(for image: UIImage) {
        let aspectRatio = image.size.height / image.size.width
        newsImageView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(newsImageView.snp.width).multipliedBy(aspectRatio)
        }
        view.layoutIfNeeded()
    }
    
    // MARK: - Actions
    
    @objc private func didTapLink() {
        let webVC = WebViewController(viewModel: viewModel)
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    @objc private func didTapReadMore() {
        let webVC = WebViewController(viewModel: viewModel)
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    @objc private func shareTapped() {
        guard let shareURL = URL(string: viewModel.detailFullArticleURL) else { return }
        let activityVC = UIActivityViewController(activityItems: [shareURL], applicationActivities: nil)
        present(activityVC, animated: true)
    }
}
