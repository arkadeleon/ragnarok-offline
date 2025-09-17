import CZlib

public enum GzipConstants: Sendable {
    public static let maxWindowBits = MAX_WBITS
    public static let chunkSize: UInt32 = 1 << 18 // 256 KB
    public static let streamSize = MemoryLayout<z_stream>.size
    public static let magicNumber: [UInt8] = [0x1f, 0x8b]
}
