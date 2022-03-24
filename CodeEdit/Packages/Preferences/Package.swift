// swift-tools-version:5.4
import PackageDescription

let package = Package(
	name: "Preferences",
	platforms: [
		.macOS(.v10_10)
	],
	products: [
		.library(
			name: "Preferences",
			targets: [
				"Preferences"
			]
		)
	],
	targets: [
		.target(
			name: "Preferences"
		)
	]
)
