//
//  AboutDetailView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 21/01/2023.
//

import SwiftUI

struct AboutDetailView<Content: View>: View {
    var title: String

    @Binding var aboutMode: AboutMode

    var namespace: Namespace.ID

    @ViewBuilder
    var content: Content

    let smallTitlebarHeight: CGFloat = 28
    let mediumTitlebarHeight: CGFloat = 113
    let largeTitlebarHeight: CGFloat = 231

    var maxScrollOffset: CGFloat {
        smallTitlebarHeight - mediumTitlebarHeight
    }

    var currentOffset: CGFloat {
        getScrollAdjustedValue(
            minValue: 22,
            maxValue: 14,
            minOffset: 0,
            maxOffset: maxScrollOffset
        )
    }

    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        OffsettableScrollView(showsIndicator: false) { offset in
            scrollOffset = offset.y
        } content: {
            Spacer(minLength: mediumTitlebarHeight + 8)
            content
                .padding(.horizontal)
                .padding(.bottom, 8)
                .matchedGeometryEffect(id: "ContentView", in: namespace, properties: .position, anchor: .top)
        }
        .transition(.opacity.combined(with: .offset(y: largeTitlebarHeight)))
        .frame(maxWidth: .infinity)

        VStack(spacing: 0) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .matchedGeometryEffect(id: "AppIcon", in: namespace)
                .frame(
                    width: getScrollAdjustedValue(
                        minValue: 48,
                        maxValue: 0,
                        minOffset: 0,
                        maxOffset: maxScrollOffset
                    ),
                    height: getScrollAdjustedValue(
                        minValue: 48,
                        maxValue: 0,
                        minOffset: 0,
                        maxOffset: maxScrollOffset
                    )
                )
                .opacity(
                    getScrollAdjustedValue(
                        minValue: 1,
                        maxValue: 0,
                        minOffset: 0,
                        maxOffset: maxScrollOffset
                    )
                )
                .padding(.top, getScrollAdjustedValue(
                    minValue: smallTitlebarHeight,
                    maxValue: 0,
                    minOffset: 0,
                    maxOffset: maxScrollOffset
                ))
                .padding(.bottom, getScrollAdjustedValue(
                    minValue: 8,
                    maxValue: 0,
                    minOffset: 0,
                    maxOffset: maxScrollOffset
                ))

            Button {
                aboutMode = .about
            } label: {
                    Text(title)
                        .foregroundColor(.primary)
                        .font(.system(
                            size: getScrollAdjustedValue(
                                minValue: 22,
                                maxValue: 14,
                                minOffset: 0,
                                maxOffset: maxScrollOffset
                            ),
                            weight: .bold
                        ))

                    .fixedSize(horizontal: true, vertical: false)
                    .frame(minHeight: smallTitlebarHeight)
                    .padding(.horizontal)
                    .overlay(alignment: .leading) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.secondary)
                    }
                    .matchedGeometryEffect(id: "Title", in: namespace, properties: .position, anchor: .center)
            }
            .buttonStyle(.plain)

            if currentOffset <= 14.0 {
                Divider()
            }
        }
        .padding(0)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial.opacity(currentOffset <= 14.0 ? 1 : 0))
    }

    func getScrollAdjustedValue(
        minValue: CGFloat,
        maxValue: CGFloat,
        minOffset: CGFloat,
        maxOffset: CGFloat
    ) -> CGFloat {
        let valueRange = maxValue - minValue
        let offsetRange = maxOffset - minOffset
        let currentOffset = scrollOffset
        let percentage = (currentOffset - minOffset) / offsetRange
        let value = minValue + (valueRange * percentage)

        print(currentOffset)

        //        TODO: Commented out for now to move with overscroll effect, should this be configurable functionality?
        //        if currentOffset >= minOffset {
        //            return minValue
        //        }

        if currentOffset <= maxOffset {
            return maxValue
        }
        if value < 0 {
            return 0
        }
        return value
    }
}
