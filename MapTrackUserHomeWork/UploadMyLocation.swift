//
//  UploadMyLocation.swift
//  MapTrackUserHomeWork
//
//  Created by 黃翊倫 on 2018/6/25.
//  Copyright © 2018年 黃翊倫. All rights reserved.
//

import Foundation

class UpdateMyLocation {
    
    let targetURL: URL
    
    init(updateURL:URL) {
        self.targetURL = updateURL
    }
    typealias updateHandler = (Error?,Bool?) -> Void
    
    func update(doneHanlder:@escaping updateHandler) {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: targetURL) { (data, response, error) in
            if let error = error {
                
                DispatchQueue.main.async {
                   doneHanlder(error,false)
                }
                return
            }
            
            guard let data = data  else{
                print("data is nil")
                
                let error = NSError(domain: "data is nil", code: -1, userInfo: nil)
                
                DispatchQueue.main.async {
                    doneHanlder(error,false)
                }
                return
            }
            
            let str =  NSString(data:data ,encoding: String.Encoding.utf8.rawValue)
            print(str)
        }
         task.resume()
        
    }
}

