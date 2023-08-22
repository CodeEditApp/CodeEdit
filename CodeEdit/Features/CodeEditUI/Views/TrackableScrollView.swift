//
//  TrackableScrollView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 19.01.23.
//

//  Inspired by SwiftUITrackableScrollView by Natchanon A.
//  https://github.com/maxnatchanon/trackable-scroll-view

import SwiftUI

private struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    typealias Value = [CGFloat]

    static var defaultValue: [CGFloat] = [0]

    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        value.append(contentsOf: nextValue())
    }
}

struct TrackableScrollView<Content>: View where Content: View {
    let axes: Axis.Set
    let showIndicators: Bool
    @Binding var contentOffset: CGFloat
    @Binding var contentTrailingOffset: CGFloat?
    let content: Content

    init(
        _ axes: Axis.Set = .vertical,
        showIndicators: Bool = true,
        contentOffset: Binding<CGFloat>,
        @ViewBuilder content: () -> Content
    ) {
        self.axes = axes
        self.showIndicators = showIndicators
        self._contentOffset = contentOffset
        self._contentTrailingOffset = Binding.constant(nil)
        self.content = content()
    }

    init(
        _ axes: Axis.Set = .vertical,
        showIndicators: Bool = true,
        contentOffset: Binding<CGFloat>,
        contentTrailingOffset: Binding<CGFloat?>?,
        @ViewBuilder content: () -> Content
    ) {
        self.axes = axes
        self.showIndicators = showIndicators
        self._contentOffset = contentOffset
        self._contentTrailingOffset = contentTrailingOffset ?? Binding.constant(nil)
        self.content = content()
    }

    var body: some View {
        GeometryReader { outsideProxy in
            ScrollView(self.axes, showsIndicators: self.showIndicators) {
                ZStack(alignment: self.axes == .vertical ? .top : .leading) {
                    GeometryReader { insideProxy in
                        Color.clear
                            .preference(
                                key: ScrollViewOffsetPreferenceKey.self,
                                value: [
                                    self.calculateContentOffset(
                                        fromOutsideProxy: outsideProxy,
                                        insideProxy: insideProxy
                                    ),
                                    self.calculateContentTrailingOffset(
                                        fromOutsideProxy: outsideProxy,
                                        insideProxy: insideProxy
                                    )
                                ]
                            )
                    }
                    VStack {
                        self.content
                    }
                }
            }
            .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
                self.contentOffset = value[0]
                if self.contentTrailingOffset != nil {
                    self.contentTrailingOffset = value[1]
                }
            }
        }
    }

    private func calculateContentOffset(
        fromOutsideProxy outsideProxy: GeometryProxy,
        insideProxy: GeometryProxy
    ) -> CGFloat {
        if axes == .vertical {
            return insideProxy.frame(in: .global).minY - outsideProxy.frame(in: .global).minY
        } else {
            return insideProxy.frame(in: .global).minX - outsideProxy.frame(in: .global).minX
        }
    }

    private func calculateContentTrailingOffset(
        fromOutsideProxy outsideProxy: GeometryProxy,
        insideProxy: GeometryProxy
    ) -> CGFloat {
        if axes == .vertical {
            return insideProxy.frame(in: .global).maxY - outsideProxy.frame(in: .global).maxY
        } else {
            return insideProxy.frame(in: .global).maxX - outsideProxy.frame(in: .global).maxX
        }
    }
}
