//
//  FCServerProtocol.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//


import CoreLocation
import Foundation
import UIKit

protocol FCServerProtocol {
    
    
    
    ///
    /// reports device token to our server to use for APNS.
    /// old token can be nil (for the first report).
    ///
    func reportDeviceTokenForPushWithDeviceNewToken(newtoken:String)
    
        
    func reportDeviceUUID(uuid: String)
    
    
    ///
    /// reports the user’s last known location. the server uses this information
    ///  to send push notification of a new Publication with defined radius.
    /// called at launch & before the app goes to background mode.
    ///
    func reportUserLocation()
    
    ///
    /// fetch all publications from server.
    ///
    func downloadAllPublications()
    
    ///
    /// fetch publication with a certain identifier
    /// called after a newPublication push notification had arrived.
    func fetchPublicationWithIdentifier(identifier: PublicationIdentifier ,completion: (publication: FCPublication) -> Void)

    
        ///
    /// reports a Report of a Publication by a user that arrived at a publication
    ///  spot
    
    
    func postReportforPublication(report: PublicationReport)
    
    ///
    /// informs the server that a user deleted his publication
    ///
    func takePublicationOffAir(publication: Publication, completion: (success:Bool)->Void)
    
    ///
    /// post a new Publication to the server
    ///
    func postNewCreatedPublication(params:[String:AnyObject],completion:(success: Bool, params: [String: AnyObject])->())
    
    ///
    /// post an edited Publication to the server. the publication must be expired or taken off air before
    ///
    func postEditedPublication(params:[String:AnyObject],publication: Publication,
        completion:(success: Bool,  version: Int)->())
   
    
    //register user for publication
    func registerUserForPublication(registration: PublicationRegistration, completion: (success:Bool) -> Void)
    
    ///
    /// unRegister or unregister the current user to a publication
    
    func unRegisterUserFromComingToPickUpPublication(publication: Publication, completion: (success: Bool) -> Void)
    
   
    
    //delete Publication
    func deletePublication(publication: Publication, completion: (success: Bool) -> ())
    ///
    ///sends user feedback to server
    func sendFeedback(report: String)
    
    ///
    ///LogIn with facebook
    ///
    func didRequestFacebookLogin(completion: (success: Bool) -> Void)
    
    ///
    ///LogIn to Foodonet Server
    ///
    func login(completion: (success: Bool) -> ()) -> Void
    
    ///
    ///Post new group to Foodonet Server
    ///
    func postGroup(groupData: GroupData, completion: (success: Bool, groupData: GroupData?) -> Void)
    
    ///
    ///Post new group members to Foodonet Server
    ///
    func postGroupMembers(members: [GroupMember]) -> Void

    ///
    ///Delete group from Foodonet Server
    ///
    func deleteGroup(groupToDelete: Group)
   
    ///
    ///Delete group members from Foodonet Server
    ///
    func deleteGroupMember(memberToDelete: GroupMember)

    //core data fetch reports for publication
    func reportsForPublication(publication:Publication,
        context: NSManagedObjectContext,
        completion: (success: Bool) -> Void )
    
    //fetch groups
    func fetchGroupsForUser(contecxt: NSManagedObjectContext)
}

