//
//   PrefectureModel.swift
//  FatePrefectureFinder
//
//  Created by 持田晴生 on 2024/01/08.
//

import Foundation

// 都道府県に関する情報を格納する構造体
struct Prefecture: Codable {
    let name: String          // 都道府県名
    let capital: String       // 県庁所在地
    let citizenDay: MonthDay? // 県民の日（オプショナル）
    let hasCoastLine: Bool    // 海岸線があるかどうか
    let logoUrl: String       // 都道府県のロゴURL
    let brief: String         // 都道府県の概要

    // JSONのキーとプロパティ名のマッピングを定義
    enum CodingKeys: String, CodingKey {
        case name, capital, citizenDay = "citizen_day", hasCoastLine = "has_coast_line", logoUrl = "logo_url", brief
    }
}

// 月日を表現する構造体
struct MonthDay: Codable {
    let month: Int // 月
    let day: Int   // 日
}
