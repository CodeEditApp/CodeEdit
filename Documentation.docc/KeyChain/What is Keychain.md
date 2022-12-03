#  What is Keychain?

Keychain is the password management system in macOS, developed by Apple. It was introduced with Mac OS 8.6, and has been included in all subsequent versions of the operating system, now known as macOS. A Keychain can contain various types of data: passwords, private keys, certificates, and secure notes. 

## Notice:
This build of CodeEditKeychain could change at anytime if bugs or breaking changes are found in the module. 

## Usage

### String

```swift
let keychain = CodeEditKeychain()
keychain.set("hello world", forKey: "my key")
keychain.get("my key")
```

### Boolean

```swift
let keychain = CodeEditKeychain()
keychain.set(true, forKey: "my key")
keychain.getBool("my key")
```

### Data

```swift
let keychain = CodeEditKeychain()
keychain.set(dataObject, forKey: "my key")
keychain.getData("my key")
```
### Removing Keys

```swift
let keychain = CodeEditKeychain()
keychain.delete("my key")
```

### Return All Keys

```swift
let keychain = CodeEditKeychain()
keychain.allKeys // Returns the names of all keys
```

### Check if operation was successful

One can verify if `set`, `delete` and `clear` methods finished successfully by checking their return values. Those methods return `true` on success and `false` on error.

```swift
if keychain.set("hello world", forKey: "my key") {
  // Keychain item is saved successfully
} else {
  // Report error
}
```

### Setting key prefix

One can pass a `keyPrefix` argument when initializing a `CodeEditKeychain` object. The string passed in `keyPrefix` argument will be used as a prefix to **all the keys** used in `set`, `get`, `getData` and `delete` methods. Adding a prefix to the keychain keys can be useful in unit tests. This prevents the tests from changing the Keychain keys that are used when the app is launched manually.

```swift
let keychain = CodeEditKeychain(keyPrefix: "myTestKey_")
keychain.set("hello world", forKey: "hello") // Value will be stored under "myTestKey_hello" key
```
