//
//  ListTarget.swift
//  zhihu
//
//  Created by yfm on 2023/10/10.
//

import Foundation
import Alamofire

enum ListAPI {
    case list(SourceView.Source, Int)
    case search(String, Int)
}

extension ListAPI: APITarget {
    var host: String {
//        switch self {
//        case .list:
//            "https://gitlab.com"
//        case .search:
            "https://www.pexels.com"
//        }
    }
    
    var path: String {
        switch self {
        case .list(let source, let page):
//            "/FMYang/wallpaper/-/raw/main/category/\(source.rawValue)/\(page).json?ref_type=heads".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            "/zh-cn/api/v3/search/photos?page=\(page)&per_page=100&query=\(source.rawValue)&orientation=portrait&size=all&color=all&seo_tags=true".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        case .search(let text, let page):
            "/zh-cn/api/v3/search/photos?page=\(page)&per_page=200&query=\(text)&orientation=portrait&size=all&color=all&seo_tags=true".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        }
    }
    
    var headers: [String : String]? {
//        switch self {
//        case .list:
//            return nil
//        case .search:
            return ["Secret-Key": "H2jk9uKnhRmL6WPwh89zBezWvr",
                    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
            ]
//        }
    }
}
