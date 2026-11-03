//
//  LicensesView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/11/3.
//

import SwiftUI

struct LicensesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(verbatim: "RagOff is not affiliated with or endorsed by Gravity Co., Ltd. Ragnarok Online and its game content belong to their respective rights holders.")

                Text(verbatim: thirdPartyNotices)

                Text(verbatim: gplLicense)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle(Text("Licenses", tableName: "Settings"))
        .toolbarTitleDisplayMode(.inline)
    }

    private var thirdPartyNotices: String {
        let url = Bundle.main.url(forResource: "ThirdPartyNotices", withExtension: "txt")!
        return try! String(contentsOf: url, encoding: .utf8)
    }

    private var gplLicense: String {
        let url = Bundle.main.url(forResource: "GPL-3.0", withExtension: "txt")!
        return try! String(contentsOf: url, encoding: .utf8)
    }
}

#Preview {
    NavigationStack {
        LicensesView()
    }
}
