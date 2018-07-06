//
//  GetFriendsLocation.swift
//  MapTrackUserHomeWork
//
//  Created by 黃翊倫 on 2018/6/26.
//  Copyright © 2018年 黃翊倫. All rights reserved.
//

import Foundation



struct ReturnData:Codable {
    var result:Bool = false
    var friends:[Friend] = []
}

struct Friend:Codable , Equatable {
    var id:String = ""
    var friendName:String = ""
    var lat:String = ""
    var lon:String = ""
    var lastUpdateDateTime:String = ""
}

class GetFriendsLocation {
    
    let targetURL :URL
    
    init(gflURL:URL) {
        self.targetURL = gflURL
    }
    
    typealias getFriendsHandler = (Error?,ReturnData?) -> Void
    
    func getFriends(doneHandler:@escaping getFriendsHandler){
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: targetURL) { (data, response, error) in
            
            if let error = error{
                print("Download Fail:\(error)")
                
                DispatchQueue.main.async {
                    doneHandler(error,nil)
                }
                
                return
            }
            
            guard let data = data else{
                print("Datat is nil.")
               
                let error = NSError(domain: "Data is nil.", code: -1, userInfo: nil)
                
                DispatchQueue.main.async {
            
                    doneHandler(error,nil)
                }
                return
            }
            
            let decoder = JSONDecoder()
            
            var results : ReturnData?

            do{

                results = try decoder.decode(ReturnData.self, from: data)
            }catch{
                print("resultserror：\(error)")
            }
            
            if  let results = results {
                print("returnData:\(results)")
                DispatchQueue.main.async {
                    doneHandler(nil,results)
                }
            }else{
                let error = NSError(domain: "Parse JSON Fail!", code: -1, userInfo: nil)
                
                DispatchQueue.main.async {
                    
                    doneHandler(error,nil)
                }
            }
        }
        task.resume()
    }
}
