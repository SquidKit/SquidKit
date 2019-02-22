//
//  ACAccount+SquidStore.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/17/14.
//  Copyright © 2014-2019 Squid Store, LLC. All rights reserved.
//

import UIKit
import Accounts


public protocol AccountHelperLoggable {
    func log<T>( _ output:@autoclosure () -> T?)
}

open class AccountHelper {
    
    let acAccountTypeIdentifier:String!
    
    open var accountUserFullName:String?
    open var accountUsername:String?
    open var accountIdentifier:String?
    
    // facebook required options
    open var facebookAppId:String?
    open var facebookPermissions:[String]?
    
    
    public init(accountIdentifier:String) {
        self.acAccountTypeIdentifier = accountIdentifier
    }
    
    open func authenticateWithCompletion(_ completion:@escaping (Bool) -> Void) {
        
        if (self.acAccountTypeIdentifier == ACAccountTypeIdentifierTwitter) {
            self.authenticateTwitter(completion)
        }
        else {
            completion(false)
        }
        
    }
    
    open func authenticateTwitter(_ completion:@escaping (Bool) -> Void) {
        let accountStore = ACAccountStore()
        guard let acAccountTypeTwitter = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter) else {
            completion(false)
            return
        }
        accountStore.requestAccessToAccounts(with: acAccountTypeTwitter, options: nil, completion: {[weak self] (success:Bool, error:Error?) -> Void in
            if success {
                guard let strongSelf = self else {
                    completion(false)
                    return
                }
                if let twitterAccount = self?.firstAccount(accountStore, accountType: acAccountTypeTwitter) {
                    strongSelf.logAccountAccessResult("Twitter: ", userFullName: String.nonNilString(twitterAccount.userFullName, stringForNil:"<nil>"), userName: twitterAccount.username, userIdentifier: twitterAccount.identifier as String?)
                }
            }
            
            completion(success)
        })
    }
    
    open func authenticateFacebook(_ completion:@escaping (Bool) -> Void) {
        let accountStore = ACAccountStore()
        guard let acAccountTypeFacebook = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierFacebook) else {
            completion(false)
            return
        }
        accountStore.requestAccessToAccounts(with: acAccountTypeFacebook, options: self.makeFacebookOptions(), completion: {[weak self] (success:Bool, error:Error?) -> Void in
            if success {
                guard let strongSelf = self else {
                    completion(false)
                    return
                }
                if let facebookAccount = self?.firstAccount(accountStore, accountType: acAccountTypeFacebook) {
                    strongSelf.logAccountAccessResult("Facebook: ", userFullName: String.nonNilString(facebookAccount.userFullName, stringForNil:"<nil>"), userName: facebookAccount.username, userIdentifier: facebookAccount.identifier as String?)
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
                                accountPrefix + "\(String(describing: userIdentifier))"
                            )
        }
        
    }
    
    fileprivate func makeFacebookOptions() -> [AnyHashable : Any] {
        var options = [AnyHashable: Any]()
        
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
