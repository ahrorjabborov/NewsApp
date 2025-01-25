//
//  NewsSkeletonTableViewCell.swift
//  NewsApp
//
//  Created by Ahror Jabborov on 1/24/25.
//

import UIKit
import SnapKit

// this is a simple skeleton cell for loading
final class SkeletonNewsTableViewCell: UITableViewCell {
    static let identifier = "SkeletonNewsTableViewCell"
    
    private lazy var skeletonContainerView: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor(hex: "F8F8F8")
        container.layer.cornerRadius = 12
        return container
    }()
    
    private lazy var skeletonSourceView: UIView = {
        let source = UIView()
        source.backgroundColor = UIColor(white: 0.9, alpha: 1)
        source.layer.cornerRadius = 4
        return source
    }()
    
    private lazy var skeletonTitleView: UIView = {
        let title = UIView()
        title.backgroundColor = UIColor(white: 0.9, alpha: 1)
        title.layer.cornerRadius = 4
        return title
    }()
    
    private lazy var skeletonEyeView: UIView = {
        let eye = UIView()
        eye.backgroundColor = UIColor(white: 0.9, alpha: 1)
        eye.layer.cornerRadius = 2
        return eye
    }()
    
    private lazy var skeletonVisitsView: UIView = {
        let visits = UIView()
        visits.backgroundColor = UIColor(white: 0.9, alpha: 1)
        visits.layer.cornerRadius = 4
        return visits
    }()
    
    private lazy var skeletonDateView: UIView = {
        let datePlaceholder = UIView()
        datePlaceholder.backgroundColor = UIColor(white: 0.9, alpha: 1)
        datePlaceholder.layer.cornerRadius = 4
        return datePlaceholder
    }()
    
    private lazy var skeletonImageView: UIView = {
        let image = UIView()
        image.backgroundColor = UIColor(white: 0.9, alpha: 1)
        image.layer.cornerRadius = 8
        return image
    }()
    
    private var shimmerLayers = [CAGradientLayer]()
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        contentView.addSubview(skeletonContainerView)
        
        [skeletonSourceView,
         skeletonTitleView,
         skeletonEyeView,
         skeletonVisitsView,
         skeletonDateView,
         skeletonImageView].forEach {
            skeletonContainerView.addSubview($0)
        }
        
        layoutSkeletonUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    private func layoutSkeletonUI() {
        skeletonContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        skeletonImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(10)
            make.width.equalTo(skeletonImageView.snp.height)
        }
        skeletonSourceView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
            make.width.equalTo(80)
            make.height.equalTo(16)
        }
        skeletonEyeView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().inset(10)
            make.width.height.equalTo(15)
        }
        skeletonVisitsView.snp.makeConstraints { make in
            make.centerY.equalTo(skeletonEyeView.snp.centerY)
            make.leading.equalTo(skeletonEyeView.snp.trailing).offset(5)
            make.width.equalTo(40)
            make.height.equalTo(16)
        }
        skeletonDateView.snp.makeConstraints { make in
            make.centerY.equalTo(skeletonEyeView.snp.centerY)
            make.trailing.lessThanOrEqualTo(skeletonImageView.snp.leading).offset(-10)
            make.width.equalTo(80)
            make.height.equalTo(16)
        }
        skeletonTitleView.snp.makeConstraints { make in
            make.top.equalTo(skeletonSourceView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalTo(skeletonImageView.snp.leading).offset(-10)
            make.bottom.equalTo(skeletonEyeView.snp.top).offset(-10)
        }
    }
    
    func startShimmer() {
        stopShimmer()
        let placeholders = [
            skeletonSourceView, skeletonTitleView, skeletonEyeView,
            skeletonVisitsView, skeletonDateView, skeletonImageView
        ]
        
        for placeholder in placeholders {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = placeholder.bounds
            gradientLayer.cornerRadius = placeholder.layer.cornerRadius
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            gradientLayer.colors = [
                UIColor(white: 0.85, alpha: 1).cgColor,
                UIColor(white: 0.75, alpha: 1).cgColor,
                UIColor(white: 0.85, alpha: 1).cgColor
            ]
            gradientLayer.locations = [0, 0.5, 1]
            
            let animation = CABasicAnimation(keyPath: "locations")
            animation.fromValue = [0, 0, 0.1]
            animation.toValue   = [0.9, 1, 1]
            animation.duration  = 1.0
            animation.repeatCount = .infinity
            gradientLayer.add(animation, forKey: "shimmer")
            
            placeholder.layer.addSublayer(gradientLayer)
            shimmerLayers.append(gradientLayer)
        }
    }
    
    func stopShimmer() {
        shimmerLayers.forEach { $0.removeAllAnimations(); $0.removeFromSuperlayer() }
        shimmerLayers.removeAll()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for layer in shimmerLayers {
            layer.frame = layer.superlayer?.bounds ?? .zero
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopShimmer()
    }
}
