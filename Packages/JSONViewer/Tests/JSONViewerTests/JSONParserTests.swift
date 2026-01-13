//
//  JSONParserTests.swift
//  JSONViewerTests
//
//  Created by Leon Li on 2026/1/12.
//

import Foundation
import Testing
@testable import JSONViewer

@Suite("JSON Parser Tests")
struct JSONParserTests {

    @Test("Parse simple object")
    func testParseObject() throws {
        let json = #"{"key": "value"}"#
        let data = try #require(json.data(using: .utf8))

        let node = try JSONParser.parse(data: data)

        #expect(node.key == nil) // Root has no key
        #expect(node.valueType == .object)
        #expect(node.children?.count == 1)

        let child = try #require(node.children?.first)
        #expect(child.key == "key")
        #expect(child.valueType == .string)
        if case .string(_, _, let value) = child {
            #expect(value == "value")
        } else {
            Issue.record("Expected string node")
        }
    }

    @Test("Parse array")
    func testParseArray() throws {
        let json = #"[1, 2, 3]"#
        let data = try #require(json.data(using: .utf8))

        let node = try JSONParser.parse(data: data)

        #expect(node.valueType == .array)
        #expect(node.children?.count == 3)

        let children = try #require(node.children)
        for (index, child) in children.enumerated() {
            #expect(child.key == "[\(index)]")
            #expect(child.valueType == .number)
        }
    }

    @Test("Parse nested structure")
    func testParseNestedStructure() throws {
        let json = #"{"obj": {"arr": [1, 2]}}"#
        let data = try #require(json.data(using: .utf8))

        let node = try JSONParser.parse(data: data)

        #expect(node.valueType == .object)
        #expect(node.children?.count == 1)

        let objChild = try #require(node.children?.first)
        #expect(objChild.key == "obj")
        #expect(objChild.valueType == .object)

        let arrChild = try #require(objChild.children?.first)
        #expect(arrChild.key == "arr")
        #expect(arrChild.valueType == .array)
        #expect(arrChild.children?.count == 2)
    }

    @Test("Parse numbers")
    func testParseNumbers() throws {
        let json = #"{"integer": 42, "float": 3.14}"#
        let data = try #require(json.data(using: .utf8))

        let node = try JSONParser.parse(data: data)
        let children = try #require(node.children)

        for child in children {
            #expect(child.valueType == .number)
            if case .number(_, let key, let value) = child {
                if key == "integer" {
                    #expect(value == 42.0)
                } else if key == "float" {
                    #expect(value == 3.14)
                }
            }
        }
    }

    @Test("Parse booleans")
    func testParseBooleans() throws {
        let json = #"{"isTrue": true, "isFalse": false}"#
        let data = try #require(json.data(using: .utf8))

        let node = try JSONParser.parse(data: data)
        let children = try #require(node.children)

        #expect(children.count == 2)
        for child in children {
            #expect(child.valueType == .boolean)
            if case .boolean(_, let key, let value) = child {
                if key == "isTrue" {
                    #expect(value == true)
                } else if key == "isFalse" {
                    #expect(value == false)
                }
            }
        }
    }

    @Test("Parse null")
    func testParseNull() throws {
        let json = #"{"nullValue": null}"#
        let data = try #require(json.data(using: .utf8))

        let node = try JSONParser.parse(data: data)
        let child = try #require(node.children?.first)

        #expect(child.key == "nullValue")
        #expect(child.valueType == .null)
    }

