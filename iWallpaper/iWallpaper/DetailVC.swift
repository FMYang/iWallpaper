//
//  DetailVC.swift
//  iWallpaper
//
//  Created by yfm on 2024/1/5.
//

import UIKit
import FDFullscreenPopGesture
import Alamofire
import Photos
import Kingfisher
import WebKit

class DetailVC: UIViewController {
    
    var curIndex = 0
    var datasource: [Item] = []
    var imgPath: String = ""
    
    var dismissBlock: ((Int) -> Void)?
    
//    lazy var webView: WKWebView = {
//        let view = WKWebView(frame: .zero)
//        view.navigationDelegate = self
//        view.isHidden = true
//        return view
//    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = true
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
        
    lazy var downloadButton: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitle("下载", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(downloadAction), for: .touchUpInside)
        btn.backgroundColor = .black.withAlphaComponent(0.4)
        btn.layer.cornerRadius = 40
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fd_prefersNavigationBarHidden = true
        view.backgroundColor = .black
        makeUI()
        loadData()
        
        let downGes = UISwipeGestureRecognizer(target: self, action: #selector(previousAction))
        downGes.direction = .down
        view.addGestureRecognizer(downGes)
        
        let upGes = UISwipeGestureRecognizer(target: self, action: #selector(nextAction))
        upGes.direction = .up
        view.addGestureRecognizer(upGes)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(nextAction))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissBlock?(curIndex)
    }

