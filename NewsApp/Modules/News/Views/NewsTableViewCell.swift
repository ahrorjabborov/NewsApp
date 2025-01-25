//
//  NewsTableViewCell.swift
//  NewsApp
//
//  Created by Ahror Jabborov on 1/23/25.
//

import UIKit
import SnapKit
import Kingfisher

final class NewsTableViewCell: UITableViewCell {
    static let identifier = "NewsTableViewCell"
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "F8F8F8")
        view.layer.cornerRadius = 12
        return view
    }()
    private lazy var sourceLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "0A2D73")
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    private lazy var eyeIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "eye")
        imageView.tintColor = UIColor(hex: "667085")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var visitsLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "667085")
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "667085")
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        return label
    }()
    private lazy var newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        contentView.addSubview(containerView)
        [sourceLabel, titleLabel, eyeIcon, visitsLabel, dateLabel, newsImageView].forEach {
            containerView.addSubview($0)
        }
        layoutUI()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
    
    private func layoutUI() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        newsImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(10)
            make.width.equalTo(newsImageView.snp.height)
        }
        sourceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
        }
        eyeIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().inset(10)
            make.width.height.equalTo(15)
        }
        visitsLabel.snp.makeConstraints { make in
            make.centerY.equalTo(eyeIcon.snp.centerY)
            make.leading.equalTo(eyeIcon.snp.trailing).offset(5)
        }
        dateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(eyeIcon.snp.centerY)
            make.trailing.lessThanOrEqualTo(newsImageView.snp.leading).offset(-10)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(sourceLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.lessThanOrEqualTo(newsImageView.snp.leading).offset(-10)
            make.bottom.lessThanOrEqualTo(eyeIcon.snp.top).offset(-10)
        }
    }
    
    func configure(with article: Article, viewCount: Int) {
        sourceLabel.text = article.source.name
        titleLabel.text = article.title
        visitsLabel.text = "\(viewCount)"
        dateLabel.text = formatDate(article.publishedAt)
        
        let placeholder = UIImage(named: "placeholder")
        if let imageURL = article.urlToImage, let url = URL(string: imageURL) {
            newsImageView.kf.setImage(with: url, placeholder: placeholder)
        } else {
            newsImageView.image = placeholder
        }
    }
    
    private func formatDate(_ isoString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = formatter.date(from: isoString) {
            formatter.dateFormat = "MMM d, yyyy - h:mm a"
            return formatter.string(from: date)
        }
        return isoString
    }
}
