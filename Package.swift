import PackageDescription

let package = Package(
	name: "SwiftCheck",
	targets: [
		Target(name: "SwiftCheck"),
		Target(
			name: "SwiftCheckTests",
			dependencies: ["SwiftCheck"]),
	]
)

