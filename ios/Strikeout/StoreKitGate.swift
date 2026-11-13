import StoreKit
import UIKit

/// Yearly auto-renewing subscription for the App Store app.
/// The field setup stays in the page under `strikeout.v1`. This type never reads or writes that key.
final class StoreKitGate {
    static let productID = "com.randyscustomapps.strikeout.yearly"
    /// On-device note that a subscription was verified, and until when. Not the field setup.
    private static let cacheKey = "strikeout.ios.entitlement"

    struct Snapshot {
        var phase: String
        var eligible: Bool
        var price: String
        var periodPhrase: String
        var trial: String
        var offline: Bool
        var message: String

        var json: [String: Any] {
            [
                "phase": phase,
                "eligible": eligible,
                "price": price,
                "periodPhrase": periodPhrase,
                "trial": trial,
                "offline": offline,
                "message": message
            ]
        }
    }

    private struct Cache: Codable {
        var productID: String
        var expiration: Date
    }

    private var product: Product?
    private(set) var snapshot: Snapshot
    var onChange: ((Snapshot) -> Void)?
    private var listening = false

    init() {
        let cached = Self.cachedEntitlementIsCurrent()
        snapshot = Snapshot(
            phase: cached ? "entitled" : "checking",
            eligible: true,
            price: "$24.99 CAD",
            periodPhrase: "a year",
            trial: "3 days",
            offline: cached,
            message: cached ? "" : "Checking…"
        )
    }

    /// A verified subscription that has not expired. Read before the page loads so a cab with no signal does not flash the paywall.
    static func cachedEntitlementIsCurrent() -> Bool {
        guard let cache = loadCache() else { return false }
        return cache.productID == productID && cache.expiration > Date()
    }

