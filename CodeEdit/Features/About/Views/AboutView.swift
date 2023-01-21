//
//  AboutView.swift
//  CodeEditModules/About
//
//  Created by Andrei Vidrasco on 02.04.2022
//

import SwiftUI

enum AboutMode: String, CaseIterable {
    case about
    case acknowledgements
    case contributors
}

public struct AboutView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) private var colorScheme

    @State var aboutMode: AboutMode = .about
    @State var pressingBackButton: Bool = false
    @State private var scrollOffset: CGFloat = 0

    private var appVersion: String {
        Bundle.versionString ?? "No Version"
    }

    private var appBuild: String {
        Bundle.buildString ?? "No Build"
    }

    private var appVersionPostfix: String {
        Bundle.versionPostfix ?? ""
    }

    private static var licenseURL = URL(string: "https://github.com/CodeEditApp/CodeEdit/blob/main/LICENSE.md")!

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

    let smallTitlebarHeight: CGFloat = 28
    let mediumTitlebarHeight: CGFloat = 113
    let largeTitlebarHeight: CGFloat = 231

    let maxScrollOffset: CGFloat

    public init() {
        self.maxScrollOffset = -self.mediumTitlebarHeight + self.smallTitlebarHeight
    }

    public var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(
                        width: aboutMode == .about
                            ? 128
                            : getScrollAdjustedValue(
                                minValue: 48,
                                maxValue: 0,
                                minOffset: 0,
                                maxOffset: maxScrollOffset
                            ),
                        height: aboutMode == .about
                            ? 128
                            : getScrollAdjustedValue(
                                minValue: 48,
                                maxValue: 0,
                                minOffset: 0,
                                maxOffset: maxScrollOffset
                            )
                    )
                    .opacity(
                        aboutMode == .about
                         ? 1
                         : getScrollAdjustedValue(
                            minValue: 1,
                            maxValue: 0,
                            minOffset: 0,
                            maxOffset: maxScrollOffset
                        )
                    )
                    .padding(.top, aboutMode == .about ? 16 : 0)
                    .padding(.bottom, aboutMode == .about
                             ? 8
                             : getScrollAdjustedValue(
                                minValue: 8,
                                maxValue: 0,
                                minOffset: 0,
                                maxOffset: maxScrollOffset
                            ))
                    .animation(.default, value: aboutMode)

                VStack(spacing: 0) {
                    ZStack {
                        Text("CodeEdit")
                            .opacity(aboutMode == .about ? 1 : 0)
                        Text("Contributors")
                            .opacity(aboutMode == .contributors ? 1 : 0)
                        Text("Acknowledgements")
                            .opacity(aboutMode == .acknowledgements ? 1 : 0)
                    }
                    .foregroundColor(.primary)
                    .font(.system(
                        size: aboutMode == .about
                            ? 26
                            : getScrollAdjustedValue(
                                minValue: 22,
                                maxValue: 14,
                                minOffset: 0,
                                maxOffset: maxScrollOffset
                            ),
                        weight: .bold
                    ))
                    .animation(.default, value: aboutMode)

                    Text("Version \(appVersion)\(appVersionPostfix) (\(appBuild))")
                        .opacity(aboutMode == .about ? 1 : 0)
                        .textSelection(.enabled)
                        .foregroundColor(Color(.tertiaryLabelColor))
                        .font(.body)
                        .blendMode(colorScheme == .dark ? .plusLighter : .plusDarker)
                        .animation(.default, value: aboutMode)
                        .padding(.top, aboutMode == .about ? 4 : -16 )
                }
                .frame(minHeight: smallTitlebarHeight)
                .padding(.horizontal)
                Divider()
                    .opacity(
                        aboutMode == .about
                         ? 0
                         : getScrollAdjustedValue(
                            minValue: 0,
                            maxValue: 1,
                            minOffset: 0,
                            maxOffset: maxScrollOffset
                        )
                    )
                    .animation(.default, value: aboutMode)
            }
            .padding(.top, aboutMode == .about ? smallTitlebarHeight : getScrollAdjustedValue(
                minValue: smallTitlebarHeight,
                maxValue: 0,
                minOffset: 0,
                maxOffset: maxScrollOffset
            ))

            VStack {
                Spacer()
                Button {
                    aboutMode = .contributors
                } label: {
                    Text("Contributors")
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                }
                .controlSize(.large)

                Button {
                    aboutMode = .acknowledgements
                } label: {
                    Text("Acknowledgements")
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                }
                .controlSize(.large)

                VStack(spacing: 2) {
                    Link(destination: Self.licenseURL) {
                        Text("MIT License")
                            .underline()

                    }
                    Text(Bundle.copyrightString ?? "")
                }
                .textSelection(.disabled)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color(.tertiaryLabelColor))
                .blendMode(colorScheme == .dark ? .plusLighter : .plusDarker)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .padding(.horizontal)
            .offset(y: aboutMode != .about ? -150 : 0)
            .opacity(aboutMode == .about ? 1 : 0)
            .animation(.default, value: aboutMode)

            VStack(spacing: 0) {
                OffsettableScrollView(showsIndicator: false) { offset in
                    scrollOffset = offset.y
                } content: {
                    ZStack(alignment: .top) {
                        ContributorsView()
                            .opacity(aboutMode == .contributors ? 1 : 0)
                            .animation(.default, value: aboutMode)
                            // prevents influencing scroll position when other views are active
                            .frame(
                                height: aboutMode == .about || aboutMode == .contributors ? nil : 0,
                                alignment: .top
                            )
                        AcknowledgementsView()
                            .opacity(aboutMode == .acknowledgements ? 1 : 0)
                            .animation(.default, value: aboutMode)
                            // prevents influencing scroll position when other views are active
                            .frame(
                                height: aboutMode == .about || aboutMode == .acknowledgements ? nil : 0,
                                alignment: .top
                            )
                    }
                    .padding(.top, mediumTitlebarHeight - smallTitlebarHeight)
                    .padding(.bottom, 48)
                    .padding(.horizontal)
                }
                .allowsHitTesting(aboutMode != .about)
            }
            .clipShape(Rectangle())
            // HELP: This padding animation seems to make the titles above not animate properly
            // Compare the title animation when the padding and animation modifiers are disabled
            .padding(.top, aboutMode == .about ? largeTitlebarHeight : smallTitlebarHeight)
            .animation(.default, value: aboutMode)

            if aboutMode != .about {
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            aboutMode = .about
                        }, label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .regular))
                                .frame(width: 24, height: 24)
                                .background(ZStack {
                                    EffectView(.sidebar)
                                    Color(pressingBackButton ? .secondaryLabelColor : .controlColor)
                                })
                                .cornerRadius(5)
                                .pressAction(onPress: {
                                    pressingBackButton = true
                                }, onRelease: {
                                    pressingBackButton = false
                                })
                        })
                        .buttonStyle(.borderless)
                        .padding()
                        Spacer()
                    }
                }
            }
        }
        .ignoresSafeArea()
        .frame(width: 280, height: 400 - 28)
        .fixedSize()
        // hack required to get buttons appearing correctly in light appearance
        // if anyone knows of a better way to do this feel free to refactor
        .background(.regularMaterial.opacity(0))
        .background(EffectView(.popover, blendingMode: .behindWindow).ignoresSafeArea())
    }

    public func showWindow(width: CGFloat, height: CGFloat) {
        AboutViewWindowController(
            view: self,
            size: NSSize(width: width, height: height)
        )
        .showWindow(nil)
    }
}
