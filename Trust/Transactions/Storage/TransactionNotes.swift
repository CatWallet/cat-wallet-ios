// Copyright CAT Wallet. All rights reserved.

import Foundation
import RealmSwift
import TrustCore

// user annotated notes, they cannot be stored with Transaction object, as it is refreshed all the way from the network, so notes could be overwritten
final class TransactionNotes: Object, Decodable {
    @objc dynamic var uniqueID: String = ""
    @objc dynamic var notes = ""   // user can optionally add note to say what this transaction is for
    
    convenience init(
        uniqueID: String,
        notes: String = ""
        ) {
        
        self.init()
        self.uniqueID = uniqueID
        self.notes = notes
    }
    
    private enum TransactionNotesCodingKeys: String, CodingKey {
        case uniqueID
        case notes
    }
    
    convenience required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TransactionNotesCodingKeys.self)
        let uniqueID = try container.decode(String.self, forKey: .uniqueID)
        let notes = try container.decodeIfPresent(String.self, forKey: .notes)
        
        self.init(uniqueID: uniqueID,
                  notes: notes ?? "")
    }
    
    override static func primaryKey() -> String? {
        return "uniqueID"
    }
}
