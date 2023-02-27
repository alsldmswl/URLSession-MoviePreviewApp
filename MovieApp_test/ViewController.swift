
import UIKit

class ViewController: UIViewController {
    
    var movieModel: MovieModel?
    var term = ""
    var networkLayer = NetworkLayer()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    @IBOutlet weak var movieTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieTableView.delegate = self
        movieTableView.dataSource = self
        searchBar.delegate = self
        requestMovieAPI()
        
    }
    //리팩토링
    func loadImage(urlString: String, completion: @escaping (UIImage?) -> Void){
        networkLayer.request(type: .justURL(urlString: urlString)) { data, response, error in
            if let hasData = data {
                completion(UIImage(data: hasData))
                return
            }
            completion(nil)
        }
    }
    
    //    func loadImage(urlString: String, completion: @escaping (UIImage?) -> Void) { //completion: 동작이 최종적으로 완료되었을 때 실행
    //        let sessionConfig = URLSessionConfiguration.default
    //        let session = URLSession(configuration: sessionConfig)
    //
    //        if let hasURL = URL(string: urlString) { // url 받아오기
    //            var request = URLRequest(url: hasURL) // 받은 url 요청
    //            request.httpMethod = "GET"
    //
    //            session.dataTask(with: request) { data, response, error in
    //                print((response as! HTTPURLResponse).statusCode)
    //
    //                if let hasData = data {
    //                    completion(UIImage(data: hasData))
    //                    return
    //                }
    //
    //            }.resume()
    //            session.finishTasksAndInvalidate()
    //        }
    //       completion(nil)
    //    }
    
    //리팩토링
    func requestMovieAPI() {
        
        let term = URLQueryItem(name: "term", value: term)
        let media = URLQueryItem(name: "media", value: "movie")
        let querys = [term, media]
        networkLayer.request(type: .searchMovie(querys: querys)) { data, response, error in
            if let hasData = data {
                do{
                    self.movieModel =  try JSONDecoder().decode(MovieModel.self, from: hasData)
                    
                    DispatchQueue.main.async {
                        self.movieTableView.reloadData()
                    }
                    
                }catch {
                    print(error)
                }
            }
        }
    }
    // 네트워크 호출
    //    func requestMovieAPI() {
    //        let sessionConfig = URLSessionConfiguration.default
    //        let session = URLSession(configuration: sessionConfig)
    //
    //        //base url
    //        var components = URLComponents(string: "https://itunes.apple.com/search")
    //        //term 입력
    //        let term = URLQueryItem(name: "term", value: term)
    //        let media = URLQueryItem(name: "media", value: "movie")
    //
    //        components?.queryItems = [term, media]
    //        //-> "https://itunes.apple.com/search?term=marvel&media=movie"
    //        // 주소 가져오기
    //       guard let url = components?.url else {
    //            return
    //        }
    //        // 위에서 만든 주소를 가져옴(요청)
    //        var request = URLRequest(url: url)
    //        request.httpMethod = "GET" // 읽어오기
    //
    //        // request를 호출해서 결과값으로 data, response, error를 준다
    //        let task = session.dataTask(with: request) { data, response, error in
    //            print((response as! HTTPURLResponse).statusCode)
    //
    //            //decoding - 컴퓨터의 언어를 사람이 읽을 수 있는 언어로 바꾼다.(<-> 인코딩)
    //            if let hasData = data {
    //                do{
    //                    self.movieModel =  try JSONDecoder().decode(MovieModel.self, from: hasData)
    //                      데이터 받아온다
    //                    print(self.movieModel ?? "no data")
    //
    //                    DispatchQueue.main.async {
    //                        self.movieTableView.reloadData()
    //                      받아온 데이터 reload한다/ 클로져 안에서작성된코드 메인스레드를 사용해야함
    //                    }
    //
    //                }catch {
    //                    print(error)
    //                }
    //            }
    //        }
    //        task.resume()
    //        session.finishTasksAndInvalidate()
    //
    //    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movieModel?.results.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = UIStoryboard(name: "DetailViewController", bundle: nil).instantiateViewController(identifier: "DetailViewController") as! DetailViewController // DetailViewController 가져오기
        tableView.deselectRow(at: indexPath, animated: true)
        
        detailVC.movieResult = self.movieModel?.results[indexPath.row]
        
        self.present(detailVC, animated: true) {}
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        cell.titleLabel.text = self.movieModel?.results[indexPath.row].trackName
        cell.descriptionLabel.text = self.movieModel?.results[indexPath.row].shortDescription
        
        
        if let hasURL =  self.movieModel?.results[indexPath.row].image {
            self.loadImage(urlString: hasURL) { image in
                DispatchQueue.main.async {
                    cell.movieImageView.image = image
                }
            }
        }
        
        //date
        if let dateString = self.movieModel?.results[indexPath.row].releaseDate
        {
            let formatter = ISO8601DateFormatter()
            if let isoDate = formatter.date(from: dateString){
                
                let myFommatter = DateFormatter()  //내가 원하는 타입으로 날짜 설정
                myFommatter.dateFormat = "yyyy-MM-dd"
                let dateString = myFommatter.string(from: isoDate)
                
                cell.dateLabel.text = dateString
            }
            
        }
        
        return cell
    }
    
    
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let hasText = searchBar.text else {
            return
        }
        term = hasText
        requestMovieAPI()
        self.view.endEditing(true)
    }
}
