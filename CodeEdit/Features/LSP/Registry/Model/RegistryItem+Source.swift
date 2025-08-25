//
//  RegistryItem+Source.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/15/25.
//

extension RegistryItem {
    struct Source: Codable {
        let id: String
        let asset: AssetContainer?
        let build: BuildContainer?
        let versionOverrides: [VersionOverride]?

        enum AssetContainer: Codable {
            case single(Asset)
            case multiple([Asset])
            case simpleFile(String)
            case none

            init(from decoder: Decoder) throws {
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

            func encode(to encoder: Encoder) throws {
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

            func getDarwinFileName() -> String? {
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

        enum BuildContainer: Codable {
            case single(Build)
            case multiple([Build])
            case none

            init(from decoder: Decoder) throws {
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

            func encode(to encoder: Encoder) throws {
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

            func getUnixBuildCommand() -> String? {
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

        struct Build: Codable {
            let target: Target?
            let run: String
            let env: [String: String]?
            let bin: BinContainer?
        }

        struct Asset: Codable {
            let target: Target
            let file: String?
            let bin: BinContainer?

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.target = try container.decode(Target.self, forKey: .target)
                self.file = try container.decodeIfPresent(String.self, forKey: .file)
                self.bin = try container.decodeIfPresent(BinContainer.self, forKey: .bin)
            }
        }

        enum Target: Codable {
            case single(String)
            case multiple([String])

            init(from decoder: Decoder) throws {
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

            func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case .single(let value):
                    try container.encode(value)
                case .multiple(let values):
                    try container.encode(values)
                }
            }

            func isDarwinTarget() -> Bool {
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

        enum BinContainer: Codable {
            case single(String)
            case multiple([String: String])

            init(from decoder: Decoder) throws {
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

            func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case .single(let value):
                    try container.encode(value)
                case .multiple(let values):
                    try container.encode(values)
                }
            }
        }

        struct VersionOverride: Codable {
            let constraint: String
            let id: String
            let asset: AssetContainer?
        }
    }
}
