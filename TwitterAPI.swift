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
    
    static func getData(path: String!, params: Dictionary<String, String>, process: AnyObject?->()){
        var clientError: NSError?
        let endpoint = self.baseURL + self.version + path
        
        let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod("GET", URL: endpoint, parameters: params, error: &clientError)
        
        if request != nil {
            Twitter.sharedInstance().APIClient.sendTwitterRequest(request, completion: {response, data, err in
                if err == nil {
                    var jsonError: NSError?
                    let json: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data,options: nil,error: &jsonError)
                    if json == nil {
                        println("json error")
                    }else{
                        process(json)
                    }
                } else {
                    println("client error")
                }
            })
        }
    }
    
    static func getSearch(tweets: [TWTRTweet]->(),searchword: String ,error: (NSError) -> ()) {
        var param = Dictionary<String, String>()
        param = ["q": searchword, "count":"20"]
        
        self.getData("/search/tweets.json", params: param, process: {
            json in
            if let jsonArray = (json as? NSDictionary){
                var list: [TWTRTweet] = []
                if let statuses = jsonArray["statuses"] as? NSArray {
                    tweets(TWTRTweet.tweetsWithJSONArray(statuses as [AnyObject]) as! [TWTRTweet])
                }
            }
        })
        
        /*let request = callAPI("/search/tweets.json",param: param, type: "GET")
        
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
        }*/
    }
    
    static func getHomeTimeline(tweets: [TWTRTweet]->(), maxid: String!, count:String! ,error: (NSError) -> ()) {
        var param = Dictionary<String, String>()
        if let tmp = maxid {
            param["max_id"] = tmp
        }
        if let tmp = count{
            param["count"] = tmp
        }
        
        self.getData("/statuses/home_timeline.json", params: param, process: {
            json in
            if let jsonArray = json as? NSArray {
                tweets(TWTRTweet.tweetsWithJSONArray(jsonArray as [AnyObject]) as! [TWTRTweet])
            }
        })
    }
    
    static func postTweetWithMedia(tweetText: String, in_reply_to_status_id: String!, image: UIImage!,error: (NSError) -> ()) {
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

    static func postTweet(tweetText: String!, in_reply_to_status_id: String!, mediaids: String!, error: (NSError) -> ()) {
        var param = Dictionary<String, String>()
        println("API/postTweet")
        
        param["status"] = (tweetText ?? "")
        
        if let tmp = in_reply_to_status_id {
            if tmp != ""{
                param["in_reply_to_status_id"] = tmp
            }
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
    
    static func gettweetwithid(tweets: [TWTRTweet]->(), tweetIDs: NSArray,error: (NSError) -> ()) {
        Twitter.sharedInstance().APIClient.loadTweetsWithIDs(tweetIDs as [AnyObject]) {(tweetsa, error) -> Void in
                if let ts = tweetsa as? [TWTRTweet] {
                    tweets(ts)
                } else {
                    println("Failed to load tweets: \(error.localizedDescription)")
                }
        }
    }
    
    static func getMyFavorites(tweets: [TWTRTweet]->(),error: (NSError) -> ()){
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