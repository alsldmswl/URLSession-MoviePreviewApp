

import Foundation

struct MovieModel: Codable {
    let resultCount: Int
    let results: [MovieResult]
    
}

struct MovieResult: Codable { // result 안에 있는 필요한 데이터 선언(trackName, previewUrl, artworkUrl100)
    let trackName: String?
    let previewUrl: String?
    let image: String?
    let shortDescription: String?
    let longDescription: String?
    let releaseDate: String?
    
    enum CodingKeys: String, CodingKey {
        case image = "artworkUrl100"
        case trackName
        case previewUrl
        case shortDescription
        case longDescription
        case releaseDate
    }
    
}
