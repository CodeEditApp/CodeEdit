//
//  DirectoryEventStream.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/26/23.
//

import Foundation

enum FSEvent {
    case changeInDirectory
    case rootChanged
    case itemChangedOwner
    case itemCreated
    case itemCloned
    case itemModified
    case itemRemoved
    case itemRenamed
}

class DirectoryEventStream {
    typealias EventCallback = (String, FSEvent, Bool) -> Void

    private var streamRef: FSEventStreamRef?
    private var callback: EventCallback
    private let debounceDuration: TimeInterval = 0.05

    init(directory: String, callback: @escaping EventCallback) {
        self.callback = callback
        let selfPtr = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        var context = FSEventStreamContext(
            version: 0,
            info: selfPtr,
            retain: nil,
            release: nil,
            copyDescription: nil
        )
        let contextPtr = withUnsafeMutablePointer(to: &context) { ptr in UnsafeMutablePointer(ptr) }

        let cfDirectory = directory as CFString
        let pathsToWatch = [cfDirectory] as CFArray

        if let ref = FSEventStreamCreate(
            kCFAllocatorDefault,
            // swiflint:ignore:next opening_brace
            { streamRef, clientCallBackInfo, numEvents, eventPaths, eventFlags, eventIds in
                guard let clientCallBackInfo else { return }
                Unmanaged<DirectoryEventStream>
                    .fromOpaque(clientCallBackInfo)
                    .takeUnretainedValue()
                    .eventStreamHandler(streamRef, numEvents, eventPaths, eventFlags, eventIds)
            },
            contextPtr,
            pathsToWatch,
            UInt64(kFSEventStreamEventIdSinceNow),
            debounceDuration,
            UInt32(
                kFSEventStreamCreateFlagNoDefer
                & kFSEventStreamCreateFlagWatchRoot
            )
        ) {
            self.streamRef = ref
            FSEventStreamSetDispatchQueue(ref, DispatchQueue(label: "com.CodeEdit.app.fseventsqueue", qos: .default))
            FSEventStreamStart(ref)
        }
    }

    deinit {
        streamRef = nil
    }

    /// Cancels the fs events watcher.
    /// This class will have to be re-initialized to begin streaming events again.
    public func cancel() {
        streamRef = nil
    }

    private func eventStreamHandler(
        _ streamRef: ConstFSEventStreamRef,
        _ numEvents: Int,
        _ eventPaths: UnsafeMutableRawPointer,
        _ eventFlags: UnsafePointer<FSEventStreamEventFlags>,
        _ eventIds: UnsafePointer<FSEventStreamEventId>
    ) {
        var eventPaths = eventPaths.bindMemory(to: UnsafePointer<CChar>.self, capacity: numEvents)
        for idx in 0..<numEvents {
            let pathPtr = eventPaths.advanced(by: idx).pointee
            let path = String(cString: pathPtr)
            let flags = eventFlags.advanced(by: idx).pointee
            guard let event = getEventFromFlags(flags) else {
                continue
            }
            callback(
                path,
                event,
                Int(flags) & kFSEventStreamEventFlagMustScanSubDirs > 0 ? true : false // Deep scan?
            )
        }
    }

    func getEventFromFlags(_ raw: FSEventStreamEventFlags) -> FSEvent? {
        if raw == 0 {
            return .changeInDirectory
        } else if raw & UInt32(kFSEventStreamEventFlagRootChanged) > 0 {
            return .rootChanged
        } else if raw & UInt32(kFSEventStreamEventFlagItemChangeOwner) > 0 {
            return .itemChangedOwner
        } else if raw & UInt32(kFSEventStreamEventFlagItemCreated) > 0 {
            return .itemCreated
        } else if raw & UInt32(kFSEventStreamEventFlagItemCloned) > 0 {
            return .itemCloned
        } else if raw & UInt32(kFSEventStreamEventFlagItemModified) > 0 {
            return .itemModified
        } else if raw & UInt32(kFSEventStreamEventFlagItemRemoved) > 0 {
            return .itemRemoved
        } else if raw & UInt32(kFSEventStreamEventFlagItemRenamed) > 0 {
            return .itemRenamed
        } else {
            return nil
        }
    }
}
