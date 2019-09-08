import UIKit

struct Error {
    var message: String
}

class FlickrAPI {
    
    class func prepareURL(_ params: [String: Any]) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest/"
        components.queryItems = [URLQueryItem]()
        components.queryItems!.append(URLQueryItem(name: "api_key", value: FlickrAPIConst.apiKey))
        components.queryItems!.append(URLQueryItem(name: "extras", value: "url_m"))
        components.queryItems!.append(URLQueryItem(name: "format", value: "json"))
        components.queryItems!.append(URLQueryItem(name: "nojsoncallback", value: "1"))
        
        for (key, value) in params {
            components.queryItems!.append(URLQueryItem(name: key, value: "\(value)"))
        }
        return components.url!
    }
    
    class func searchPhotos(page: Int, text: String? = nil, longitude: Double? = nil, latitude: Double? = nil, completionHandler: @escaping ([[String: AnyObject]], Int, Error?) -> Void) {
        
        func handleError(_ message: String) {
            completionHandler([[:]], 0, Error(message: message))
        }
        var params = [
            "method": "flickr.photos.search",
            "in_gallery": 1,
            "per_page": "30",
            "page": page
            ] as [String: Any]
        if let txt = text {
            params["text"] = txt
        }
        if let lon = longitude, let lat = latitude {
            params["lon"] = lon
            params["lat"] = lat
        }
        let task = URLSession.shared.dataTask(with: prepareURL(params)) { (data, response, error) in
            guard (error == nil) else {
                handleError("There was an error with your request: \(String(describing: error))")
                return
            }
            guard let data = data else {
                handleError("No data was returned by the request!")
                return
            }
            let (photos, allPages) = parseResponse(data)
            if photos.isEmpty {
                handleError("There is no photos")
                return
            }
            completionHandler(photos, allPages, nil)
        }
        task.resume()
    }
    
    class func parseResponse(_ response: Data) -> ([[String: AnyObject]], Int){
        var parsedResult: [String: AnyObject]!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: response, options: .allowFragments) as? [String: AnyObject]
        } catch {
            print("Could not parse the data as JSON: '\(response)'")
            return ([], 0)
        }
        guard let stat = parsedResult["stat"] as? String, stat == "ok" else {
            print("Stat fail '\(String(describing: parsedResult))'")
            return ([], 0)
        }
        guard let photosDict = parsedResult["photos"] as? [String: AnyObject],
            let allPages = photosDict["pages"] as? Int,
            let photosArray = photosDict["photo"] as? [[String: AnyObject]] else
        {
            print("Missing key photos or photo")
            return ([], 0)
        }
        return (photosArray, allPages)
    }
}
