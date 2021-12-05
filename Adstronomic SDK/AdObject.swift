import Foundation

public class AdObject : Codable {
    internal init(appId: String? = nil, storeURL: String? = nil, id: String? = nil, fileURL: String? = nil) {
        self.appId = appId
        self.storeURL = storeURL
        self.id = id
        self.fileURL = fileURL
    }
    
    public var appId: String?
    public var storeURL: String?
    public var id: String?
    public var fileURL: String?
}
