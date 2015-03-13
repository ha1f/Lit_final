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
    let baseURL = "https://api.twitter.com"
    let version = "/1.1"
    
    init() {
        
    }
    
    class func callAPI(path: String, param: Dictionary<String, String>?, type: String) -> NSURLRequest!{
        let api = TwitterAPI()
        var clientError: NSError?
        let endpoint = api.baseURL + api.version + path
        
        return Twitter.sharedInstance().APIClient.URLRequestWithMethod(type, URL: endpoint, parameters: param, error: &clientError)
    }

    class func postTweet(tweetText: String, in_reply_to_status_id: String, error: (NSError) -> ()) {
        var param = Dictionary<String, String>()
        param["status"] = tweetText
        if in_reply_to_status_id != ""{
            param["in_reply_to_status_id"] = in_reply_to_status_id
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
                    println("succeeded")
                    var jsonError: NSError?
                    let json: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data,
                        options: nil,
                        error: &jsonError)
                    if let jsonArray = json as? NSDictionary {
                        var list: [TWTRTweet] = []
                        if let statuses = jsonArray["statuses"] as? NSArray {
                            tweets(TWTRTweet.tweetsWithJSONArray(statuses) as [TWTRTweet])
                        }
                    }
                } else {
                    error(err)
                    println("error")
                }
            })
        }
    }
    
    class func getHomeTimeline(tweets: [TWTRTweet]->(), error: (NSError) -> ()) {
        let request = callAPI("/statuses/home_timeline.json",param: nil, type: "GET")
        
        if request != nil {
            Twitter.sharedInstance().APIClient.sendTwitterRequest(request, completion: {
                response, data, err in
                if err == nil {
                    var jsonError: NSError?
                    let json: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data,
                        options: nil,
                        error: &jsonError)
                    if let jsonArray = json as? NSArray {
                        tweets(TWTRTweet.tweetsWithJSONArray(jsonArray) as [TWTRTweet])
                    }
                } else {
                    error(err)
                }
            })
        }
    }
    
    class func gettweetwithid(tweets: [TWTRTweet]->(), tweetIDs: NSArray,error: (NSError) -> ()) {
        Twitter.sharedInstance().APIClient
            .loadTweetsWithIDs(tweetIDs) {
                (tweetsa, error) -> Void in
                // handle the response or error
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
                        tweets(TWTRTweet.tweetsWithJSONArray(jsonArray) as [TWTRTweet])
                    }
                } else {
                    error(err)
                }
            })
        }
    }
    
}