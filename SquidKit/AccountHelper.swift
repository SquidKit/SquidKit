//
//  ACAccount+SquidStore.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/17/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import UIKit
import Accounts


public protocol AccountHelperLoggable {
    func log<T>(@autoclosure _ output:() -> T?)
}

open class AccountHelper {
    
    let acAccountTypeIdentifier:NSString!
    
    open var accountUserFullName:String?
    open var accountUsername:String?
    open var accountIdentifier:String?
    
    // facebook required options
    open var facebookAppId:String?
    open var facebookPermissions:[String]?
    
    
    public init(accountIdentifier:NSString) {
        self.acAccountTypeIdentifier = accountIdentifier
    }
    
    open func authenticateWithCompletion(_ completion:(Bool) -> Void) {
        
        if (self.acAccountTypeIdentifier == ACAccountTypeIdentifierTwitter) {
            self.authenticateTwitter(completion)
        }
        else {
            completion(false)
        }
        
    }
    
    fileprivate func authenticateTwitter(_ completion:(Bool) -> Void) {
        let accountStore = ACAccountStore()
        let acAccountTypeTwitter = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        accountStore.requestAccessToAccounts(with: acAccountTypeTwitter, options: nil, completion: {[weak self] (success:Bool, error:NSError!) -> Void in
            if success {
                guard let strongSelf = self else {
                    completion(false)
                    return
                }
                if let twitterAccount = self?.firstAccount(accountStore, accountType: acAccountTypeTwitter) {
                    strongSelf.logAccountAccessResult("Twitter: ", userFullName: String.nonNilString(twitterAccount.userFullName, stringForNil:"<nil>"), userName: twitterAccount.username, userIdentifier: twitterAccount.identifier)
                }
            }
            
            completion(success)
        })
    }
    
    fileprivate func authenticateFacebook(_ completion:(Bool) -> Void) {
        let accountStore = ACAccountStore()
        let acAccountTypeFacebook = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierFacebook)
        accountStore.requestAccessToAccounts(with: acAccountTypeFacebook, options: self.makeFacebookOptions(), completion: {[weak self] (success:Bool, error:NSError!) -> Void in
            if success {
                guard let strongSelf = self else {
                    completion(false)
                    return
                }
                if let facebookAccount = self?.firstAccount(accountStore, accountType: acAccountTypeFacebook) {
                    strongSelf.logAccountAccessResult("Facebook: ", userFullName: String.nonNilString(facebookAccount.userFullName, stringForNil:"<nil>"), userName: facebookAccount.username, userIdentifier: facebookAccount.identifier)
                }
            }
            
            completion(success)
        })
    }
    
    fileprivate func logAccountAccessResult(_ accountPrefix:String, userFullName:String, userName:String, userIdentifier:String?) {
        
        if let loaggable = self as? AccountHelperLoggable {
            loaggable.log   (
                                accountPrefix + "\(userFullName)" + "\n" +
                                accountPrefix + "\(userName)" + "\n" +
                                accountPrefix + "\(userIdentifier)"
                            )
        }
        
    }
    
    fileprivate func makeFacebookOptions() -> [NSObject: AnyObject] {
        var options = [NSObject: AnyObject]()
        
        if let appId = self.facebookAppId {
            options[ACFacebookAppIdKey] = appId
        }
        if let permissions = self.facebookPermissions {
            options[ACFacebookPermissionsKey] = permissions
        }
        
        return options
    }
    
    fileprivate func firstAccount(_ accountStore:ACAccountStore, accountType:ACAccountType) -> ACAccount? {
        var account:ACAccount?
        
        if let accountsOfType = accountStore.accounts(with: accountType) as? [ACAccount] {
            if accountsOfType.count > 0 {
                account = accountsOfType[0]
            }
        }
        
        return account
    }
}
