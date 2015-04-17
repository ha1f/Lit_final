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
}

class OriginalTweetTableViewCell : TWTRTweetTableViewCell {
    weak var delegate: OriginalTweetTableViewCellDelegate?
    var haveButtonsDisplayed = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.tweetView.theme = .Dark
        
        
        self.selectionStyle = .None
        // バックグラウンドに使用されるViewを生成する
        self.createView()
        // スワイプ時のアクションの紐付け
        self.contentView.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: "onRightSwipe"))
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: "onLeftSwipe")
        swipeRecognizer.direction = .Left
        self.contentView.addGestureRecognizer(swipeRecognizer)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createView() {
        self.contentView.backgroundColor = UIColor.whiteColor()
        self.backgroundView = UIView(frame: self.bounds)
    }
    
    func onLeftSwipe() {
        // カスタムカラーをバックグラウンドに指定
        /*self.backgroundView?.backgroundColor = UIColor.blackColor()
        UIView.animateWithDuration(0.1, animations: {
            let size   = self.contentView.frame.size
            let origin = self.contentView.frame.origin
            self.contentView.frame = CGRect(x: origin.x - 100, y:origin.y, width:size.width, height:size.height)
            }) { completed in
                // アニメーション完了時に100ずれていたら、readTweetを実行する
                println(self.contentView.frame.origin.x)
                if self.contentView.frame.origin.x == -100 {
                    self.delegate?.onLeftSwipe?(self)
                    self.contentView.frame.origin.x = 0
                }
        }*/
        self.delegate?.onLeftSwipe?(self)
    }
    
    func onRightSwipe() {
        self.delegate?.onRightSwipe?(self)
    }
}