    @Test("Parse invalid JSON throws error")
    func testInvalidJSON() throws {
        let json = #"{invalid json}"#
        let data = try #require(json.data(using: .utf8))

        #expect(throws: JSONParsingError.self) {
            try JSONParser.parse(data: data)
        }
    }

    @Test("Parse empty structures")
    func testEmptyStructures() throws {
        let json = #"{"emptyObject": {}, "emptyArray": []}"#
        let data = try #require(json.data(using: .utf8))

        let node = try JSONParser.parse(data: data)
        let children = try #require(node.children)

        for child in children {
            if child.key == "emptyObject" {
                #expect(child.valueType == .object)
                #expect(child.children?.count == 0)
            } else if child.key == "emptyArray" {
                #expect(child.valueType == .array)
                #expect(child.children?.count == 0)
            }
        }
    }

    @Test("Parse unicode strings")
    func testUnicodeStrings() throws {
        let json = #"{"japanese": "日本語", "korean": "한국어", "emoji": "🎮"}"#
        let data = try #require(json.data(using: .utf8))

        let node = try JSONParser.parse(data: data)
        let children = try #require(node.children)

        #expect(children.count == 3)
        for child in children {
            #expect(child.valueType == .string)
            if case .string(_, let key, let value) = child {
                if key == "japanese" {
                    #expect(value == "日本語")
                } else if key == "korean" {
                    #expect(value == "한국어")
                } else if key == "emoji" {
                    #expect(value == "🎮")
                }
            }
        }
    }

    @Test("Parse large numbers")
    func testLargeNumbers() throws {
        let json = #"{"large": 9223372036854775807, "negative": -9223372036854775808, "double": 1.7976931348623157e+308}"#
        let data = try #require(json.data(using: .utf8))

        let node = try JSONParser.parse(data: data)
        let children = try #require(node.children)

        for child in children {
            #expect(child.valueType == .number)
        }
    }

    @Test("Display value formatting")
    func testDisplayValueFormatting() throws {
        let json = #"{"integer": 42, "float": 3.14, "string": "test", "bool": true, "null": null}"#
        let data = try #require(json.data(using: .utf8))

        let node = try JSONParser.parse(data: data)
        let children = try #require(node.children)

        for child in children {
            let displayValue = child.displayValue
            #expect(displayValue != nil)

            if case .number(_, let key, _) = child {
                if key == "integer" {
                    // Should display without decimal point
                    #expect(displayValue == "42")
                } else if key == "float" {
                    // Should display with decimal
                    #expect(displayValue?.contains(".") == true)
                }
            } else if case .string = child {
                // String should be quoted
                #expect(displayValue?.hasPrefix("\"") == true)
                #expect(displayValue?.hasSuffix("\"") == true)
            } else if case .boolean(_, let key, _) = child {
                if key == "bool" {
                    #expect(displayValue == "true")
                }
            } else if case .null = child {
                #expect(displayValue == "null")
            }
        }
    }

    @Test("Large array chunking")
    func testLargeArrayChunking() throws {
        // Create an array with 250 items (should be chunked into 3 chunks: 100, 100, 50)
        var items: [Int] = []
        for i in 0..<250 {
            items.append(i)
        }

        let jsonData = try JSONEncoder().encode(items)
        let node = try JSONParser.parse(data: jsonData)

        #expect(node.valueType == .array)
        let children = try #require(node.children)

        // Should have 3 chunks
        #expect(children.count == 3)

        // Array display value should show original count (250), not chunk count (3)
        #expect(node.displayValue == "[250 items]")

        // First chunk: [0..99]
        let chunk1 = children[0]
        #expect(chunk1.valueType == .chunk)
        #expect(chunk1.key == "[0..99]")
        #expect(chunk1.children?.count == 100)

        // Second chunk: [100..199]
        let chunk2 = children[1]
        #expect(chunk2.valueType == .chunk)
        #expect(chunk2.key == "[100..199]")
        #expect(chunk2.children?.count == 100)

        // Third chunk: [200..249]
        let chunk3 = children[2]
        #expect(chunk3.valueType == .chunk)
        #expect(chunk3.key == "[200..249]")
        #expect(chunk3.children?.count == 50)
    }

    @Test("Large object chunking")
    func testLargeObjectChunking() throws {
        // Create an object with 250 items
        var dict: [String: Int] = [:]
        for i in 0..<250 {
            dict["key\(i)"] = i
        }

        let jsonData = try JSONEncoder().encode(dict)
        let node = try JSONParser.parse(data: jsonData)

        #expect(node.valueType == .object)
        let children = try #require(node.children)

        // Should have 3 chunks
        #expect(children.count == 3)

        // Object display value should show original count (250), not chunk count (3)
        #expect(node.displayValue == "{250 items}")

        // All chunks should be of type .chunk
        for chunk in children {
            #expect(chunk.valueType == .chunk)
            #expect(chunk.key?.hasPrefix("Items ") == true)
        }

        // Total items across all chunks should be 250
        let totalItems = children.compactMap { $0.children?.count }.reduce(0, +)
        #expect(totalItems == 250)
    }

    @Test("Small array not chunked")
    func testSmallArrayNotChunked() throws {
        // Create an array with 50 items (should NOT be chunked)
        var items: [Int] = []
        for i in 0..<50 {
            items.append(i)
        }

        let jsonData = try JSONEncoder().encode(items)
        let node = try JSONParser.parse(data: jsonData)

        #expect(node.valueType == .array)
        let children = try #require(node.children)

        // Should have 50 direct children, not chunked
        #expect(children.count == 50)

        // First child should be a number, not a chunk
        #expect(children[0].valueType == .number)
    }

    @Test("Array at threshold not chunked")
    func testArrayAtThresholdNotChunked() throws {
        // Create an array with exactly 100 items (at threshold, should NOT be chunked)
        var items: [Int] = []
        for i in 0..<100 {
            items.append(i)
        }

        let jsonData = try JSONEncoder().encode(items)
        let node = try JSONParser.parse(data: jsonData)

        #expect(node.valueType == .array)
        let children = try #require(node.children)

        // Should have 100 direct children, not chunked
        #expect(children.count == 100)

        // First child should be a number, not a chunk
        #expect(children[0].valueType == .number)
    }

    @Test("Array just over threshold is chunked")
    func testArrayJustOverThresholdIsChunked() throws {
        // Create an array with 101 items (just over threshold, should be chunked)
        var items: [Int] = []
        for i in 0..<101 {
            items.append(i)
        }

        let jsonData = try JSONEncoder().encode(items)
        let node = try JSONParser.parse(data: jsonData)

        #expect(node.valueType == .array)
        let children = try #require(node.children)

        // Should have 2 chunks
        #expect(children.count == 2)

        // First child should be a chunk
        #expect(children[0].valueType == .chunk)

        // First chunk should have 100 items
        #expect(children[0].children?.count == 100)

        // Second chunk should have 1 item
        #expect(children[1].children?.count == 1)
    }
}
