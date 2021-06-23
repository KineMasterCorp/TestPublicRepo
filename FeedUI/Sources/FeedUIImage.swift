import UIKit

class FeedUIImage: Hashable {    
    var height: CGFloat?
    var image: UIImage!
    var title: String!
    let url: URL!
    let identifier = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    static func == (lhs: FeedUIImage, rhs: FeedUIImage) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    init(image: UIImage, url: URL, title: String) {
        self.image = image
        self.url = url
        self.title = title
    }

}

class FeedImage: Hashable {
    var height: CGFloat?
    let url: URL!
    let identifier = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    static func == (lhs: FeedImage, rhs: FeedImage) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    init(url: URL) {
        self.url = url
    }
}
