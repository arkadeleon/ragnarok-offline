import CZlib
import Foundation

public struct GzipError: LocalizedError, Sendable {
    public enum Kind: Hashable, Sendable {
        case stream
        case data
        case memory
        case buffer
        case version
        case unknown(code: Int)

        init(code: Int32) {
            switch code {
            case Z_STREAM_ERROR: self = .stream
            case Z_DATA_ERROR: self = .data
            case Z_MEM_ERROR: self = .memory
            case Z_BUF_ERROR: self = .buffer
            case Z_VERSION_ERROR: self = .version
            default: self = .unknown(code: Int(code))
            }
        }
    }

    public let kind: Kind
    public let message: String

    public var errorDescription: String? {
        return message
    }

    init(kind: Kind, message: String) {
        self.kind = kind
        self.message = message
    }

    init(code: Int32, msg: UnsafePointer<CChar>?) {
        message = msg.flatMap(String.init(cString:)) ?? "Unknown gzip error"
        kind = Kind(code: code)
    }
}
