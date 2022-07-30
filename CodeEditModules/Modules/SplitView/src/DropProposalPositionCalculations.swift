//
//  DropProposalPositionCalculations.swift
//  CodeEditModules/SplitView
//
//  Created by Mateusz Bąk on 2022/07/03.
//

import Foundation

/*
 Leading Rect:
 +------+--------------------------+------+
 |xxxxxx|                          |      |
 |xxxxxx|                          |      |
 |xxxxxx+--------------------------+      |
 |xxxxxx|                          |      |
 |xxxxxx|                          |      |
 |xxxxxx|                          |      |
 |xxxxxx+--------------------------+      |
 |xxxxxx|                          |      |
 |xxxxxx|                          |      |
 +------+--------------------------+------+

 Trailing Rect:
 +------+--------------------------+------+
 |      |                          |xxxxxx|
 |      |                          |xxxxxx|
 |      +--------------------------+xxxxxx|
 |      |                          |xxxxxx|
 |      |                          |xxxxxx|
 |      |                          |xxxxxx|
 |      +--------------------------+xxxxxx|
 |      |                          |xxxxxx|
 |      |                          |xxxxxx|
 +------+--------------------------+------+

 Top Rect:
 +------+--------------------------+------+
 |      |xxxxxxxxxxxxxxxxxxxxxxxxxx|      |
 |      |xxxxxxxxxxxxxxxxxxxxxxxxxx|      |
 |      +--------------------------+      |
 |      |                          |      |
 |      |                          |      |
 |      |                          |      |
 |      +--------------------------+      |
 |      |                          |      |
 |      |                          |      |
 +------+--------------------------+------+

 Bottom Rect:
 +------+--------------------------+------+
 |      |                          |      |
 |      |                          |      |
 |      +--------------------------+      |
 |      |                          |      |
 |      |                          |      |
 |      |                          |      |
 |      +--------------------------+      |
 |      |xxxxxxxxxxxxxxxxxxxxxxxxxx|      |
 |      |xxxxxxxxxxxxxxxxxxxxxxxxxx|      |
 +------+--------------------------+------+

 Center Rect:
 +------+--------------------------+------+
 |      |                          |      |
 |      |                          |      |
 |      +--------------------------+      |
 |      |xxxxxxxxxxxxxxxxxxxxxxxxxx|      |
 |      |xxxxxxxxxxxxxxxxxxxxxxxxxx|      |
 |      |xxxxxxxxxxxxxxxxxxxxxxxxxx|      |
 |      +--------------------------+      |
 |      |                          |      |
 |      |                          |      |
 +------+--------------------------+------+
 */
func calculateDropProposalPosition(
    in rect: CGRect,
    for point: CGPoint,
    margin: CGFloat
) -> SplitViewProposalDropPosition? {
    let leadingRect = CGRect(
        x: rect.minX,
        y: rect.minY,
        width: margin,
        height: rect.height
    )

    let trailingRect = CGRect(
        x: rect.maxX - margin,
        y: rect.minY,
        width: margin,
        height: rect.height
    )

    let topRect = CGRect(
        x: rect.minX + margin,
        y: rect.minY,
        width: rect.width - 2 * margin,
        height: margin
    )

    let bottomRect = CGRect(
        x: rect.minX + margin,
        y: rect.maxY - margin,
        width: rect.width - 2 * margin,
        height: margin
    )

    if leadingRect.contains(point) {
        return .leading
    }

    if trailingRect.contains(point) {
        return .trailing
    }

    if topRect.contains(point) {
        return .top
    }

    if bottomRect.contains(point) {
        return .bottom
    }

    if rect.contains(point) {
        return .center
    }

    return nil
}
