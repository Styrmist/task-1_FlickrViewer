import UIKit
import CoreLocation

class LocationCollectionViewController: UICollectionViewController, CLLocationManagerDelegate {
    
    private let reuseIdentifier = "Cell"
    private let ImageViewTag = 1
    let locationManager = CLLocationManager()
    var photos = [[String: AnyObject]]()
    var curPage = 1
    var allPages = 0
    var longitude:Double  = 0
    var latitude:Double = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        collectionView?.register(LocationCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView?.prefetchDataSource = self
        
        let minimumInterItemSpacing: CGFloat = 3
        let minimumLineSpacing: CGFloat = 3
        let numberOfColumns: CGFloat = 3
    
        let width = ((collectionView?.frame.width)! - minimumInterItemSpacing - minimumLineSpacing) / numberOfColumns
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = minimumInterItemSpacing
        layout.minimumLineSpacing = minimumLineSpacing
        layout.itemSize = CGSize(width: width, height: width)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LocationCollectionViewCell
        let photoDict = photos[(indexPath as NSIndexPath).row]
        if let imageUrlString = photoDict["url_m"] as? String {
            cell.imageView.loadFromURL(imageUrlString)
        }
        return cell
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        latitude = Double(round(1000 * location.latitude) / 1000)
        longitude = Double(round(1000 * location.longitude) / 1000)
        FlickrAPI.searchPhotos(page: curPage, longitude: longitude, latitude: latitude) { (photosArray, allPages, error) in
            self.photos = photosArray
            self.curPage += 1
            self.allPages = allPages
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LocationMore"{
            if let cellIndex = self.collectionView?.indexPathsForSelectedItems {
                let detailVC = segue.destination as! DetailViewController
                detailVC.imageLink = (photos[cellIndex[0].row]["url_m"] as! String)
            }
        }
    }
}
extension LocationCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if indexPaths.last?[1] == photos.count - 1  {
            if allPages != 0 && curPage < allPages {
                FlickrAPI.searchPhotos(page: curPage, longitude: longitude, latitude: latitude) { (photosArray, allPages, error) in
                    self.photos += photosArray
                    self.curPage += 1
                    self.allPages = allPages
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
            }
        }
    }
}
