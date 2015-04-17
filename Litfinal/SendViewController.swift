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
    
    var images : [String] = ["camera.png", "いいんじゃない.jpg", "くじけない.jpg", "この話はこれで終わり.jpg", "とてもつらい.jpg", "起きた.JPG", "みなかったことに.jpg", "むりです.PNG", "もう喋るな.jpg", "ん！？.jpg", "クソムシゴミクズこんにちは.jpg", "ラーメン.jpg", "一人で寝るのさみしい.jpg", "僕は悪くない.JPG", "受験番号ない.jpg", "次はオマエだ.jpg", "真顔.jpg", "進捗.png", "00_56_cj8zf.jpg", "15d91a88.jpg", "201201187.jpg", "3e28691a-s.jpg", "BUBV4gLCQAAIWL8.jpg", "eventsnews102.jpg", "img_0.gif", "wpid-73JlIEr.jpg", "wpid-H00pmHd.jpg", "じゃがいも.jpg", "mac.jpg"]
    
    let sendButton: UIButton! = UIButton()
    
    @IBOutlet weak var myTextField: UITextField!
    @IBOutlet weak var PhotoCollection: UICollectionView!
    
    var replyUser:[String!] = [nil,nil]//segueから受け取る
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("sendview")
        
        PhotoCollection.delegate = self
        PhotoCollection.dataSource = self
        
        //入力欄
        myTextField.returnKeyType = UIReturnKeyType.Done
        if let tmpString = self.replyUser[1] {
            myTextField.text = "@" + tmpString + " "
        }
        myTextField.delegate = self
        self.view.addSubview(myTextField)
        
    }
    
    //完了を押したらキーボードを閉じる
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        println("return")
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
        return true
    }

    override func viewDidLayoutSubviews() {
        PhotoCollection.frame = CGRectMake(15, 130, self.view.frame.width-30, self.view.frame.height-160)
    }

    @IBAction func onClickBackButton(sender: AnyObject) {
        println("back!")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendtweet(tweetText: String!, replyid: String!){
        TwitterAPI.postTweet(
            tweetText,
            in_reply_to_status_id: replyid,
            mediaids: nil,
            error: {
                error in
                println(error.localizedDescription)
        })

    }
}

extension SendViewController: UICollectionViewDataSource,UICollectionViewDelegate{
    
    // MARK: - UICollectionViewDelegate Protocol
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:CustomCell = collectionView.dequeueReusableCellWithReuseIdentifier("photocell", forIndexPath: indexPath) as! CustomCell
        //cell.title.text = "タイトル";
        cell.image.image = UIImage(named: images[indexPath.row])
        
        cell.backgroundColor = UIColor.blackColor()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {

        println("select: \(indexPath.row)")
        var mediaid : String!
        
        if indexPath.row != 0 {
            TwitterAPI.postTweetWithMedia(myTextField.text,in_reply_to_status_id: replyUser[0],image: UIImage(named: images[indexPath.row]),error: {
                error in
                println(error.localizedDescription)
            })
        }else{
            sendtweet(myTextField.text,replyid: replyUser[0])
        }

        self.myTextField.text = ""
        if self.myTextField.isFirstResponder() {
            self.myTextField.resignFirstResponder()
        }
        //dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popViewControllerAnimated(true);
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath)
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

