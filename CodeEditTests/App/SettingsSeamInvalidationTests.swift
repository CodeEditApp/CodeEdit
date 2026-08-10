//
//  SettingsSeamInvalidationTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 10/08/2026.
//

import AppKit
import CETerminal
import SwiftUI
import Testing
import CodeEditSettings
@testable import CodeEdit

/// Covers the settings seam's *invalidation* half: that a change to the store actually re-renders a
/// view reading through `@SettingsValue`.
///
/// This is the production path end to end — `SettingsInjector` → `\.settingsRevision` +
/// `AppSettingsStore` → `@SettingsValue` — not a stand-in. It exists because the read/write tests
/// next door pass just as happily when nothing ever re-renders: they render once.
///
/// **What it does not prove.** It is a guard on the *outcome*, not on the mechanism: it passes with
/// `\.settingsRevision` injected and without it. Measured while writing it — with the revision
/// removed, with the accessor injected once above the observing view so it is never rewritten, and
/// with the probe behind an `EquatableView` returning `true` — the probe still re-rendered every
/// time. SwiftUI appears to re-evaluate a view holding `@Environment`-backed `DynamicProperty`
/// state whenever an ancestor's body reruns. That is the unspecified behaviour the revision key
/// replaces with a documented one, so this test cannot distinguish the two and should not be read
/// as evidence that it can.
@MainActor
@Suite(.serialized)
struct SettingsSeamInvalidationTests {

    /// A store over a temporary file, so these tests neither read nor overwrite the developer's real
    /// `settings.json` — and cannot race any other suite.
    private func makeStore() throws -> AppSettingsStore {
        let directory = URL.temporaryDirectory.appending(path: "SettingsSeam-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return AppSettingsStore(settingsURL: directory.appending(path: "settings.json"))
    }

    private func setCursorBlink(_ value: Bool, on store: AppSettingsStore) {
        var section = store.value(TerminalSettings.self)
        section.cursorBlink = value
        store.setValue(section)
    }
    /// Records the value observed on every body evaluation, so a *missing* re-render is a visible
    /// absence rather than a stale-but-plausible reading.
    private final class BodyRecorder {
        var observed: [Bool] = []
    }

    private struct RevisionProbe: View {
        @SettingsValue(TerminalSettings.self, \.cursorBlink)
        private var cursorBlink

        let recorder: BodyRecorder

        var body: some View {
            recorder.observed.append(cursorBlink)
            return Color.clear
        }
    }

    /// Hosts `view` without ever ordering the window front — an on-screen window in the shared
    /// app-hosted test process destabilised the whole plan. Attaching the hosting view and laying
    /// it out is enough to drive SwiftUI's update cycle.
    private func host<V: View>(_ view: V) -> (NSWindow, NSHostingView<V>) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 64, height: 64),
            styleMask: [.borderless],
            backing: .buffered,
            defer: true
        )
        let hostingView = NSHostingView(rootView: view)
        window.contentView = hostingView
        hostingView.layoutSubtreeIfNeeded()
        return (window, hostingView)
    }

    private func settle<V: View>(_ hostingView: NSHostingView<V>, until: () -> Bool) async {
        var attempts = 0
        while !until() && attempts < 200 {
            attempts += 1
            hostingView.layoutSubtreeIfNeeded()
            try? await Task.sleep(for: .milliseconds(10))
        }
    }

    @Test
    func changingSettingsBumpsTheRevision() throws {
        let store = try makeStore()
        let before = store.revision

        setCursorBlink(!store.value(TerminalSettings.self).cursorBlink, on: store)

        #expect(store.revision == before + 1)
    }

    /// Guards the **outcome** users care about: a settings change reaches a view reading through the
    /// seam.
    ///
    /// It deliberately does NOT isolate the `\.settingsRevision` mechanism — it passes with and
    /// without that key, because SwiftUI also re-evaluates the probe when `SettingsInjector`'s body
    /// reruns. Do not read a pass here as evidence the revision signal works; that is
    /// ``changingSettingsBumpsTheRevision``'s job. What this catches is the seam silently failing to
    /// deliver updated values at all — the failure mode that has recurred most on this branch.
    @Test
    func settingsChangeReachesAViewThroughTheSeam() async throws {
        let store = try makeStore()
        setCursorBlink(false, on: store)

        let recorder = BodyRecorder()
        let (window, hostingView) = host(SettingsInjector(store: store) { RevisionProbe(recorder: recorder) })
        defer { window.contentView = nil }

        await settle(hostingView) { !recorder.observed.isEmpty }
        // The probe reached the real store rather than `DefaultSettingsReader`, and saw the seeded
        // value. (Defaults would also read `false` here, which is why the assertion that matters is
        // the one below: defaults can never *change*.)
        #expect(recorder.observed.last == false)

        setCursorBlink(true, on: store)

        await settle(hostingView) { recorder.observed.last == true }
        #expect(
            recorder.observed.last == true,
            "A settings change did not re-render a view reading through @SettingsValue"
        )
    }
}
