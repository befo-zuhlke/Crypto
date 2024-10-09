import Foundation

enum Tag: String, Decodable {
    case deposit = "deposit"
    case withdrawal = "withdrawal"
}

struct USDPrice: Decodable {
    var id: Int
    let name: String
    let usd: Decimal
    let tags: [Tag] 
}

extension USDPrice: Equatable {
    static func == (lhs: USDPrice, rhs: USDPrice) -> Bool {
        lhs.id == rhs.id
    }
}

struct AllPrice: Decodable {
    let data: Price

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

extension USDPrice: Pricable {
    var prices: [Price] {
        [.init(value: usd, currency: "usd")]
    }
}

extension AllPrice.Price: Pricable {
    var prices: [Price] {
        [
            .init(value: price.usd, currency: "usd"),
            .init(value: price.eur, currency: "eur")
        ]
    }
}

protocol Pricable {
    var id: Int { get }
    var name: String { get }
    var prices: [Price] { get }
    var tags: [Tag] { get }
}

struct Price {
    let value: Decimal
    let currency: String
}
