//
//  PatronModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/11/12.
//

import Observation
import StoreKit

@MainActor
@Observable
final class PatronModel {
    static let subscriptionGroupID = "22564162"
    static let productIDs = [
        "online.ragnarokoffline.patron.monthly",
        "online.ragnarokoffline.patron.yearly",
    ]

    private(set) var hasActiveSubscription = false

    @ObservationIgnored private var transactionTask: Task<Void, Never>?
    @ObservationIgnored private var statusTask: Task<Void, Never>?
    @ObservationIgnored private var refreshRevision = 0

    init() {
        // Keep listening for transactions even after the settings page closes.
        transactionTask = Task { [weak self] in
            await self?.refreshEntitlements()

            for await result in Transaction.updates {
                guard case .verified(let transaction) = result,
                      Self.productIDs.contains(transaction.productID) else {
                    continue
                }

                await self?.refreshEntitlements()
                await transaction.finish()
            }
        }

        statusTask = Task { [weak self] in
            for await (groupID, _) in Product.SubscriptionInfo.Status.all {
                if groupID == Self.subscriptionGroupID {
                    await self?.refreshEntitlements()
                }
            }
        }
    }

    deinit {
        transactionTask?.cancel()
        statusTask?.cancel()
    }

    func refreshEntitlements() async {
        refreshRevision += 1
        let revision = refreshRevision
        var isActive = false

        // A subscription can remain active during a payment grace period.
        // Use StoreKit's current entitlements instead of checking expiration dates.
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               Self.productIDs.contains(transaction.productID),
               transaction.revocationDate == nil,
               !transaction.isUpgraded {
                isActive = true
            }
        }

        guard revision == refreshRevision, !Task.isCancelled else {
            return
        }

        hasActiveSubscription = isActive
    }
}
