//
//  BundleDescription+Module.swift
//  RagnarokLocalization
//
//  Created by Leon Li on 2024/7/12.
//

import Foundation

extension LocalizedStringResource.BundleDescription {
    static let module: LocalizedStringResource.BundleDescription = .atURL(Bundle.module.bundleURL)
}
