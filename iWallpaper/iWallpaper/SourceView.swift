//
//  SourceView.swift
//  zhihu
//
//  Created by yfm on 2023/11/10.
//

import UIKit

class SourceView: UIView {
    
    enum Source: String, CaseIterable {
        case iphone     = "iphone wallpaper"
        case background = "background"
        case cat        = "cat"
        case dog        = "dog"
        case cartoon    = "cartoon"
        case starrySky  = "starry sky"
        case beautyGirl = "beauty girl"
        case city       = "city"
        case winter     = "winter"
        case ocean      = "ocean"
        case snow       = "snow"
        case nature     = "nature"
        case flowers    = "flowers"
        case food       = "food"
        case christmas  = "christmas"
        case building   = "building"
        case plant      = "plant"
        case abstract   = "abstract"
        case fashion    = "fashion"
        case relaxation = "relaxation"
        case grassland  = "grassland"
        case pretty     = "pretty"
        
        var title: String {
            switch self {
            case .iphone:        return "壁纸"
            case .background:    return "背景"
            case .cat:           return "猫咪"
            case .dog:           return "狗狗"
            case .cartoon:       return "卡通"
            case .starrySky:     return "星空"
            case .beautyGirl:    return "美女"
            case .city:          return "城市"
            case .winter:        return "冬天"
            case .ocean:         return "大海"
            case .snow:          return "雪景"
            case .nature:        return "自然"
            case .flowers:       return "花朵"
            case .food:          return "美食"
            case .christmas:     return "圣诞"
            case .building:      return "建筑"
            case .plant:         return "植物"
            case .abstract:      return "抽象"
            case .fashion:       return "流行"
            case .relaxation:    return "休闲"
            case .grassland:     return "草地"
            case .pretty:        return "模特"
            }
        }
        
        var maxPage: Int {
            switch self {
            case .iphone:       return 178  // 178
            case .cat:          return 92   // 92
            case .dog:          return 78   // 90
            case .background:   return 250  // 596
            case .cartoon:      return 59   // 59
            case .starrySky:    return 5    // 5
            case .beautyGirl:   return 65   // 158
            case .city:         return 160  // 268
            case .winter:       return 126  // 145
            case .ocean:        return 140  // 186
            case .snow:         return 94   // 103
            case .nature:       return 120  // 2004
            case .flowers:      return 119  // 777
            case .food:         return 115  // 141
            case .christmas:    return 91   // 92
            case .building:     return 122  // 274
            case .plant:        return 83   // 506
            case .abstract:     return 58   // 95
            case .fashion:      return 232  // 232
            case .relaxation:   return 46   // 46
            case .grassland:    return 5    // 5
            case .pretty:       return 200
            }
        }
    }
    
    class Row {
        var title: String = ""
        var selected: Bool = false
        var source: Source = .background
        
        init(title: String, selected: Bool, source: Source) {
            self.title = title
            self.selected = selected
            self.source = source
        }
    }
    
    var datasource: [Row] = []
    
    var dismiss: ((Source) -> Void)?
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.8)
        return view
    }()
    
    lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.backgroundColor = .white
        view.delegate = self
        view.dataSource = self
        view.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return view
    }()
    
    init(frame: CGRect, type: Source = .background) {
        super.init(frame: frame)
        backgroundColor = .black.withAlphaComponent(0.5)
        datasource = Source.allCases.map { Row(title: $0.title, selected: $0 == type, source: $0) }
        makeUI()
        let index = datasource.firstIndex(where: { $0.source == type }) ?? 0
        tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: true)
    }
    
    func makeUI() {
        addSubview(contentView)
        contentView.addSubview(topView)
        contentView.addSubview(tableView)
        
        contentView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(200)
        }
        
        topView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(kSafeAreaInsets.top)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        contentView.zy_x = -200
        UIView.animate(withDuration: 0.25) {
            self.contentView.zy_x = 0
        } completion: { finish in
            super.willMove(toSuperview: newSuperview)
        }
    }
    
    override func removeFromSuperview() {
        contentView.zy_x = 0
        UIView.animate(withDuration: 0.25) {
            self.contentView.zy_x = -200
        } completion: { finish in
            super.removeFromSuperview()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeFromSuperview()
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view?.isDescendant(of: contentView) == true {
            return false
        }
        return true
    }
}

extension SourceView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = datasource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = row.title
        cell.textLabel?.textColor = row.selected ? .red : .black
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != datasource.count - 1 {
            datasource.forEach { $0.selected = false }
            let row = datasource[indexPath.row]
            row.selected = true
            tableView.reloadData()
            dismiss?(row.source)
            removeFromSuperview()
        } else {
            removeFromSuperview()
        }
    }
}
