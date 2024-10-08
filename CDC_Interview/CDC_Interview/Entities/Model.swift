import Foundation

enum Tag: String, Decodable {
    case deposit = "deposit"
    case withdrawal = "withdrawal"
}

struct USDPrice: Decodable {
    let id: Int
    let name: String
    let usd: Decimal
    let tags: [Tag] 
}


struct AllPrice: Decodable {
    struct Price: Decodable {
        struct PriceRecrd: Decodable { 
            let usd: Decimal
            let eur: Decimal
        }
        
        let id: Int
        let name: String
        let price: PriceRecrd
        let tags: [Tag]
    }
    let data: Price
}
