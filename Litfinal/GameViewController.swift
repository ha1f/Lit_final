//
//  GameViewController.swift
//  Litfinal
//
//  Created by 山口 智生 on 2015/03/08.
//  Copyright (c) 2015年 Nextvanguard. All rights reserved.
//

import UIKit



class GameViewController: UIViewController ,UIPickerViewDelegate, UIPickerViewDataSource{
    
    var nums = [20,20,20]
    
    var Values = [1]
    
    let arealabel: [UIButton] = [UIButton(), UIButton(), UIButton()]
    var sendButton: UIButton! = UIButton()
    
    var myUIPicker: UIPickerView = UIPickerView()
    
    var activecell: Int = 0
    var activenum:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        var scenewidth = self.view.bounds.width
        var sceneheight = self.view.bounds.height-180
        
        
        sendButton.setTitle("決定", forState: .Normal)
        sendButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        sendButton.frame = CGRectMake(0,0,80,80)
        sendButton.layer.position = CGPoint(x: self.view.bounds.width-80, y: self.view.bounds.height-80)
        sendButton.addTarget(self, action: "onClickSendButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(sendButton)
        
        
        for i in 0...2 {
            arealabel[i].backgroundColor = UIColor.whiteColor()
            arealabel[i].frame = CGRectMake(0,0,scenewidth,sceneheight/3)
            arealabel[i].setTitle("", forState: .Normal)
            arealabel[i].setTitleColor(UIColor.blackColor(), forState: .Normal)
            arealabel[i].setTitle("", forState: UIControlState.Highlighted)
            arealabel[i].setTitleColor(UIColor.blackColor(), forState: .Highlighted)
            arealabel[i].layer.position = CGPoint(x: scenewidth/2, y: sceneheight/6*(CGFloat(i)*2+1) )
            arealabel[i].tag = i+1
            arealabel[i].titleLabel?.numberOfLines = 2
            arealabel[i].addTarget(self, action: "onClickMyButton:", forControlEvents: .TouchUpInside)
            self.view.addSubview(arealabel[i])
        }
        
        // サイズを指定する.
        myUIPicker.frame = CGRectMake(0,self.view.bounds.height-180,self.view.bounds.width/2, 180.0)
        
        myUIPicker.delegate = self
        myUIPicker.dataSource = self
        
        // Viewに追加する.
        self.view.addSubview(myUIPicker)
        
        draw()
    }
    func onClickSendButton(sender: AnyObject){
        nums[activecell] = nums[activecell] - activenum
        if nums[0] + nums[1] + nums[2] == 0 {
            
        }
        
        draw()
    }
    func draw(){
        for i in 0...2 {
            var tmp :String! = ""
            for var j=0;j<nums[i];j++ {
                tmp = tmp + "◯"
                if j==9 {
                    tmp = tmp + "\n"
                }
            }
            arealabel[i].setTitle(tmp, forState: .Normal)
            arealabel[i].setTitle(tmp, forState: .Highlighted)
        }
        
        for i in 0...2 {
            if i == activecell {
                arealabel[i].backgroundColor = UIColor.blackColor()
                arealabel[i].setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
                arealabel[i].setTitleColor(UIColor.whiteColor(), forState: .Normal)
            }else{
                arealabel[i].backgroundColor = UIColor.whiteColor()
                arealabel[i].setTitleColor(UIColor.blackColor(), forState: .Highlighted)
                arealabel[i].setTitleColor(UIColor.blackColor(), forState: .Normal)
            }
        }
        
        Values = []
        for var j=0;j<nums[activecell];j++ {
            Values.append(j+1)
        }
        myUIPicker.reloadAllComponents()
    }
    
    
    func onClickMyButton(sender: UIButton){
        println("sender.tag:\(sender.tag)")
        
        activecell = sender.tag-1
        
        draw()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /*
    表示するデータ数を返す.
    */
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Values.count
    }
    
    /*
    値を代入する.
    */
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {
        return "\(Values[row])"
    }
    
    /*
    Pickerが選択された際に呼ばれる.
    */
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        println("row: \(row)")
        println("value: \(Values[row])")
        
        activenum = Values[row]
    }
    
    
}

