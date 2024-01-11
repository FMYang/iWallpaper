//
//  ViewController.swift
//  iWallpaper
//
//  Created by yfm on 2024/1/5.
//

import UIKit
import SnapKit
import Alamofire

class ViewController: UIViewController {
    
    var page = 1
    
//    var maxPage = SourceView.Source.iphone.maxPage
    
    var datasource: [Item] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var source: SourceView.Source = .background {
        didSet {
            sourceButton.setTitle(source.title, for: .normal)
//            maxPage = source.maxPage
            collectionView.headRefreshControl.beginRefreshing()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                if self.datasource.count > 0 {
                    self.collectionView.layoutIfNeeded()
                    self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            })
        }
    }
    
    lazy var searchButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "cctop_search"), for: .normal)
        btn.addTarget(self, action: #selector(searchAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var sourceButton: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitle("", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.contentHorizontalAlignment = .left
        btn.addTarget(self, action: #selector(sourceAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var collectionView: UICollectionView = {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "iWallpaper"
        configNav()
//        page = Int(arc4random_uniform(UInt32(self.maxPage))) + 1
        listenNetwork()
        makeUI()
        addRefresh()
        source = .background
        
        let ges = UISwipeGestureRecognizer(target: self, action: #selector(sourceAction))
        ges.direction = .right
        view.addGestureRecognizer(ges)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sourceButton.isHidden = false
        searchButton.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sourceButton.isHidden = true
        searchButton.isHidden = true
    }
    
    func configNav() {
        navigationController?.navigationBar.addSubview(sourceButton)
        sourceButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(120)
            make.top.bottom.equalToSuperview()
        }
        
        navigationController?.navigationBar.addSubview(searchButton)
        searchButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(60)
            make.top.bottom.equalToSuperview()
        }
    }
    
    @objc func searchAction() {
        let searchView = SearchVC()
        let nav = UINavigationController(rootViewController: searchView)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    @objc func sourceAction() {
        let sourceView = SourceView(frame: UIScreen.main.bounds, type: source)
        sourceView.dismiss = { [weak self] source in
            if self?.source != source {
                self?.source = source
            }
        }
        navigationController?.view.addSubview(sourceView)
    }
    
    func listenNetwork() {
        NetworkReachabilityManager.default?.startListening(onQueue: DispatchQueue.main, onUpdatePerforming: { [weak self] status in
            switch status {
            case .reachable(.ethernetOrWiFi), .reachable(.cellular):
                if self?.datasource.count == 0 {
                    self?.loadData()
                }
            case .notReachable:
                break
            case .unknown:
                break
            }
        })
    }
    
    func addRefresh() {
        collectionView.bindGlobalStyle(forHeadRefreshHandler: { [weak self] in
            guard let self = self else { return }
            self.page = 1
//            self.page = Int(arc4random_uniform(UInt32(self.maxPage))) + 1
            self.loadData()
        })
        
        collectionView.bindGlobalStyle(forFootRefreshHandler: { [weak self] in
            self?.loadData(refresh: false)
        })
        
        collectionView.footRefreshControl.autoRefreshOnFoot = true
    }
    
    func loadData(refresh: Bool = true) {
        APIService.request1(target: ListAPI.list(source, page), type: SearchResult.self) { [weak self] response in
            switch response.result {
            case .success(let result):
                if refresh {
                    self?.datasource = result.tranformToItems()
                } else {
                    self?.datasource += result.tranformToItems()
                }
                self?.page += 1
            case .failure(let error):
                print(error)
            }
            self?.collectionView.headRefreshControl.endRefreshing()
            self?.collectionView.footRefreshControl.endRefreshing()
        }
    }
    
    func makeUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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
        vc.dismissBlock = { [weak self] index in
            self?.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredVertically, animated: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

