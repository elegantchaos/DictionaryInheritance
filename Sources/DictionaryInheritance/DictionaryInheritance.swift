// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/04/2022.
//  All code (c) 2022 - present day, Sam Deane.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

public struct DictionaryIndex {
    public typealias Record = [String:Any]
    public typealias Index = [String: Record]

    let records: Index
    
    init(_ records: Index) {
        self.records = records
    }
    
    func resolve() {
        
    }
    
    func record(withID id: String) -> Record? {
        records[id]
    }
}
