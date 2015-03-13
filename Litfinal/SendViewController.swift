//
//  SendViewController.swift
//  Litfinal
//
//  Created by 山口 智生 on 2015/03/08.
//  Copyright (c) 2015年 Nextvanguard. All rights reserved.
//

import UIKit
import TwitterKit

class CustomCell: UICollectionViewCell {
    @IBOutlet var image:UIImageView!
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
}

class SendViewController: UIViewController, UITextFieldDelegate {
    
    var images : [String] = ["black.png", "くじけない.jpg", "とてもつらい.jpg", "むりです.PNG", "ん！？.jpg", "クソムシゴミクズこんにちは.jpg", "起きた.JPG", "次はオマエだ.jpg", "ラーメン.jpg", "進捗.png", "受験番号ない.jpg", "僕は悪くない.JPG", "一人で寝るのさみしい.jpg", "いいんじゃない.jpg", "この話はこれで終わり.jpg", "みなかったことに.jpg", "もう喋るな.jpg"]
    
    let sendButton: UIButton! = UIButton()
    
    @IBOutlet weak var myTextField: UITextField!
    @IBOutlet weak var PhotoCollection: UICollectionView!

    var app:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate //AppDelegateのインスタンスを取得
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("sendview")
        
        PhotoCollection.delegate = self
        PhotoCollection.dataSource = self
        
        //入力欄
        myTextField.returnKeyType = UIReturnKeyType.Done
        if let tmpString = self.app.replyuser {
            myTextField.text = "@" + tmpString + " "
        }
        myTextField.delegate = self
        self.view.addSubview(myTextField)
        
    }
    func textFieldShouldReturn(textField: UITextField!) -> Bool{
        println( textField.text )
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
        return true
    }

    @IBAction func onClickBackButton(sender: AnyObject) {
        println("back!")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendtweet(tweetText: String, replyid: String){
        TwitterAPI.postTweet(
            tweetText,
            in_reply_to_status_id: replyid,
            error: {
                error in
                println(error.localizedDescription)
        })

    }
}

extension SendViewController: UICollectionViewDataSource,UICollectionViewDelegate{
    
    // MARK: - UICollectionViewDelegate Protocol
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:CustomCell = collectionView.dequeueReusableCellWithReuseIdentifier("photocell", forIndexPath: indexPath) as CustomCell
        //cell.title.text = "タイトル";
        cell.image.image = UIImage(named: images[indexPath.row])
        
        cell.backgroundColor = UIColor.blackColor()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!)
    {
        //var cell:CustomCell = collectionView.dequeueReusableCellWithReuseIdentifier("photocell", forIndexPath: indexPath) as CustomCell
        println("select: \(indexPath.row)")
        var mediaid : String!
        
        if indexPath.row != 0 {
            TwitterAPI.postTweetWithMedia(myTextField.text,in_reply_to_status_id: (self.app.replyid ?? ""),image: UIImage(named: images[indexPath.row]),error: {
                error in
                println(error.localizedDescription)
            })
        }else{
            sendtweet(myTextField.text,replyid: (self.app.replyid ?? ""))
        }
        println(mediaid ?? "nil")

        self.myTextField.text = ""
        if self.myTextField.isFirstResponder() {
            self.myTextField.resignFirstResponder()
        }
        dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    func collectionView(collectionView: UICollectionView!, didDeselectItemAtIndexPath indexPath: NSIndexPath!)
    {
        //var cell:CustomCell = collectionView.dequeueReusableCellWithReuseIdentifier("photocell", forIndexPath: indexPath) as CustomCell

        println("deselect: \(indexPath.row)")
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count;
    }
}

