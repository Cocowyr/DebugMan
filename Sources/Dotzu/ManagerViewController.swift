//
//  ManagerViewController.swift
//  exampleWindow
//
//  Created by Remi Robert on 02/12/2016.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit

class ManagerViewController: UIViewController, ZYSuspensionViewDelegate {

    private var logHeadView: ZYSuspensionView?
    private var timer: Timer?

    //liman mark
    public func showLogHead() {
        logHeadView?.show()
    }

    public func hideLogHead() {
        logHeadView?.removeFromScreen()
    }
    
    //MARK: - tool
    fileprivate func initLabelEvent(content: String, logHeadView: ZYSuspensionView?) {
        guard let logHeadView = logHeadView else {return}
        let view = UILabel()
        view.frame = CGRect(x: logHeadView.frame.size.width/2 - 25/2,
                            y: logHeadView.frame.size.height/2, width: 25, height: 25)
        view.text = content
        logHeadView.addSubview(view)
        UIView.animate(withDuration: 0.8, animations: {
            view.frame.origin.y = -100
            view.alpha = 0
        }, completion: { _ in
            view.removeFromSuperview()
        })
    }
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logHeadView = ZYSuspensionView.defaultSuspensionView(with: self)
        logHeadView?.leanType = .eachSide
        
        //网络通知
        NotificationCenter.default.addObserver(self, selector: #selector(reloadHttp_notification), name: NSNotification.Name(kNotifyKeyReloadHttp), object: nil)
        
        //内存监控
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerMonitor), userInfo: nil, repeats: true)
        guard let timer = timer else {return}//code never go here
        RunLoop.current.add(timer, forMode: .defaultRunLoopMode)
    }

    override func viewWillAppear(_ animated: Bool) {
        Dotzu.sharedManager.displayedList = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        timer?.invalidate()
    }

    func shouldReceive(point: CGPoint) -> Bool {
        if Dotzu.sharedManager.displayedList {return true}
        guard let logHeadView = logHeadView else {return false}
        return logHeadView.frame.contains(point)
    }
    
    //MARK: - ZYSuspensionViewDelegate
    func suspensionViewClick(_ suspensionView: ZYSuspensionView!) {
        LogsSettings.shared.isControllerPresent = true
        
        Dotzu.sharedManager.displayedList = true
        let storyboard = UIStoryboard(name: "Manager", bundle: Bundle(for: ManagerViewController.self))
        guard let controller = storyboard.instantiateInitialViewController() else {return}
        self.present(controller, animated: true, completion: nil)
    }
    
    //MARK: - target action
    //内存监控
    func timerMonitor() {
        logHeadView?.setTitle(JxbDebugTool.shareInstance().bytesOfUsedMemory(), for: .normal)
    }
    
    //MARK: - notification
    //网络通知
    func reloadHttp_notification() {
        DispatchQueue.main.async { [weak self] in
            self?.initLabelEvent(content: "🚀", logHeadView: self?.logHeadView)
        }
    }
}
