//
//  WebPageViewController.swift
//  Litfinal
//
//  Created by 山口 智生 on 2015/03/08.
//  Copyright (c) 2015年 Nextvanguard. All rights reserved.
//

import UIKit


class WebPageViewController: UIViewController {
    
    
    @IBOutlet weak var webview: UIWebView!
    
    var app:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate //AppDelegateのインスタンスを取得
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("viewwebloaded")
        
        let req = NSURLRequest(URL: app.weburl)
        webview.loadRequest(req)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

