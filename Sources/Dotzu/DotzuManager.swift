//
//  Manager.swift
//  exampleWindow
//
//  Created by Remi Robert on 02/12/2016.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit

public class Dotzu: NSObject, LogHeadViewDelegate {
    
    var logHeadView: LogHeadView?
    public static let sharedManager = Dotzu()
    
    override init() {
        super.init()
        logHeadView = LogHeadView(frame: CGRect(origin: LogHeadView.originalPosition, size: LogHeadView.size))
        logHeadView?.delegate = self
    }

    //MARK: - public
    public func enable() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.logHeadView?.isHidden = false
            }
        }
        Logger.shared.enable = true
        LoggerCrash.shared.enable = true
    }

    public func disable() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.logHeadView?.isHidden = true
            }
        }
        Logger.shared.enable = false
        LoggerCrash.shared.enable = false
    }
    
    //MARK: - LogHeadViewDelegate
    func didTapLogHeadView() {
        guard let window = UIApplication.shared.delegate?.window else {return}
        
        let tabbarController = LogTabBarViewController.instanceFromStoryBoard()
        window?.rootViewController?.present(tabbarController, animated: true, completion: nil)
    }
}
