import Foundation

enum Tag: String, Decodable {
    case deposit = "deposit"
    case withdrawal = "withdrawal"
}

extension Tag: CaseIterable {}

struct USDPrice: Decodable {
    var id: Int
    let name: String
    let usd: Decimal
    let tags: [Tag]
}

struct AllPrice: Decodable {
    let data: [Price]

    struct Price: Decodable {
        let id: Int
        let name: String
        let price: PriceRecord
        let tags: [Tag]

        struct PriceRecord: Decodable {
            let usd: Decimal
            let eur: Decimal
        }
    }
}

protocol Pricable {
    var id: Int { get }
    var name: String { get }
    var prices: [Price] { get }
    var tags: [Tag] { get }
}

struct Price { // Conforming to Equatable
    let value: Decimal
    let currency: Currency
}

enum Currency: String, CaseIterable {
    case usd
    case eur
}

// Implementing Equatable for USDPrice
extension USDPrice: Pricable {
    var prices: [Price] {
        [.init(value: usd, currency: .usd)]
    }
}

// Implementing Equatable for AllPrice.Price
extension AllPrice.Price: Pricable {
    var prices: [Price] {
        [
            .init(value: price.usd, currency: .usd),
            .init(value: price.eur, currency: .eur)
        ]
    }
}

struct AnyPricable: Pricable, Equatable {
    private let base: any Pricable

    var id: Int { base.id }
    var name: String { base.name }
    var prices: [Price] { base.prices }
    var tags: [Tag] { base.tags }

    init<P: Pricable>(_ base: P) {
        self.base = base
    }

    static func == (lhs: AnyPricable, rhs: AnyPricable) -> Bool {
        return lhs.id == rhs.id
    }
}

extension AnyPricable: CustomDebugStringConvertible {
    var debugDescription: String {
        """
            type:\(type(of: base))
            id: \(id),
            name: \(name),
            prices: \(prices),
            tags: \(tags)
        """
    }
}
