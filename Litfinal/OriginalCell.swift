//
//  OriginalCell.swift
//  Litfinal
//
//

import Foundation
import UIKit
import TwitterKit

@objc protocol OriginalTweetTableViewCellDelegate {
    optional func onRightSwipe(cell: OriginalTweetTableViewCell)
    optional func onLeftSwipe(cell: OriginalTweetTableViewCell)
    //optional func onTapRight(cell: OriginalTweetTableViewCell)
}

class OriginalTweetTableViewCell : TWTRTweetTableViewCell {
    weak var delegate: OriginalTweetTableViewCellDelegate?
    var haveButtonsDisplayed = false
    
    /*func favoriteTweet() {
        delegate?.onRightSwipe?(self)
    }
    
    func readTweet() {
        delegate?.onLeftSwipe?(self)
    }*/
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .None
        // バックグラウンドに使用されるViewを生成する
        self.createView()
        // 右スワイプ時のアクションの紐付け
        self.contentView.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: "onRightSwipe"))
        // 左スワイプ時のアクションの紐付け
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: "onLeftSwipe")
        swipeRecognizer.direction = .Left
        self.contentView.addGestureRecognizer(swipeRecognizer)
        
        //let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapped:")
        //tapGesture.numberOfTapsRequired = 1
        //self.contentView.addGestureRecognizer(tapGesture)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createView() {
        self.contentView.backgroundColor = UIColor.whiteColor()
        self.backgroundView = UIView(frame: self.bounds)
    }
    
    /*
    func tapped(sender: AnyObject){
        println("tapped")
        //var point: CGPoint = sender.locationOfTouch()
        println(CGPoint)
        self.delegate?.onTapRight?(self)
    }
    */
    
    func onLeftSwipe() {
        // カスタムカラーをバックグラウンドに指定
        self.backgroundView?.backgroundColor = UIColor.blackColor()
        UIView.animateWithDuration(0.1, animations: {
            let size   = self.contentView.frame.size
            let origin = self.contentView.frame.origin
            self.contentView.frame = CGRect(x: origin.x - 100, y:origin.y, width:size.width, height:size.height)
            }) { completed in
                // アニメーション完了時に100ずれていたら、readTweetを実行する
                println(self.contentView.frame.origin.x)
                if self.contentView.frame.origin.x == -100 {
                    self.delegate?.onLeftSwipe?(self)
                }
        }
    }
    
    // 外からcellを左にずらすためのユーティリティ
    func moveToLeft() {
        let size   = self.contentView.frame.size
        let origin = self.contentView.frame.origin
        self.contentView.frame = CGRect(x: origin.x - 100, y:origin.y, width:size.width, height:size.height)
    }
    
    func onRightSwipe() {
        // カスタムカラーをバックグラウンドに指定
        self.backgroundView?.backgroundColor = UIColor.blackColor()
        UIView.animateWithDuration(0.1, animations: {
            let size   = self.contentView.frame.size
            let origin = self.contentView.frame.origin
            self.contentView.frame = CGRect(x: origin.x + 100, y:origin.y, width:size.width, height:size.height)
            }) { completed in
                // アニメーション完了時に100ずれていたら、favoriteTweetを実行する
                println(self.contentView.frame.origin.x)
                if self.contentView.frame.origin.x == 100 {
                    self.delegate?.onRightSwipe?(self)
                }
        }
    }
    
    // 外からcellを右にずらすためのユーティリティ
    func moveToRight() {
        let size   = self.contentView.frame.size
        let origin = self.contentView.frame.origin
        self.contentView.frame = CGRect(x: origin.x + 100, y:origin.y, width:size.width, height:size.height)
    }
}
