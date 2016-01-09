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
        //TODO: disable when we have a login
        loginData.prepareMockData()
        
        FaceBookLoginManager.fetchUserData(loginData) { (success) -> Void in
        
            if !success {
                completion(success: false)
                return
            }
            
            self.login(loginData, completion: { (success) -> () in
                completion(success: success)
            })
        }
    }

    func didRequestGoogleLogin(loginData: LoginData , completion: (success: Bool) -> Void) {
        
        //TODO: disable when we have a login
        //loginData.prepareMockData()
        
        self.login(loginData) { (success) -> () in
            
            completion(success: success)
        }
    }
    
    func login(loginData: LoginData , completion: (success: Bool) -> ()) -> Void {

        let jsonData = loginData.jsonToSend()
        guard let data = jsonData else { completion(success: false) ; return}
      
        // send data to server
        //TODO: change the url
        let url = NSURL(string: "http://ofer-fd-server.herokuapp.com/users")
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
           
            if response.statusCode == 200 || response.statusCode == 201 {
                
                let responseParams = try? NSJSONSerialization.JSONObjectWithData(incomingData, options: [])
                guard let params = responseParams else {self.handleFailure(loginData, completion: completion) ; return}
                
                loginData.userId = params[userIdKey] as? Int
                User.sharedInstance.updateWithLoginData(loginData)
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