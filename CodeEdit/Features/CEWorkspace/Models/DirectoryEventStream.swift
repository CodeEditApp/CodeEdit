//
//  DirectoryEventStream.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/26/23.
//

import Foundation

enum FSEvent: String {
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
///
/// The `callback` function will be called with all events that happened since the last event notification,
/// effectively batching all notifications every `debounceDuration`. This callback may not be called on a
/// predictable dispatch queue.
class DirectoryEventStream {
    typealias EventCallback = ([Event]) -> Void

    private var streamRef: FSEventStreamRef?
    private var callback: EventCallback
    private let debounceDuration: TimeInterval

    struct Event {
        let path: String
        let eventType: FSEvent
    }

    /// Initialize the event stream and begin listening for events.
    /// - Parameters:
    ///   - directory: The directory to monitor. The listener may receive a ``FSEvent/rootChanged`` event if this
    ///   directory is modified or moved.
    ///   - debounceDuration: The duration to delay notifications for to let the FS events API accumulates events.
    ///                       defaults to 0.1s.
    ///   - callback: A callback provided that the ``DirectoryEventStream`` will send events to. See
    ///               ``DirectoryEventStream``'s documentation for detailed information.
    init(directory: String, debounceDuration: TimeInterval = 0.1, callback: @escaping EventCallback) {
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
            FSEventStreamCreateFlags(
                kFSEventStreamCreateFlagUseCFTypes
                // This will listen for file changes
                | kFSEventStreamCreateFlagFileEvents
                // This provides additional information, like fileId,
                // it is useful when file renamed, because it's firing to separate events with old and new path,
                // but they can be linked by file id
                | kFSEventStreamCreateFlagUseExtendedData
                // Useful for us, always sends after the debounce duration.
                | kFSEventStreamCreateFlagNoDefer
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

    /// Handler for the fs event stream.
    private func eventStreamHandler(
        _ streamRef: ConstFSEventStreamRef,
        _ numEvents: Int,
        _ eventPaths: UnsafeMutableRawPointer,
        _ eventFlags: UnsafePointer<FSEventStreamEventFlags>,
        _ eventIds: UnsafePointer<FSEventStreamEventId>
    ) {
        guard let eventDictionaries = unsafeBitCast(eventPaths, to: NSArray.self) as? [NSDictionary] else {
            return
        }

        var events: [Event] = []

        for (index, dictionary) in eventDictionaries.enumerated() {
            // Get get file id use dictionary[kFSEventStreamEventExtendedFileIDKey] as? UInt64
            guard let path = dictionary[kFSEventStreamEventExtendedDataPathKey] as? String,
                  let event = getEventFromFlags(eventFlags[index])
            else {
                continue
            }

            events.append(.init(path: path, eventType: event))
        }

        callback(events)
    }

    /// Parses an ``FSEvent`` from the raw flag value.
    ///
    /// Often returns ``FSEvent/changeInDirectory`` as `FSEventStream` returns
    /// `kFSEventStreamEventFlagNone (0x00000000)` frequently without more information.
    /// - Parameter raw: The int value received from the FSEventStream
    /// - Returns: An ``FSEvent`` if a valid one was found, or `nil` otherwise.
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
