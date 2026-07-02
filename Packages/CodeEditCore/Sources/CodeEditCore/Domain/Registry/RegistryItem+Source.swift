//
//  RegistryItem+Source.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/15/25.
//

extension RegistryItem {
    public struct Source: Codable {
        public let id: String
        public let asset: AssetContainer?
        public let build: BuildContainer?
        public let versionOverrides: [VersionOverride]?

        public init(
            id: String,
            asset: AssetContainer?,
            build: BuildContainer?,
            versionOverrides: [VersionOverride]?
        ) {
            self.id = id
            self.asset = asset
            self.build = build
            self.versionOverrides = versionOverrides
        }

        public enum AssetContainer: Codable {
            case single(Asset)
            case multiple([Asset])
            case simpleFile(String)
            case none

            public init(from decoder: Decoder) throws {
                if let container = try? decoder.singleValueContainer() {
                    if let singleValue = try? container.decode(Asset.self) {
                        self = .single(singleValue)
                        return
                    } else if let multipleValues = try? container.decode([Asset].self) {
                        self = .multiple(multipleValues)
                        return
                    } else if let simpleFile = try? container.decode([String: String].self),
                              simpleFile.count == 1,
                              simpleFile.keys.contains("file"),
                              let file = simpleFile["file"] {
                        self = .simpleFile(file)
                        return
                    }
                }
                self = .none
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case .single(let value):
                    try container.encode(value)
                case .multiple(let values):
                    try container.encode(values)
                case .simpleFile(let file):
                    try container.encode(["file": file])
                case .none:
                    try container.encodeNil()
                }
            }

            public func getDarwinFileName() -> String? {
                switch self {
                case .single(let asset):
                    if asset.target.isDarwinTarget() {
                        return asset.file
                    }

                case .multiple(let assets):
                    for asset in assets where asset.target.isDarwinTarget() {
                        return asset.file
                    }

                case .simpleFile(let fileName):
                    return fileName

                case .none:
                    return nil
                }
                return nil
            }
        }

        public enum BuildContainer: Codable {
            case single(Build)
            case multiple([Build])
            case none

            public init(from decoder: Decoder) throws {
                if let container = try? decoder.singleValueContainer() {
                    if let singleValue = try? container.decode(Build.self) {
                        self = .single(singleValue)
                        return
                    } else if let multipleValues = try? container.decode([Build].self) {
                        self = .multiple(multipleValues)
                        return
                    }
                }
                self = .none
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case .single(let value):
                    try container.encode(value)
                case .multiple(let values):
                    try container.encode(values)
                case .none:
                    try container.encodeNil()
                }
            }

            public func getUnixBuildCommand() -> String? {
                switch self {
                case .single(let build):
                    return build.run
                case .multiple(let builds):
                    for build in builds {
                        guard let target = build.target else { continue }
                        if target.isDarwinTarget() {
                            return build.run
                        }
                    }
                case .none:
                    return nil
                }
                return nil
            }
        }

        public struct Build: Codable {
            public let target: Target?
            public let run: String
            public let env: [String: String]?
            public let bin: BinContainer?

            public init(
                target: Target?,
                run: String,
                env: [String: String]?,
                bin: BinContainer?
            ) {
                self.target = target
                self.run = run
                self.env = env
                self.bin = bin
            }
        }

        public struct Asset: Codable {
            public let target: Target
            public let file: String?
            public let bin: BinContainer?

            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.target = try container.decode(Target.self, forKey: .target)
                self.file = try container.decodeIfPresent(String.self, forKey: .file)
                self.bin = try container.decodeIfPresent(BinContainer.self, forKey: .bin)
            }

            public init(
                target: Target,
                file: String?,
                bin: BinContainer?
            ) {
                self.target = target
                self.file = file
                self.bin = bin
            }
        }

        public enum Target: Codable {
            case single(String)
            case multiple([String])

            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let singleValue = try? container.decode(String.self) {
                    self = .single(singleValue)
                } else if let multipleValues = try? container.decode([String].self) {
                    self = .multiple(multipleValues)
                } else {
                    throw DecodingError.typeMismatch(
                        Target.self,
                        DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "Invalid target format"
                        )
                    )
                }
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case .single(let value):
                    try container.encode(value)
                case .multiple(let values):
                    try container.encode(values)
                }
            }

            public func isDarwinTarget() -> Bool {
                switch self {
                case .single(let value):
#if arch(arm64)
                    return value == "darwin" || value == "darwin_arm64" || value == "unix"
#else
                    return value == "darwin" || value == "darwin_x64" || value == "unix"
#endif
                case .multiple(let values):
#if arch(arm64)
                    return values.contains("darwin") ||
                    values.contains("darwin_arm64") ||
                    values.contains("unix")
#else
                    return values.contains("darwin") ||
                    values.contains("darwin_x64") ||
                    values.contains("unix")
#endif
                }
            }
        }

        public enum BinContainer: Codable {
            case single(String)
            case multiple([String: String])

            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let singleValue = try? container.decode(String.self) {
                    self = .single(singleValue)
                } else if let dictValue = try? container.decode([String: String].self) {
                    self = .multiple(dictValue)
                } else {
                    throw DecodingError.typeMismatch(
                        BinContainer.self,
                        DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "Invalid bin format"
                        )
                    )
                }
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case .single(let value):
                    try container.encode(value)
                case .multiple(let values):
                    try container.encode(values)
                }
            }
        }

        public struct VersionOverride: Codable {
            public let constraint: String
            public let id: String
            public let asset: AssetContainer?

            public init(
                constraint: String,
                id: String,
                asset: AssetContainer?
            ) {
                self.constraint = constraint
                self.id = id
                self.asset = asset
            }
        }
    }
}
