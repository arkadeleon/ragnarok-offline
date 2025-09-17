public struct GzipDecompressor: Sendable {
    public let wBits: Int32

    /// Create a new `GzipDecompressor` instance.
    ///
    /// The `wBits` parameter allows for managing the size of the history buffer. The possible values are:
    ///
    ///     Value       Window size logarithm    Input
    ///     +9 to +15   Base 2                   Includes zlib header and trailer
    ///     -9 to -15   Absolute value of wbits  No header and trailer
    ///     +25 to +31  Low 4 bits of the value  Includes gzip header and trailing checksum
    ///
    /// - Parameter wBits: Manage the size of the history buffer.
    public init(wBits: Int32 = GzipConstants.maxWindowBits + 32) {
        self.wBits = wBits
    }
}
