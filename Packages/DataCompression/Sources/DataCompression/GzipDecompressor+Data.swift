import CZlib
import Foundation

extension GzipDecompressor {
    /// Asynchronously decompress `data` using `zlib`.
    ///
    /// - Parameter data: Data to decompress.
    ///
    /// - Returns: Gzip-decompressed `Data` instance.
    /// - Throws: `GzipError`
    public func unzip(data: Data) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let data = try unzip(data: data)
                continuation.resume(returning: data)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    /// Decompress `data` using `zlib`.
    ///
    /// - Parameter data: Data to decompress.
    ///
    /// - Returns: Gzip-decompressed `Data` instance.
    /// - Throws: `GzipError`
    public func unzip(data: Data) throws -> Data {
        let input = InputStream(data: data)
        let output = OutputStream(toMemory: ())
        try unzip(inputStream: input, outputStream: output)
        guard let outputData = output.property(forKey: .dataWrittenToMemoryStreamKey) as? Data else {
            throw GzipError(kind: .stream, message: "Cannot read data from output stream")
        }

        return outputData
    }
}
