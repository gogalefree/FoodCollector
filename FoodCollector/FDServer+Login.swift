//
//  FDServer+Login.swift
//  FoodCollector
//
//  Created by Guy Freedman on 26/12/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//


import Foundation

extension FCMockServer {
    
    func didRequestFacebookLogin(completion: (success: Bool) -> Void) {
        
        let loginData = LoginData(.Facebook)
        User.sharedInstance.loginData = loginData
        FaceBookLoginManager.fetchUserData(loginData) { (success) -> Void in
        
            completion(success: success)
        }
    }

    func login(completion: (success: Bool) -> ()) -> Void {

        guard let loginData = User.sharedInstance.loginData else {
            completion(success: false)
            return
        }
        
        guard let data = loginData.jsonToSend() else {
            completion(success: false)
            return
        }
      
        let url = NSURL(string: /*baseUrlString*/ "https://ofer-fd-server.herokuapp.com/" + "users.json")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod  = "POST"
        request.HTTPBody    = data
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
            taskData, response, error -> () in

            if error != nil {
            
                self.handleFailure(loginData, completion: completion)
                return
            }
            
            guard let response = response as? NSHTTPURLResponse , incomingData = taskData else {self.handleFailure(loginData, completion: completion) ; return}
           
            print("response: \(response)")
            if response.statusCode == 200 || response.statusCode == 201 {
                
                let responseParams = try? NSJSONSerialization.JSONObjectWithData(incomingData, options: [])
                guard let params = responseParams else {self.handleFailure(loginData, completion: completion) ; return}
                
                loginData.userId = params[userIdKey] as? Int
                User.sharedInstance.updateWithLoginData()
                completion(success: true)
            }
            
            else {
                
                self.handleFailure(loginData, completion: completion)
            }
            
        }).resume()
    }
    
    func handleFailure(loginData: LoginData , completion: (success: Bool) -> ()){
        
        loginData.isLoggedIn = false
        completion(success: false)
    }
}