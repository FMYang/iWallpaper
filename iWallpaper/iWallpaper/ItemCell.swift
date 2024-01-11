//
//  ItemCell.swift
//  iWallpaper
//
//  Created by yfm on 2024/1/5.
//

import UIKit
import Kingfisher

class ItemCell: UICollectionViewCell {
    
    lazy var imgView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    lazy var textBgView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.4)
        return view
    }()
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeUI() {
        addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func config(item: Item) {
        guard let src = item.src640 else { return }
        if let url = URL(string: src) {
            imgView.kf.setImage(with: url, placeholder: UIColor.createImage(color: .gray.withAlphaComponent(0.2))) { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    print("fm load image fail: \(error)")
                }
            }
        }
        textLabel.text = item.id
    }
}
