//
//  PrefectureService.swift
//  FatePrefectureFinder
//
//  Created by 持田晴生 on 2024/01/08.
//

import Foundation
import Alamofire

class PrefectureService {
    // APIエンドポイント
    private let url = "https://yumemi-ios-junior-engineer-codecheck.app.swift.cloud/my_fortune"

    // API通信を行い、結果を取得する関数
    func fetchPrefecture(requestData: RequestData, completion: @escaping (Result<Prefecture, Error>) -> Void) {
        // Alamofireを使用してリクエストを送信
        AF.request(url, method: .post, parameters: requestData, encoder: JSONParameterEncoder.default)
            .responseDecodable(of: Prefecture.self) { response in
                // レスポンスの結果に基づいて処理を分岐
                switch response.result {
                case .success(let prefecture):
                    // レスポンスが成功した場合、取得したデータをcompletionハンドラに渡す
                    completion(.success(prefecture))
                case .failure(let error):
                    // レスポンスが失敗した場合、エラーログを表示し、エラーをcompletionハンドラに渡す
                    if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                        print("Received JSON string: \(jsonString)")
                    }
                    completion(.failure(error))
                }
            }
    }
}

// APIリクエストのためのデータモデル
struct RequestData: Codable {
    let name: String
    let birthday: YearMonthDay
    let bloodType: String
    let today: YearMonthDay
}

// 年月日を表すデータモデル
struct YearMonthDay: Codable {
    let year: Int
    let month: Int
    let day: Int
}
