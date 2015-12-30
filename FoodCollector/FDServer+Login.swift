//
//  FDServer+Login.swift
//  FoodCollector
//
//  Created by Guy Freedman on 26/12/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

/*
      To Simulate login:

      FCModel.sharedInstance.foodCollectorWebServer.didRequestFacebookLogin(<#T##completion: (success: Bool) -> Void##(success: Bool) -> Void#>)
      FCModel.sharedInstance.foodCollectorWebServer.didRequestGoogleLogin(<#T##completion: (success: Bool) -> Void##(success: Bool) -> Void#>)
*/

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
        loginData.prepareMockData()
        
        self.login(loginData) { (success) -> () in
            
            completion(success: success)
        }
    }
    
    func login(loginData: LoginData , completion: (success: Bool) -> ()) -> Void {
        

        // let data = loginData.jsonToSend()
        // send data to server
        
        //add the id from the server
        loginData.userId = 1
        
        //update User Class with id
        User.sharedInstance.updateWithLoginData(loginData)
        
        completion(success: true)
        
    }
    
}