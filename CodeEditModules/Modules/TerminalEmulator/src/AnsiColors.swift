//
//  File.swift
//  
//
//  Created by Lukas Pistrol on 23.03.22.
//

import SwiftUI

public struct AnsiColors {
	public static let `default`: AnsiColors = .init()
	public static let storageKey: String = "ansiColors"

	public init() {
		self.init(
			black: CGColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000),
			red: CGColor(red: 0.600, green: 0.000, blue: 0.000, alpha: 1.000),
			green: CGColor(red: 0.000, green: 0.651, blue: 0.004, alpha: 1.000),
			yellow: CGColor(red: 0.600, green: 0.600, blue: 0.000, alpha: 1.000),
			blue: CGColor(red: 0.000, green: 0.031, blue: 0.702, alpha: 1.000),
			magenta: CGColor(red: 0.702, green: 0.020, blue: 0.702, alpha: 1.000),
			cyan: CGColor(red: 0.000, green: 0.647, blue: 0.702, alpha: 1.000),
			white: CGColor(red: 0.749, green: 0.749, blue: 0.749, alpha: 1.000),
			brightBlack: CGColor(red: 0.400, green: 0.400, blue: 0.400, alpha: 1.000),
			brightRed: CGColor(red: 0.902, green: 0.000, blue: 0.004, alpha: 1.000),
			brightGreen: CGColor(red: 0.004, green: 0.851, blue: 0.000, alpha: 1.000),
			brightYellow: CGColor(red: 0.902, green: 0.898, blue: 0.012, alpha: 1.000),
			brightBlue: CGColor(red: 0.000, green: 0.063, blue: 1.000, alpha: 1.000),
			brightMagenta: CGColor(red: 0.902, green: 0.035, blue: 0.902, alpha: 1.000),
			brightCyan: CGColor(red: 0.008, green: 0.902, blue: 0.898, alpha: 1.000),
			brightWhite: CGColor(red: 0.902, green: 0.902, blue: 0.902, alpha: 1.000))
	}

	public init(
		black: CGColor,
		red: CGColor,
		green: CGColor,
		yellow: CGColor,
		blue: CGColor,
		magenta: CGColor,
		cyan: CGColor,
		white: CGColor,
		brightBlack: CGColor,
		brightRed: CGColor,
		brightGreen: CGColor,
		brightYellow: CGColor,
		brightBlue: CGColor,
		brightMagenta: CGColor,
		brightCyan: CGColor,
		brightWhite: CGColor
	) {
		self.blackComps = black.components ?? [1, 1, 1, 0]
		self.redComps = red.components ?? [1, 1, 1, 0]
		self.greenComps = green.components ?? [1, 1, 1, 0]
		self.yellowComps = yellow.components ?? [1, 1, 1, 0]
		self.blueComps = blue.components ?? [1, 1, 1, 0]
		self.magentaComps = magenta.components ?? [1, 1, 1, 0]
		self.cyanComps = cyan.components ?? [1, 1, 1, 0]
		self.whiteComps = white.components ?? [1, 1, 1, 0]
		self.brightBlackComps = brightBlack.components ?? [1, 1, 1, 0]
		self.brightRedComps = brightRed.components ?? [1, 1, 1, 0]
		self.brightGreenComps = brightGreen.components ?? [1, 1, 1, 0]
		self.brightYellowComps = brightYellow.components ?? [1, 1, 1, 0]
		self.brightBlueComps = brightBlue.components ?? [1, 1, 1, 0]
		self.brightMagentaComps = brightMagenta.components ?? [1, 1, 1, 0]
		self.brightCyanComps = brightCyan.components ?? [1, 1, 1, 0]
		self.brightWhiteComps = brightWhite.components ?? [1, 1, 1, 0]
	}

	internal var blackComps: [CGFloat]
	internal var redComps: [CGFloat]
	internal var greenComps: [CGFloat]
	internal var yellowComps: [CGFloat]
	internal var blueComps: [CGFloat]
	internal var magentaComps: [CGFloat]
	internal var cyanComps: [CGFloat]
	internal var whiteComps: [CGFloat]
	internal var brightBlackComps: [CGFloat]
	internal var brightRedComps: [CGFloat]
	internal var brightGreenComps: [CGFloat]
	internal var brightYellowComps: [CGFloat]
	internal var brightBlueComps: [CGFloat]
	internal var brightMagentaComps: [CGFloat]
	internal var brightCyanComps: [CGFloat]
	internal var brightWhiteComps: [CGFloat]

	public var allColors: [CGColor] {
		[black, red, green, yellow, blue, magenta, cyan, white,
		 brightBlack, brightRed, brightGreen, brightYellow, brightBlue, brightMagenta, brightCyan, brightWhite]
	}

	public var black: CGColor {
		get { cgColorFrom(components: self.blackComps) }
		set { self.blackComps = newValue.components ?? [1, 1, 1, 0] }
	}

	public var red: CGColor {
		get { cgColorFrom(components: self.redComps) }
		set { self.redComps = newValue.components ?? [1, 1, 1, 0]}
	}

	public var green: CGColor {
		get { cgColorFrom(components: self.greenComps) }
		set { self.greenComps = newValue.components ?? [1, 1, 1, 0] }
	}

	public var yellow: CGColor {
		get { cgColorFrom(components: self.yellowComps) }
		set { self.yellowComps = newValue.components ?? [1, 1, 1, 0] }
	}

	public var blue: CGColor {
		get { cgColorFrom(components: self.blueComps) }
		set { self.blueComps = newValue.components ?? [1, 1, 1, 0] }
	}

	public var magenta: CGColor {
		get { cgColorFrom(components: self.magentaComps) }
		set { self.magentaComps = newValue.components ?? [1, 1, 1, 0] }
	}

	public var cyan: CGColor {
		get { cgColorFrom(components: self.cyanComps) }
		set { self.cyanComps = newValue.components ?? [1, 1, 1, 0] }
	}

	public var white: CGColor {
		get { cgColorFrom(components: self.whiteComps) }
		set { self.whiteComps = newValue.components ?? [1, 1, 1, 0] }
	}

	public var brightBlack: CGColor {
		get { cgColorFrom(components: self.brightBlackComps) }
		set { self.brightBlackComps = newValue.components ?? [1, 1, 1, 0] }
	}

	public var brightRed: CGColor {
		get { cgColorFrom(components: self.brightRedComps) }
		set { self.brightRedComps = newValue.components ?? [1, 1, 1, 0] }
	}

	public var brightGreen: CGColor {
		get { cgColorFrom(components: self.brightGreenComps) }
		set { self.brightGreenComps = newValue.components ?? [1, 1, 1, 0] }
	}

	public var brightYellow: CGColor {
		get { cgColorFrom(components: self.brightYellowComps) }
		set { self.brightYellowComps = newValue.components ?? [1, 1, 1, 0] }
	}

	public var brightBlue: CGColor {
		get { cgColorFrom(components: self.brightBlueComps) }
		set { self.brightBlueComps = newValue.components ?? [1, 1, 1, 0] }
	}

	public var brightMagenta: CGColor {
		get { cgColorFrom(components: self.brightMagentaComps) }
		set { self.brightMagentaComps = newValue.components ?? [1, 1, 1, 0] }
	}

	public var brightCyan: CGColor {
		get { cgColorFrom(components: self.brightCyanComps) }
		set { self.brightCyanComps = newValue.components ?? [1, 1, 1, 0] }
	}

	public var brightWhite: CGColor {
		get { cgColorFrom(components: self.brightWhiteComps) }
		set { self.brightWhiteComps = newValue.components ?? [1, 1, 1, 0] }
	}

	private func cgColorFrom(components: [CGFloat]?) -> CGColor {
		guard let components = components else { return .black }
		return .init(red: components[0], green: components[1], blue: components[2], alpha: components[3])
	}
}

extension AnsiColors: Codable, RawRepresentable {
	public var rawValue: String {
		guard let data = try? JSONEncoder().encode(self),
			  let result = String(data: data, encoding: .utf8) else {
			return ""
		}
		return result
	}

	public typealias RawValue = String

	public init?(rawValue: RawValue) {
		guard let data = rawValue.data(using: .utf8),
			  let result = try? JSONDecoder().decode(AnsiColors.self, from: data) else {
			self = .init()
			return
		}
		self = result
	}
}
