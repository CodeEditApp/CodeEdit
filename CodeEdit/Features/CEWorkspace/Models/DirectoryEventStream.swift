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

/// Creates a stream of events using the File System Events API.
///
/// The stream of events is started immediately upon initialization, and will only be stopped when either `cancel`
/// is called, or the object is deallocated. The stream is also configured to debounce notifications to happen
/// according to the `debounceDuration` parameter. This directly corresponds with the `latency` parameter in
/// `FSEventStreamCreate`, which will delay notifications until `latency` has passed at which point it will send all
/// the notifications built up during that period of time.
///
/// Use the `callback` parameter to listen for notifications.
/// Notifications are automatically filtered to include certain events, but the FS event API doesn't always correctly
/// flag events so use caution when handling events as they can come frequently.
class DirectoryEventStream {
    typealias EventCallback = (String, FSEvent, Bool) -> Void

    private var streamRef: FSEventStreamRef?
    private var callback: EventCallback
    private let debounceDuration: TimeInterval

    /// Initialize the event stream and begin listening for events.
    /// - Parameters:
    ///   - directory: The directory to monitor. The listener may receive a `FSEvent.rootChanged` event if this
    ///   directory is modified or moved.
    ///   - debounceDuration: The duration to delay notifications for to let the FS events API accumulates events.
    ///   - callback: A callback provided that `DirectoryEventStream` will send events to.
    init(directory: String, debounceDuration: TimeInterval = 0.05, callback: @escaping EventCallback) {
        self.debounceDuration = debounceDuration
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
            FSEventStreamSetDispatchQueue(ref, DispatchQueue.global(qos: .default))
            FSEventStreamStart(ref)
        }
    }

    deinit {
        if let streamRef {
            FSEventStreamStop(streamRef)
            FSEventStreamInvalidate(streamRef)
            FSEventStreamRelease(streamRef)
        }
        streamRef = nil
    }

    /// Cancels the events watcher.
    /// This class will have to be re-initialized to begin streaming events again.
    public func cancel() {
        if let streamRef {
            FSEventStreamStop(streamRef)
            FSEventStreamInvalidate(streamRef)
            FSEventStreamRelease(streamRef)
        }
        streamRef = nil
    }

    private func eventStreamHandler(
        _ streamRef: ConstFSEventStreamRef,
        _ numEvents: Int,
        _ eventPaths: UnsafeMutableRawPointer,
        _ eventFlags: UnsafePointer<FSEventStreamEventFlags>,
        _ eventIds: UnsafePointer<FSEventStreamEventId>
    ) {
        let eventPaths = eventPaths.bindMemory(to: UnsafePointer<CChar>.self, capacity: numEvents)
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

    /// Parses an `FSEvent` from the raw flag value.
    ///
    /// This more often than not returns `.changeInDirectory` as `FSEventStream` more often than not
    /// returns `kFSEventStreamEventFlagNone (0x00000000)`.
    /// - Parameter raw: The int value received from the FSEventStream
    /// - Returns: An FSEvent if a valid one was found.
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
