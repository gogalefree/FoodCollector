//
//  FDServer+Groups.swift
//  FoodCollector
//
//  Created by Guy Freedman on 17/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import Foundation

extension FCMockServer {
    
    func postGroup(groupData: GroupData, completion: (success: Bool, groupData: GroupData?) -> Void) {
     
      //TODO: Implement with fdserver
        var groupData = groupData
        groupData.id = 1
        
        completion(success: true, groupData: groupData)
    }
}