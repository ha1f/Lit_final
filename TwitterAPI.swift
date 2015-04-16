//
//  TwitterAPI.swift
//  Litfinal
//
//  Created by 山口 智生 on 2015/03/08.
//  Copyright (c) 2015年 Nextvanguard. All rights reserved.
//

import Foundation
import TwitterKit

class TwitterAPI {
    static let baseURL = "https://api.twitter.com"
    static let version = "/1.1"
    
    static func callAPI(path: String, param: Dictionary<String, String>?, type: String) -> NSURLRequest!{
        var clientError: NSError?
        let endpoint = self.baseURL + self.version + path
        
        return Twitter.sharedInstance().APIClient.URLRequestWithMethod(type, URL: endpoint, parameters: param, error: &clientError)
    }
    
    class func postTweetWithMedia(tweetText: String, in_reply_to_status_id: String!, image: UIImage!,error: (NSError) -> ()) {
        var clientError: NSError?
        
        let media = UIImagePNGRepresentation(image).base64EncodedStringWithOptions(nil)
        
        let param = ["media" : media]
        
        let apiPath = "https://upload.twitter.com" + self.version + "/media/upload.json"
        
        let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod("POST", URL: apiPath, parameters: param, error: nil)
        
        if request != nil {
            Twitter.sharedInstance().APIClient.sendTwitterRequest(request, completion: {response, data, err in
                if err == nil {
                    var jsonError: NSError?
                    let json: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data,options: nil,error: &jsonError)
                    if let jsonArray = json as? NSDictionary {
                        if let statuses = jsonArray["media_id_string"] as! String?{
                            self.postTweet(tweetText,in_reply_to_status_id: in_reply_to_status_id, mediaids: statuses, error: {
                                error in
                                println(error.localizedDescription)
                            })
                        }
                    }
                } else {
                    error(err)
                }
            })
        }
    }

    class func postTweet(tweetText: String, in_reply_to_status_id: String!, mediaids: String!, error: (NSError) -> ()) {
        var param = Dictionary<String, String>()
        param["status"] = tweetText
        
        if in_reply_to_status_id != ""{
            param["in_reply_to_status_id"] = in_reply_to_status_id
        }
        if let tmp = mediaids {
            param["media_ids"] = tmp
        }
        
        let request = callAPI("/statuses/update.json",param:  param, type: "POST")
        
        if request != nil {
            Twitter.sharedInstance().APIClient.sendTwitterRequest(request, completion: {
                response, data, err in
                if err == nil {
                    println("post succeeded")
                } else {
                    error(err)
                }
            })
        }
    }
    
    class func getSearch(tweets: [TWTRTweet]->(),searchword: String ,error: (NSError) -> ()) {
        var param = Dictionary<String, String>()
        println(searchword)
        param = ["q": searchword, "count":"20"]
        
        let request = callAPI("/search/tweets.json",param: param, type: "GET")
        
        if request != nil {
            Twitter.sharedInstance().APIClient.sendTwitterRequest(request, completion: {
                response, data, err in
                if err == nil {
                    var jsonError: NSError?
                    let json: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data,
                        options: nil,
                        error: &jsonError)
                    if let jsonArray = (json as? NSDictionary){
                        var list: [TWTRTweet] = []
                        if let statuses = jsonArray["statuses"] as? NSArray {
                            tweets(TWTRTweet.tweetsWithJSONArray(statuses as [AnyObject]) as! [TWTRTweet])
                        }
                    }
                } else {
                    error(err)
                    println("error")
                }
            })
        }
    }
    
    class func getHomeTimeline(tweets: [TWTRTweet]->(), maxid: String!, error: (NSError) -> ()) {
        var param = Dictionary<String, String>()
        if let tmpid = maxid {
            param["max_id"] = tmpid
        }
        param["count"] = "20"
        
        let request = callAPI("/statuses/home_timeline.json",param: param, type: "GET")
        
        if request != nil {
            Twitter.sharedInstance().APIClient.sendTwitterRequest(request, completion: {response, data, err in
                if err == nil {
                    var jsonError: NSError?
                    let json: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data,
                        options: nil,
                        error: &jsonError)
                    if let jsonArray = json as? NSArray {
                        tweets(TWTRTweet.tweetsWithJSONArray(jsonArray as [AnyObject]) as! [TWTRTweet])
                    }
                } else {
                    error(err)
                }
            })
        }
    }
    
    class func gettweetwithid(tweets: [TWTRTweet]->(), tweetIDs: NSArray,error: (NSError) -> ()) {
        Twitter.sharedInstance().APIClient.loadTweetsWithIDs(tweetIDs as [AnyObject]) {(tweetsa, error) -> Void in
                if let ts = tweetsa as? [TWTRTweet] {
                    tweets(ts)
                } else {
                    println("Failed to load tweets: \(error.localizedDescription)")
                }
        }
    }
    
    class func getMyFavorites(tweets: [TWTRTweet]->(),error: (NSError) -> ()){
        var param = Dictionary<String, String>()
        param = ["count":"20"]
        
        let request = callAPI("/favorites/list.json",param: param, type: "GET")
        
        if request != nil {
            Twitter.sharedInstance().APIClient.sendTwitterRequest(request, completion: {
                response, data, err in
                if err == nil {
                    var jsonError: NSError?
                    let json: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data,
                        options: nil,
                        error: &jsonError)
                    if let jsonArray = json as? NSArray {
                        tweets(TWTRTweet.tweetsWithJSONArray(jsonArray as [AnyObject]) as! [TWTRTweet])
                    }
                } else {
                    error(err)
                }
            })
        }
    }
    
}