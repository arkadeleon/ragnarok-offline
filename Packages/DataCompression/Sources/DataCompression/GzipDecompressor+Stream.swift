import CZlib
import Foundation

extension GzipDecompressor {
    /// Asynchronously decompress data from given `InputStream` using `zlib`
    /// and write decompressed data to the `OutputStream`.
    ///
    /// - Parameter inputStream: Input stream from where to read the data for decompression.
    /// - Parameter outputStream: Output stream where to write the decompressed data.
    ///
    /// - Throws: `GzipError`
    public func unzip(inputStream: InputStream, outputStream: OutputStream) async throws {
        try await withCheckedThrowingContinuation { continuation in
            do {
                try unzip(inputStream: inputStream, outputStream: outputStream)
                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    /// Decompress data from given `InputStream` using `zlib` and write decompressed data to the `OutputStream`.
    ///
    /// - Parameter inputStream: Input stream from where to read the data for decompression.
    /// - Parameter outputStream: Output stream where to write the decompressed data.
    ///
    /// - Throws: `GzipError`
    public func unzip(inputStream: InputStream, outputStream: OutputStream) throws {
        if inputStream.streamStatus == .notOpen { inputStream.open() }
        if outputStream.streamStatus == .notOpen { outputStream.open() }
        defer {
            inputStream.close()
            outputStream.close()
        }

        let inputBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(GzipConstants.chunkSize))
        let outputBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(GzipConstants.chunkSize))
        defer {
            inputBuffer.deallocate()
            outputBuffer.deallocate()
        }

        var stream = z_stream()
        var status: Int32
        let initStatus = inflateInit2_(
            &stream,
            Int32(wBits),
            ZLIB_VERSION,
            Int32(GzipConstants.streamSize)
        )
        guard initStatus == Z_OK else {
            throw GzipError(code: initStatus, msg: stream.msg)
        }
        defer {
            inflateEnd(&stream)
        }

        repeat {
            let readBytes = inputStream.read(inputBuffer, maxLength: Int(GzipConstants.chunkSize))
            if readBytes < 0 {
                let message = inputStream.streamError.map { "\($0)" } ?? "Failure reading input stream"
                throw GzipError(kind: .stream, message: message)
            } else if readBytes == 0 {
                break
            } else {
                stream.avail_in = UInt32(readBytes)
                stream.next_in = inputBuffer
                repeat {
                    stream.avail_out = GzipConstants.chunkSize
                    stream.next_out = outputBuffer
                    status = inflate(&stream, Z_NO_FLUSH)
                    let have = GzipConstants.chunkSize - stream.avail_out
                    if have > 0, outputStream.write(outputBuffer, maxLength: Int(have)) < 0 {
                        let message = outputStream.streamError.map { "\($0)" } ?? "Failure writing to output stream"
                        throw GzipError(kind: .stream, message: message)
                    }
                } while stream.avail_out == 0
            }
        } while status != Z_STREAM_END
    }
}
