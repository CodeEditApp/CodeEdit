//
//  File.swift
//  
//
//  Created by Matthijs Eikelenboom on 09/10/2022.
//

import Foundation

final class FolderMonitor {

    private let folderToMonitor: URL

    /// A file descriptor for the monitored folder.
    private var monitoredFolderFileDescriptor: CInt = -1

    /// A dispatch source to monitor a file descriptor created from the folder.
    private var folderMonitorSource: DispatchSourceFileSystemObject?

    /// A dispatch queue used for sending file changes in the folder.
    private let folderMonitorQueue = DispatchQueue(label: "FolderMonitorQueue", attributes: .concurrent)

    /// When there are changes in the folder, this is the function that gets triggered
    internal var folderDidChange: () -> Void = { }

    init(url: URL) {
        self.folderToMonitor = url
    }

    /// Start monitoring the folder
    func startMonitoring() {
        guard folderMonitorSource == nil && monitoredFolderFileDescriptor == -1 else {
            return
        }
        // Open the folder referenced by URL for monitoring only.
        monitoredFolderFileDescriptor = open(folderToMonitor.path, O_EVTONLY)

        // Define a dispatch source monitoring the folder for additions, deletions, and renamings.
        folderMonitorSource = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: monitoredFolderFileDescriptor,
            eventMask: .write,
            queue: folderMonitorQueue
        )

        // Define the block to call when a file change is detected.
        folderMonitorSource?.setEventHandler { [weak self] in
            self?.folderDidChange()
        }

        // Define a cancel handler to ensure the directory is closed when the source is cancelled.
        folderMonitorSource?.setCancelHandler { [weak self] in
            guard let self = self else { return }
            close(self.monitoredFolderFileDescriptor)
            self.monitoredFolderFileDescriptor = -1
            self.folderMonitorSource = nil
        }

        // Start monitoring the directory via the source.
        folderMonitorSource?.resume()
    }

    func stopMonitoring() {
        folderMonitorSource?.cancel()
    }

    deinit {
        self.folderMonitorSource?.cancel()
    }

}
