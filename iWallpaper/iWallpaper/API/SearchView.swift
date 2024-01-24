//
//  SearchView.swift
//  iMusic
//
//  Created by yfm on 2023/11/28.
//

import UIKit
import NotificationCenter

class SearchVC: UIViewController {
    
    var page = 1
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var searchView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(valueRGB: 0xe1e2e3).withAlphaComponent(0.8)
        view.layer.cornerRadius = 18
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var searchIconView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "fx_list_icon_search")
        return view
    }()
    
    lazy var searchTextfiled: UITextField = {
        let view = UITextField()
        view.returnKeyType = .search
        view.clearButtonMode = .whileEditing
        view.delegate = self
        view.placeholder = "搜索图片"
        return view
    }()
    
    lazy var cancelButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("取消", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        return btn
    }()
        
    lazy var resultCollectionView: UICollectionView = {
        let flowlayout = UICollectionViewFlowLayout()
        let w = (kScreenWidth - 50) * 0.5
        let h = w * 16 / 9
        flowlayout.itemSize = CGSizeMake((kScreenWidth - 50) * 0.5, h)
        flowlayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: flowlayout)
        view.delegate = self
        view.dataSource = self
        view.register(ItemCell.self, forCellWithReuseIdentifier: "cell")
        return view
    }()

    lazy var activityView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.color = .gray
        return view
    }()
    
    lazy var noDataLabel: UILabel = {
        let label = UILabel()
        label.text = "无相关内容"
        label.textColor = .black
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    var datasource: [Item] = [] {
        didSet {
            resultCollectionView.reloadData()
//            noDataLabel.isHidden = datasource.count > 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        makeUI()
        searchTextfiled.becomeFirstResponder()
        addRefresh()
        fd_prefersNavigationBarHidden = true
        
        let ges = UISwipeGestureRecognizer(target: self, action: #selector(backAction))
        ges.direction = .right
        view.addGestureRecognizer(ges)
    }
    
    @objc func backAction() {
        dismiss(animated: true)
    }
    
    // MARK: - action
    @objc func cancelAction() {
        searchTextfiled.resignFirstResponder()
        dismiss(animated: true)
    }
    
    func search(text: String) {
        if !text.isEmpty {
            datasource = []
            page = 1//Int(arc4random_uniform(50)) + 1
            searchApi(text: text)
        } else {
            datasource = []
            noDataLabel.isHidden = false
        }
    }
    
    func addRefresh() {
//        resultCollectionView.bindGlobalStyle(forHeadRefreshHandler: { [weak self] in
//            guard let self = self else { return }
//            self.page = 1
//            self.searchApi(text: searchTextfiled.text ?? "")
//        })
        
        resultCollectionView.bindGlobalStyle(forFootRefreshHandler: { [weak self] in
            guard let self = self else { return }
            self.searchApi(text: searchTextfiled.text ?? "", refresh: false)
        })
        
        resultCollectionView.footRefreshControl.autoRefreshOnFoot = true
    }
    
    // MARK: - UI
    func makeUI() {
        view.addSubview(contentView)
        contentView.addSubview(searchView)
        searchView.addSubview(searchIconView)
        searchView.addSubview(searchTextfiled)
        contentView.addSubview(cancelButton)
        contentView.addSubview(resultCollectionView)
        contentView.addSubview(noDataLabel)
        contentView.addSubview(activityView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        searchView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(cancelButton.snp.left).offset(0)
            make.top.equalToSuperview().offset(kSafeAreaInsets.top+10)
            make.height.equalTo(36)
        }
        
        searchIconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.width.height.equalTo(14)
            make.centerY.equalToSuperview()
        }
        
        searchTextfiled.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(searchIconView.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.height.equalTo(36)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(searchView)
        }
        
        resultCollectionView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(searchView.snp.bottom).offset(10)
        }
        
        noDataLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(searchView.snp.bottom).offset(20)
        }
        
        activityView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

}

extension SearchVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ItemCell
        cell.config(item: datasource[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = DetailVC(index: indexPath.row, data: datasource)
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension SearchVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            search(text: text)
            textField.resignFirstResponder()
        }
        return true
    }
}

extension SearchVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchTextfiled.resignFirstResponder()
    }
}

extension SearchVC {
    func searchApi(text: String, refresh: Bool = true) {
        if refresh {
            noDataLabel.isHidden = true
            activityView.startAnimating()
        }
        APIService.request1(target: ListAPI.search(text, page), type: SearchResult.self) { [weak self] response in
            self?.activityView.stopAnimating()
            switch response.result {
            case .success(let data):
                if refresh {
                    self?.datasource = data.tranformToItems()
                    self?.noDataLabel.isHidden = (self?.datasource.count ?? 0 > 0)
                } else {
                    self?.datasource += data.tranformToItems()
                }
                self?.page += 1
            case .failure(let error):
                print(error)
            }
//            self?.resultCollectionView.headRefreshControl.endRefreshing()
            self?.resultCollectionView.footRefreshControl.endRefreshing()
        }
    }
}