    init(index: Int, data: [Item]) {
        super.init(nibName: nil, bundle: nil)
        datasource = data
        curIndex = index
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadData() {
        imgPath = datasource[curIndex].src640 ?? ""
        if let url = URL(string: imgPath) {
            imageView.kf.setImage(with: url)
        }
    }
    
    @objc func previousAction() {
        if curIndex > 0 {
            curIndex -= 1
        }
        loadData()
    }
    
    @objc func nextAction() {
        if curIndex < datasource.count - 1 {
            curIndex += 1
        }
        loadData()
    }
    
    @objc func downloadAction() {
        let item = datasource[curIndex]
        guard let id = item.id else { return }
//        webView.load(URLRequest(url: URL(string: "https://pixabay.com/images/download/fireworks-\(id).jpg")!))
        var downloadPath = ""
        var headers: HTTPHeaders? = nil
        if item.src1280?.contains("https://cdn.pixabay.com") == true {
            downloadPath = "https://pixabay.com/images/download/fireworks-\(id).jpg"
            
            headers = HTTPHeaders(["sessionid": ".eJxVzEEOgjAQheG7dG1Ii1OmeplmOgxShWJouzLeXWBhdP3-972Up1pGX7OsPvbqqsB0Ggy06vQ7BeKHpH1_rstduDS1xCk3XHNZ5iNs4pEmmsUvq5eZ4vT9_WEj5XGTjLVoAxDoHmHo2QXEEJAHMRbBISJo6nQYWkOG0ODlLI7RIXUSuOUdnSjdKt1k4ySp9wfp6kRV:1rKwoI:tA4eCKblGoR0pNXiTQDGj0uoFBvtj4QE0rK9VPYGV1w", "user_id": "41604142"])
        } else {
            downloadPath = item.downloadlink ?? ""
        }
        
        guard downloadPath.count > 0 else {
            view.showToast("下载图片失败，无效的地址")
            return
        }
        
        let destination: DownloadRequest.Destination = { url, response in
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let savePath = documentPath.appendingPathComponent("/\(response.suggestedFilename ?? "tmp.jpg")")
            return (savePath, [.createIntermediateDirectories, .removePreviousFile])
        }
        
        APIService.alamofire.download(downloadPath, headers: headers, to: destination)
            .downloadProgress(closure: { progress in
                let downloadProgress = progress.fractionCompleted
                print(downloadProgress)
                if downloadProgress < 1.0 {
                    let str = "\(Int(downloadProgress * 100))%"
                    self.downloadButton.setTitle(str, for: .normal)
                } else {
                    self.downloadButton.setTitle("下载", for: .normal)
                }
            })
            .response { [weak self] response in
            switch response.result {
            case .success(let url):
                if let sanboxPath = url?.path {
                    if let image = UIImage(contentsOfFile: sanboxPath) {
                        self?.saveImageToPhotoLibrary(image: image)
                    } else {
                        self?.view.showToast("获取图片失败")
                        self?.downloadButton.setTitle("下载", for: .normal)
                    }
                }
            case .failure(let error):
                print(error)
                self?.view.showToast("下载图片失败")
            }
        }
    }
    
    func downloadImage(path: String) {
        let destination: DownloadRequest.Destination = { url, response in
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let savePath = documentPath.appendingPathComponent("/\(response.suggestedFilename ?? "tmp.jpg")")
            return (savePath, [.createIntermediateDirectories, .removePreviousFile])
        }
        
        APIService.alamofire.download(path, to: destination)
            .downloadProgress(closure: { progress in
                let downloadProgress = progress.fractionCompleted
                print(downloadProgress)
                if downloadProgress < 1.0 {
                    let str = "\(Int(downloadProgress * 100))%"
                    self.downloadButton.setTitle(str, for: .normal)
                } else {
                    self.downloadButton.setTitle("下载", for: .normal)
                }
            })
            .response { [weak self] response in
            switch response.result {
            case .success(let url):
                if let sanboxPath = url?.path {
                    if let image = UIImage(contentsOfFile: sanboxPath) {
                        self?.saveImageToPhotoLibrary(image: image)
                    } else {
                        self?.view.showToast("获取图片失败")
                        self?.downloadButton.setTitle("下载", for: .normal)
                    }
                }
            case .failure(let error):
                print(error)
                if error.responseCode == 403 {
                    self?.view.showToast("下载图片失败, 没有权限")
                } else {
                    self?.view.showToast("下载图片失败")
                }
            }
        }
    }
    
    func saveImageToPhotoLibrary(image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
            request.creationDate = Date() // 设置创建日期（可选）
        }) { [weak self] (success, error) in
            if success {
                DispatchQueue.main.async {
                    self?.showAlert()
                }
            } else {
                DispatchQueue.main.async {
                    self?.view.showToast("保存相册失败")
                }
            }
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "图片已保存", message: "是否立刻打开相册设置墙纸", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "去设置", style: .default, handler: { action in
            let wallpaperURL = URL(string: "photos-redirect://")
            UIApplication.shared.open(wallpaperURL!, options: [:], completionHandler: nil)
        }))
        navigationController?.present(alert, animated: true)
    }
    
    func makeUI() {
        view.addSubview(imageView)
        view.addSubview(downloadButton)
//        view.addSubview(webView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
                
        downloadButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
            make.bottom.equalToSuperview().offset(-50)
        }
        
//        webView.snp.makeConstraints { make in
//            make.top.left.right.equalToSuperview()
//            make.height.equalTo(600)
//        }
    }
}

//extension DetailVC: WKNavigationDelegate {
//    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        print("didStartProvisionalNavigation")
//    }
//    
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        print("fm web \(navigationAction.request.url?.absoluteString ?? "")")
//        if navigationAction.request.url?.absoluteString.contains("https://pixabay.com/accounts/register") == true {
//            // 表示需要登录
//            webView.isHidden = false
//            // 跳到pixabay去登录
//            webView.load(URLRequest(url: URL(string: "https://pixabay.com/")!))
//        }
//        if navigationAction.request.url?.absoluteString.contains("https://pixabay.com/get") == true {
//            webView.isHidden = true
//            if let hdPath = navigationAction.request.url?.absoluteString {
//                print(hdPath)
//                downloadImage(path: hdPath)
//            }
//        }
//        decisionHandler(.allow)
//    }
//}
