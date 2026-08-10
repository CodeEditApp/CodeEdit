//
//  SettingsValueWriteTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 09/08/2026.
//

import AppKit
import CESourceControl
import SwiftUI
import Testing
import CodeEditSettings
@testable import CodeEdit

/// Covers `@SettingsValue`'s write half — the `nonmutating set` and the `projectedValue` binding —
/// end to end: seed a section, render a real view, have it write one field, and assert the whole
/// section came back through the accessor with that field changed.
///
/// **Why these live in the app test target rather than `CodeEditModules/Tests`.** `@SettingsValue`
/// is a `DynamicProperty` that resolves its accessor from `@Environment`, and `@Environment` only
/// resolves inside a view SwiftUI is actually rendering. Constructing the wrapper directly would
/// silently read `DefaultSettingsReader` and assert nothing. Rendering needs an app-hosted runner
/// with a real run loop, which the package test bundles are not (the same constraint that sent
/// `CENotifications`' tests back here). The write-capable double, `RecordingSettingsStore`, is
/// already here too.
@MainActor
@Suite(.serialized)
struct SettingsValueWriteTests {
    /// Captures what the view saw when it rendered, so the read side is proven rather than assumed.
    private final class ObservedValue {
        var value: Bool?
    }

    /// Writes through `wrappedValue`'s `nonmutating set`.
    private struct WrappedValueProbe: View {
        @SettingsValue(SourceControlSettings.self, \.general.sourceControlIsEnabled)
        private var sourceControlIsEnabled

        let observed: ObservedValue

        var body: some View {
            Color.clear.onAppear {
                observed.value = sourceControlIsEnabled
                sourceControlIsEnabled = true
            }
        }
    }

    /// Writes through the `Binding` vended by `projectedValue`, the way a `Toggle` would.
    private struct ProjectedValueProbe: View {
        @SettingsValue(SourceControlSettings.self, \.general.sourceControlIsEnabled)
        private var sourceControlIsEnabled

        let observed: ObservedValue

        var body: some View {
            Color.clear.onAppear {
                let binding: Binding<Bool> = $sourceControlIsEnabled
                observed.value = binding.wrappedValue
                binding.wrappedValue = true
            }
        }
    }

    /// A store seeded with two **non-default** fields (both default to `true`), so a view that
    /// failed to reach this store would observe `true` and fail the read assertion.
    ///
    /// `refreshStatusLocally` is the untouched sibling: the probes never write it, so it is what
    /// distinguishes a read-modify-write from a section rebuilt at its defaults.
    private func makeSeededStore() -> RecordingSettingsStore {
        var section = SourceControlSettings()
        section.general.sourceControlIsEnabled = false
        section.general.refreshStatusLocally = false
        return RecordingSettingsStore([SourceControlSettings.settingsKey: section])
    }

    /// Hosts `view` long enough for SwiftUI to evaluate its body, then waits until it writes.
    ///
    /// The window is deliberately **never ordered front**: attaching the hosting view is enough to
    /// drive the update cycle, and an on-screen window makes the shared app-hosted test process
    /// talk to the window server, which destabilised the whole test plan when this suite ran
    /// concurrently with others.
    private func render(_ view: some View, until store: RecordingSettingsStore) async {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 64, height: 64),
            styleMask: [.borderless],
            backing: .buffered,
            defer: true
        )
        defer { window.contentView = nil }

        let hostingView = NSHostingView(rootView: view)
        window.contentView = hostingView
        hostingView.layoutSubtreeIfNeeded()

        var attempts = 0
        while store.writes.isEmpty && attempts < 200 {
            attempts += 1
            try? await Task.sleep(for: .milliseconds(10))
        }
    }

    @Test
    func wrappedValueSetterWritesTheWholeSectionBack() async throws {
        let store = makeSeededStore()
        let observed = ObservedValue()

        await render(
            WrappedValueProbe(observed: observed).environment(\.settingsAccessor, store),
            until: store
        )

        // The view read through the injected store, not through defaults.
        #expect(observed.value == false)

        let written = try #require(
            store.lastWrite(SourceControlSettings.self),
            "@SettingsValue's setter never reached the accessor"
        )
        #expect(written.general.sourceControlIsEnabled == true)
        // Read-modify-write, not replace-with-defaults: the sibling field the probe never touched
        // still carries its seeded, non-default value.
        #expect(written.general.refreshStatusLocally == false)
        #expect(store.value(SourceControlSettings.self).general.sourceControlIsEnabled == true)
    }

    @Test
    func projectedValueBindingWritesTheWholeSectionBack() async throws {
        let store = makeSeededStore()
        let observed = ObservedValue()

        await render(
            ProjectedValueProbe(observed: observed).environment(\.settingsAccessor, store),
            until: store
        )

        #expect(observed.value == false)

        let written = try #require(
            store.lastWrite(SourceControlSettings.self),
            "@SettingsValue's projectedValue binding never reached the accessor"
        )
        #expect(written.general.sourceControlIsEnabled == true)
        #expect(written.general.refreshStatusLocally == false)
        #expect(store.value(SourceControlSettings.self).general.sourceControlIsEnabled == true)
    }
}
