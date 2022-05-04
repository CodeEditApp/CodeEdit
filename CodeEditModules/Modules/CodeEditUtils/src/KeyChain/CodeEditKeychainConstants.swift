//
//  CodeEditKeychainConstants.swift
//  CodeEditModules/CodeEditUtils
//
//  Created by Nanashi Li on 2022/04/14.
//

import Foundation
import Security

/// Constants used by the library
public enum CodeEditKeychainConstants {
    /// Specifies a Keychain access group. Used for sharing Keychain items between apps.
    public static var accessGroup: String { toString(kSecAttrAccessGroup) }

    /**
     A value that indicates when your app needs access to the data in a keychain item.
     The default value is AccessibleWhenUnlocked.
     For a list of possible values, see CodeEditKeychainAccessOptions.
     */
    public static var accessible: String { toString(kSecAttrAccessible) }

    /// Used for specifying a String key when setting/getting a Keychain value.
    public static var attrAccount: String { toString(kSecAttrAccount) }

    /// Used for specifying synchronization of keychain items between devices.
    public static var attrSynchronizable: String { toString(kSecAttrSynchronizable) }

    /// An item class key used to construct a Keychain search dictionary.
    public static var `class`: String { toString(kSecClass) }

    /// Specifies the number of values returned from the keychain. The library only supports single values.
    public static var matchLimit: String { toString(kSecMatchLimit) }

    /// A return data type used to get the data from the Keychain.
    public static var returnData: String { toString(kSecReturnData) }

    /// Used for specifying a value when setting a Keychain value.
    public static var valueData: String { toString(kSecValueData) }

    /// Used for returning a reference to the data from the keychain
    public static var returnReference: String { toString(kSecReturnPersistentRef) }

    /// A key whose value is a Boolean indicating whether or not to return item attributes
    public static var returnAttributes: String { toString(kSecReturnAttributes) }

    /// A value that corresponds to matching an unlimited number of items
    public static var secMatchLimitAll: String { toString(kSecMatchLimitAll) }

    static func toString(_ value: CFString) -> String {
        value as String
    }
}
