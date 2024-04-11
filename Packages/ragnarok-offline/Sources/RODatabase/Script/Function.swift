//
//  Function.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/8.
//

/// Define a function object.
///
/// `function%TAB%script%TAB%<function name>%TAB%{<code>}`
public struct Function {

    public var functionName: String

    public var code: String

    init(_ w1: String, _ w2: String, _ w3: String, _ w4: String) {
        functionName = w3
        code = w4
    }
}
