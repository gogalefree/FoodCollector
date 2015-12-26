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
        loginData.prepareMockData()
        
        self.login(loginData) { (success) -> () in
        
            completion(success: success)
        }
    }

    func didRequestGoogleLogin(completion: (success: Bool) -> Void) {
        
        let loginData = LoginData(.Google)
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