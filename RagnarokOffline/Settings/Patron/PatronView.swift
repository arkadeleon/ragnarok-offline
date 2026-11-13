//
//  PatronView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/11/12.
//

import StoreKit
import SwiftUI

struct PatronView: View {
    @Environment(PatronModel.self) private var patron

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: "star.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .frame(width: 72, height: 72)
                        .background(Color.accentColor.gradient, in: RoundedRectangle(cornerRadius: 16))

                    if patron.hasActiveSubscription {
                        Text("Thank You for Being a Patron", tableName: "Settings")
                            .font(.title)
                            .bold()
                    } else {
                        Text("Patron", tableName: "Settings")
                            .font(.title)
                            .bold()
                    }

                    Text("Your support helps keep RagOff free for everyone. Patrons get early access to new features.", tableName: "Settings")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical)

                NavigationLink {
                    subscriptionView
                } label: {
                    LabeledContent {
                        if patron.hasActiveSubscription {
                            Text("Active", tableName: "Settings")
                        } else {
                            Text("Inactive", tableName: "Settings")
                        }
                    } label: {
                        Text("Subscription", tableName: "Settings")
                    }
                }

                if patron.hasActiveSubscription {
                    Link(destination: URL(string: "https://apps.apple.com/account/subscriptions")!) {
                        Text("Manage Subscription", tableName: "Settings")
                    }
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Server Mode", tableName: "Settings")
                    Text("Switch between Pre-Renewal and Renewal for your local servers.", tableName: "Settings")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Early Access", tableName: "Settings")
            } footer: {
                Text("During early access, an active subscription is required to switch modes. Your current mode is kept if your subscription ends.", tableName: "Settings")
            }
        }
        .formStyle(.grouped)
        .navigationTitle(Text("Patron", tableName: "Settings"))
        .toolbarTitleDisplayMode(.inline)
    }

    private var subscriptionView: some View {
        SubscriptionStoreView(productIDs: PatronModel.productIDs)
            .storeButton(.hidden, for: .cancellation)
            .storeButton(.visible, for: .restorePurchases)
            .onInAppPurchaseCompletion { _, _ in
                await patron.refreshEntitlements()
            }
            .navigationTitle(Text("Subscription", tableName: "Settings"))
            .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PatronView()
    }
    .environment(PatronModel())
}
