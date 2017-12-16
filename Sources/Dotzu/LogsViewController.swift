//
//  LogsViewController.swift
//  exampleWindow
//
//  Created by Remi Robert on 06/12/2016.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit

class LogsViewController: UITableViewController, UISearchBarDelegate {

    var models: [Log] = [Log]()
    var cacheModels: Array<Log>?
    var searchModels: Array<Log>?
    
    var _searchText: String = ""
    var flag: Bool = false
    
    let keyboardMan = KeyboardMan()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: - tool
    func dispatch_main_async_safe(callback: @escaping ()->Void ) {
        if Thread.isMainThread {
            callback()
        }else{
            DispatchQueue.main.async( execute: {
                callback()
            })
        }
    }
    
    //搜索逻辑
    func searchLogic(_ searchText: String = "") {
        guard let cacheModels = cacheModels else {return}
        searchModels = cacheModels
        
        if searchText == "" {
            models = cacheModels
        }else{
            guard var searchModels = searchModels else {return}
            
            for _ in searchModels {
                if let index = searchModels.index(where: { (model) -> Bool in
                    return !model.content.lowercased().contains(searchText.lowercased())//忽略大小写
                }) {
                    searchModels.remove(at: index)
                }
            }
            models = searchModels
        }
    }
    
    //MARK: - private
    func reloadLogs(_ isFirstIn: Bool = false) {
        
        models = StoreManager.shared.logArray
        self.cacheModels = self.models
        
        self.searchLogic(self._searchText)
        
        dispatch_main_async_safe { [weak self] in
            self?.tableView.reloadData()
            
            if isFirstIn == false {return}
            
            //table下滑到底部
            guard let count = self?.models.count else {return}
            if count > 0 {
                self?.tableView.scrollToRow(at: IndexPath.init(row: count-1, section: 0), at: .bottom, animated: false)
                
                /*
                 //滑动不到最底部, 弃用
                 if let h1 = self?.tableView.contentSize.height, let h2 = self?.tableView.frame.size.height, let bottom = self?.tableView.contentInset.bottom {
                 if h1 > h2 {
                 self?.tableView.setContentOffset(CGPoint.init(x: 0, y: h1-h2+bottom), animated: false)
                 }
                 }*/
            }
        }
    }
    
    //MARK: - init
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if flag == true {return}
        flag = true
        
        
        let count = self.models.count
        
        if count > 0 {
            //否则第一次进入滑动不到底部
            DispatchQueue.main.async { [weak self] in
                self?.tableView.scrollToRow(at: IndexPath.init(row: count-1, section: 0), at: .bottom, animated: false)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(tapDebugWin), name: NSNotification.Name("tapDebugWin"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshLogs_notification), name: NSNotification.Name("refreshLogs"), object: nil)
        
        reloadLogs(true)
        
        tableView.tableFooterView = UIView()
        searchBar.delegate = self
        
        //hide searchBar icon
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as! UITextField
        textFieldInsideSearchBar.leftViewMode = UITextFieldViewMode.never
        
        //键盘
        keyboardMan.postKeyboardInfo = { keyboardMan, keyboardInfo in
            switch keyboardInfo.action {
            case .show: break
                
            case .hide: break
                
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //liman mark, 否则偶尔crash
        if indexPath.row >= models.count {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogTableViewCell", for: indexPath)
            as! LogTableViewCell
        cell.model = models[indexPath.row]
        return cell
    }
    
    //MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        searchBar.resignFirstResponder()
    }
    
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let model = models[indexPath.row]
        var title = "Tag"
        if model.isTag == true {title = "UnTag"}
        
        let left = UIContextualAction(style: .normal, title: title) { [weak self] (action, sourceView, completionHandler) in
            model.isTag = !model.isTag
            self?.dispatch_main_async_safe { [weak self] in
                self?.tableView.reloadData()
            }
            completionHandler(true)
        }
        
        searchBar.resignFirstResponder()
        left.backgroundColor = UIColor.init(hexString: "#007aff")
        return UISwipeActionsConfiguration(actions: [left])
    }
    
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, sourceView, completionHandler) in
            guard let models = self?.models else {return}
            StoreManager.shared.removeLog(models[indexPath.row])
            self?.models.remove(at: indexPath.row)
            self?.dispatch_main_async_safe { [weak self] in
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            completionHandler(true)
        }
        
        searchBar.resignFirstResponder()
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    //MARK: - only for ios8/ios9/ios10, not ios11
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            StoreManager.shared.removeLog(models[indexPath.row])
            self.models.remove(at: indexPath.row)
            self.dispatch_main_async_safe { [weak self] in
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    //MARK: - UIScrollViewDelegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        searchBar.resignFirstResponder()
    }

    //MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        _searchText = searchText
        
        searchLogic(_searchText)
        
        dispatch_main_async_safe { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    //MARK: - target action
    @IBAction func resetLogs(_ sender: Any) {
        models = []
        cacheModels = []
        StoreManager.shared.resetLogs()
        searchBar.resignFirstResponder()
        
        dispatch_main_async_safe { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    //MARK: - notification
    @objc func tapDebugWin() {
        if models.count > 0 {
            
            dispatch_main_async_safe { [weak self] in
                self?.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .bottom, animated: true)
                //滑动不到最顶部, 弃用
//                tableView.setContentOffset( CGPoint(x: 0, y: 0) , animated: false)
            }
        }
        
        searchBar.resignFirstResponder()
    }
    
    @objc func refreshLogs_notification() {
        reloadLogs()
    }
}



