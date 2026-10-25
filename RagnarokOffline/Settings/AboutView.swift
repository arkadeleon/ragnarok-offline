//
//  AboutView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/26.
//

import SwiftUI

struct AboutView: View {
    @Environment(SettingsModel.self) private var settings

    var body: some View {
        Form {
            Section {
                LabeledContent("Version", value: appVersion)
            }

            Section {
                Link("GitHub Repository", destination: repositoryURL)

                Link("Report a Bug", destination: newIssueURL(template: "bug_report.yml", fields: [
                    "app-version": appVersion,
                    "os-version": systemVersion,
                    "device-model": deviceModel,
                    "remote-client": settings.isRemoteClientEnabled ? "On" : "Off",
                ]))

                Link("Request a Feature", destination: newIssueURL(template: "feature_request.yml", fields: [
                    "app-version": appVersion,
                ]))
            }
        }
        .formStyle(.grouped)
        .navigationTitle("About")
        .toolbarTitleDisplayMode(.inline)
    }

    private var appVersion: String {
        let shortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return "\(shortVersion) (\(version))"
    }

    private var repositoryURL: URL {
        URL(string: "https://github.com/arkadeleon/ragnarok-offline")!
    }

    private var systemVersion: String {
        #if os(macOS)
        let systemName = "macOS"
        #elseif os(visionOS)
        let systemName = "visionOS"
        #else
        let systemName = UIDevice.current.userInterfaceIdiom == .pad ? "iPadOS" : "iOS"
        #endif
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(systemName) \(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }

    private var deviceModel: String {
        #if targetEnvironment(simulator)
        let model = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? ""
        return "\(model) (Simulator)"
        #elseif os(macOS)
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [UInt8](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        return String(decoding: model.prefix(while: { $0 != 0 }), as: UTF8.self)
        #else
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafeBytes(of: systemInfo.machine) { bytes in
            String(decoding: bytes.prefix(while: { $0 != 0 }), as: UTF8.self)
        }
        #endif
    }

    private func newIssueURL(template: String, fields: [String : String]) -> URL {
        var components = URLComponents(url: repositoryURL.appending(path: "issues/new"), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "template", value: template)]
            + fields.sorted(by: { $0.key < $1.key }).map({ URLQueryItem(name: $0.key, value: $0.value) })
        return components.url!
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
    .environment(SettingsModel())
}
