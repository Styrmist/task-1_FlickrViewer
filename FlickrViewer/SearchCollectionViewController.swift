import UIKit

class SearchCollectionViewController: UICollectionViewController {
    
    private let reuseIdentifier = "Cell"
    private let ImageViewTag = 1
    var textSearch = ""
    var photos = [[String: AnyObject]]()
    var curPage = 1
    var allPages = 0
    
    @IBOutlet weak var searchField: UITextField!
    @IBAction func search(_ sender: UITextField) {
        if let text = searchField.text {
            textSearch = text
        }
        
        FlickrAPI.searchPhotos(page: curPage, text: textSearch) { (photosArray, allPages, error) in
            self.photos = photosArray
            self.curPage += 1
            self.allPages = allPages
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView?.prefetchDataSource = self
        collectionView.keyboardDismissMode = .interactive
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SearchCollectionViewCell
        let photoDict = photos[(indexPath as NSIndexPath).row]
        if let imageUrlString = photoDict["url_m"] as? String {
            cell.imageView.loadFromURL(imageUrlString)
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMore"{
            if let cellIndex = self.collectionView?.indexPathsForSelectedItems {
                let detailVC = segue.destination as! DetailViewController
                detailVC.imageLink = (photos[cellIndex[0].row]["url_m"] as! String)
            }
        }
    }
}

extension SearchCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if indexPaths.last?[1] == photos.count - 1  {
            if allPages != 0 && curPage < allPages {
                FlickrAPI.searchPhotos(page: curPage, text: textSearch) { (photosArray, allPages, error) in
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
