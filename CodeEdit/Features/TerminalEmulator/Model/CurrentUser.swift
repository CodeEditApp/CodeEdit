//
//  CurrentUser.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/2/24.
//

import Foundation

struct CurrentUser {
    let name: String
    let shell: String
    let homeDir: String
    let uid: uid_t
    let gid: gid_t

    private init(name: String, shell: String, homeDir: String, uid: uid_t, gid: gid_t) {
        self.name = name
        self.shell = shell
        self.homeDir = homeDir
        self.uid = uid
        self.gid = gid
    }

    static func getCurrentUser() -> CurrentUser? {
        let bufsize = sysconf(_SC_GETPW_R_SIZE_MAX)
        guard bufsize != -1 else { return nil }
        let buffer = UnsafeMutablePointer<Int8>.allocate(capacity: bufsize)
        defer {
            buffer.deallocate()
        }
        var pwd = passwd()
        // points to `pwd`
        var result: UnsafeMutablePointer<passwd>? = UnsafeMutablePointer<passwd>.allocate(capacity: 1)

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
