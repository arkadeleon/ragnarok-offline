import CZlib
import Foundation

extension GzipDecompressor {
    /// Asynchronously decompress bytes (`[UInt8]`) using `zlib`.
    ///
    /// - Parameter bytes: Bytes to decompress.
    ///
    /// - Returns: Gzip-decompressed bytes (`[UInt8]`) instance.
    /// - Throws: `GzipError`
    public func unzip(bytes: [UInt8]) async throws -> [UInt8] {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let data = try unzip(bytes: bytes)
                continuation.resume(returning: data)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    /// Decompress bytes (`[UInt8]`) using `zlib`.
    ///
    /// - Parameter bytes: Bytes to decompress.
    ///
    /// - Returns: Gzip-decompressed bytes (`[UInt8]`) instance.
    /// - Throws: `GzipError`
    public func unzip(bytes: [UInt8]) throws -> [UInt8] {
        let zippedData = Data(bytes)
        let input = InputStream(data: zippedData)
        let output = OutputStream(toMemory: ())
        try unzip(inputStream: input, outputStream: output)
        guard let outputData = output.property(forKey: .dataWrittenToMemoryStreamKey) as? Data else {
            throw GzipError(kind: .stream, message: "Cannot read data from output stream")
        }

        return [UInt8](outputData)
    }
}
