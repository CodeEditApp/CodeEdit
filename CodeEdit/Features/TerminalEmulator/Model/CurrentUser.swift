//
//  CurrentUser.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/2/24.
//

import Foundation

/// Represents the currently logged in user.
///
/// Do not initialize this struct, instead use ``CurrentUser/getCurrentUser()`` to create and fill in the information.
struct CurrentUser {
    /// The user's username.
    let name: String
    /// The path to the user's shell executable.
    let shell: String
    /// The user's home directory path.
    let homeDir: String
    /// The users id.
    let uid: uid_t
    /// The user's group id.
    let gid: gid_t

    private init(name: String, shell: String, homeDir: String, uid: uid_t, gid: gid_t) {
        self.name = name
        self.shell = shell
        self.homeDir = homeDir
        self.uid = uid
        self.gid = gid
    }

    /// Gets the current user using the `getpwuid_r` syscall.
    static func getCurrentUser() -> CurrentUser? {
        let bufsize = sysconf(_SC_GETPW_R_SIZE_MAX)
        guard bufsize != -1 else { return nil }
        let buffer = UnsafeMutablePointer<Int8>.allocate(capacity: bufsize)
        defer {
            buffer.deallocate()
        }
        var pwd = passwd()
        // `result` will be set by getpwuid_r to point to `pwd` on success
        var result: UnsafeMutablePointer<passwd>?

        if getpwuid_r(getuid(), &pwd, buffer, bufsize, &result) != 0 { return nil }

        return CurrentUser(
            name: String(cString: pwd.pw_name),
            shell: String(cString: pwd.pw_shell),
            homeDir: String(cString: pwd.pw_dir),
            uid: pwd.pw_uid,
            gid: pwd.pw_gid
        )
    }
}