    func start() {
        guard !listening else { return }
        listening = true
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = result {
                    await transaction.finish()
                }
                await self.refresh()
            }
        }
        Task { await self.refresh() }
    }

    func refresh() async {
        if let expiration = await currentExpiration() {
            saveCache(expiration: expiration)
            snapshot.phase = "entitled"
            snapshot.offline = false
            snapshot.message = ""
            emit()
            return
        }
        do {
            let products = try await Product.products(for: [Self.productID])
            guard let product = products.first else {
                showPaywall(offline: false, message: "The subscription is not available in the store yet.")
                return
            }
            self.product = product
            clearCache()
            let offer = await intro(for: product)
            snapshot.phase = "paywall"
            snapshot.eligible = offer.eligible
            snapshot.price = product.displayPrice
            snapshot.periodPhrase = offer.periodPhrase
            snapshot.trial = offer.trial
            snapshot.offline = false
            snapshot.message = ""
            emit()
        } catch {
            if Self.cachedEntitlementIsCurrent() {
                snapshot.phase = "entitled"
                snapshot.offline = true
                snapshot.message = ""
                emit()
                return
            }
            showPaywall(offline: true, message: "Need a connection to start the free trial.")
        }
    }

    func purchase() async {
        snapshot.phase = "paywall"
        snapshot.message = "Opening the App Store…"
        emit()
        do {
            let product = try await loadProduct()
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    await refresh()
                case .unverified:
                    showPaywall(offline: false, message: "The App Store could not verify that purchase.")
                }
            case .userCancelled:
                snapshot.phase = "paywall"
                snapshot.message = ""
                emit()
            case .pending:
                showPaywall(offline: false, message: "Waiting for approval. The calculator opens when it goes through.")
            @unknown default:
                showPaywall(offline: false, message: "The App Store did not finish that purchase.")
            }
        } catch is CancellationError {
            snapshot.phase = "paywall"
            snapshot.message = ""
            emit()
        } catch StoreError.missingProduct {
            showPaywall(offline: false, message: "The subscription is not available in the store yet.")
        } catch {
            if Self.cachedEntitlementIsCurrent() {
                await refresh()
                return
            }
            showPaywall(offline: true, message: "Need a connection to subscribe.")
        }
    }

    func restore() async {
        snapshot.phase = "paywall"
        snapshot.message = "Checking the App Store…"
        emit()
        do {
            try await AppStore.sync()
            if await currentExpiration() != nil {
                await refresh()
                return
            }
            clearCache()
            showPaywall(offline: false, message: "No active subscription on this Apple ID.")
        } catch {
            if Self.cachedEntitlementIsCurrent() {
                await refresh()
                return
            }
            showPaywall(offline: true, message: "Need a connection to restore purchases.")
        }
    }

    func manage(in scene: UIWindowScene) async throws {
        try await AppStore.showManageSubscriptions(in: scene)
    }

    private func loadProduct() async throws -> Product {
        if let product { return product }
        let products = try await Product.products(for: [Self.productID])
        guard let product = products.first else {
            throw StoreError.missingProduct
        }
        self.product = product
        return product
    }

    private func showPaywall(offline: Bool, message: String) {
        let price = product?.displayPrice ?? snapshot.price
        snapshot.phase = "paywall"
        snapshot.price = price
        snapshot.offline = offline
        snapshot.message = message
        emit()
    }

    private struct Intro {
        var eligible: Bool
        var trial: String
        var periodPhrase: String
    }

    private func intro(for product: Product) async -> Intro {
        guard let sub = product.subscription else {
            return Intro(eligible: true, trial: "3 days", periodPhrase: "a year")
        }
        let phrase = Self.periodPhrase(sub.subscriptionPeriod)
        guard let offer = sub.introductoryOffer, offer.paymentMode == .freeTrial else {
            return Intro(eligible: false, trial: "", periodPhrase: phrase)
        }
        let eligible = await sub.isEligibleForIntroOffer
        return Intro(eligible: eligible, trial: Self.periodText(offer.period), periodPhrase: phrase)
    }

    /// Expiration of a verified, current transaction for this product. Nil when StoreKit has none.
    private func currentExpiration() async -> Date? {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            guard transaction.productID == Self.productID else { continue }
            guard transaction.revocationDate == nil else { continue }
            guard let expiration = transaction.expirationDate, expiration > Date() else { continue }
            return expiration
        }
        return nil
    }

    private static func periodText(_ period: Product.SubscriptionPeriod) -> String {
        let n = period.value
        let unit: String
        switch period.unit {
        case .day: unit = n == 1 ? "day" : "days"
        case .week: unit = n == 1 ? "week" : "weeks"
        case .month: unit = n == 1 ? "month" : "months"
        case .year: unit = n == 1 ? "year" : "years"
        @unknown default: unit = n == 1 ? "period" : "periods"
        }
        if n == 1 { return unit }
        return "\(n) \(unit)"
    }

    private static func periodPhrase(_ period: Product.SubscriptionPeriod) -> String {
        if period.value == 1 {
            switch period.unit {
            case .day: return "a day"
            case .week: return "a week"
            case .month: return "a month"
            case .year: return "a year"
            @unknown default: return "each period"
            }
        }
        return "every \(periodText(period))"
    }

    private func emit() {
        let snap = snapshot
        let callback = onChange
        if Thread.isMainThread {
            callback?(snap)
        } else {
            DispatchQueue.main.async { callback?(snap) }
        }
    }

    private static func loadCache() -> Cache? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else { return nil }
        return try? JSONDecoder().decode(Cache.self, from: data)
    }

    private func saveCache(expiration: Date) {
        let cache = Cache(productID: Self.productID, expiration: expiration)
        guard let data = try? JSONEncoder().encode(cache) else { return }
        UserDefaults.standard.set(data, forKey: Self.cacheKey)
    }

    private func clearCache() {
        UserDefaults.standard.removeObject(forKey: Self.cacheKey)
    }

    private enum StoreError: Error {
        case missingProduct
    }
}
