//
//  ContentView.swift
//  FatePrefectureFinder
//
//  Created by 持田晴生 on 2023/12/14.
//

import SwiftUI
import Kingfisher

struct ContentView: View {
    @State private var currentView: ViewType = .home
    @State private var prefectureData: Prefecture?
    @State private var isLoading = false
    @State private var showError = false

    var body: some View {
        switch currentView {
        case .home:
            HomeView(currentView: $currentView)
        case .input:
            InputView(currentView: $currentView, startLoading: fetchPrefectureData)
        case .loading:
            LoadingView()
        case .result:
            ResultView(currentView: $currentView, prefectureData: prefectureData)
        case .error:
            ErrorView(currentView: $currentView)
        }
    }

    // APIから都道府県のデータを取得する関数
    func fetchPrefectureData(name: String, birthday: YearMonthDay, bloodType: String, today: YearMonthDay) {
        isLoading = true  // ローディング状態を開始
        showError = false // エラー表示をリセット
        currentView = .loading // ローディング画面に遷移

        // APIリクエスト用のデータを作成
        let requestData = RequestData(name: name, birthday: birthday, bloodType: bloodType, today: today)

        // API通信を実行
        PrefectureService().fetchPrefecture(requestData: requestData) { result in
            DispatchQueue.main.async { // メインスレッドでUIの更新を行う
                isLoading = false // ローディング状態を終了
                switch result {
                case .success(let data):
                    self.prefectureData = data // データを保存
                    self.currentView = .result // 結果画面に遷移
                case .failure:
                    self.showError = true  // エラーフラグを設定
                    self.currentView = .error // エラー画面に遷移
                }
            }
        }
    }

    enum ViewType {
        case home, input, loading, result, error
    }
}

struct HomeView: View {
    @Binding var currentView: ContentView.ViewType

    var body: some View {
        VStack {
            Text("Fate Prefecture Finder")
                .font(.largeTitle)
                .padding()

            Text("あなたと相性の良い都道府県を占います")
                .font(.headline)
                .padding()

            Button("占いを始める") {
                currentView = .input
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
        }
    }
}

struct InputView: View {
    @Binding var currentView: ContentView.ViewType
    // 入力フォームの状態変数（例）
    @State private var username: String = ""
    @State private var birthday: Date = Date()
    @State private var bloodType: String = "A"
    @State private var today: Date = Date()
    var startLoading: (String, YearMonthDay, String, YearMonthDay) -> Void


    var body: some View {
        Form {
            TextField("名前", text: $username)
            DatePicker("生年月日", selection: $birthday, displayedComponents: .date)
            Picker("血液型", selection: $bloodType) {
                ForEach(["A", "B", "AB", "O"], id: \.self) {
                    Text($0)
                }
            }
            DatePicker("今日の日付", selection: $today, displayedComponents: .date)
            Button("占う") {
                let birthdayData = convertDateToYearMonthDay(birthday)
                let todayData = convertDateToYearMonthDay(today)
                startLoading(username, birthdayData, bloodType, todayData)
            }
        }
    }
    private func convertDateToYearMonthDay(_ date: Date) -> YearMonthDay {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return YearMonthDay(year: year, month: month, day: day)
    }

}

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView("占い中...")
                .padding()
            Text("結果を取得中です。しばらくお待ちください。")
        }
    }
}

struct ResultView: View {
    @Binding var currentView: ContentView.ViewType
    var prefectureData: Prefecture?

    var body: some View {
        VStack {
            if let data = prefectureData {
                Text("結果")
                    .font(.title)

                Text(data.name)
                    .font(.headline)

                Text("県庁所在地: \(data.capital)")

                if let day = data.citizenDay {
                    Text("県民の日: \(day.month)月\(day.day)日")
                }

                Text("海岸線: \(data.hasCoastLine ? "あり" : "なし")")

                Text(data.brief)
                    .padding()

                KFImage(URL(string: data.logoUrl))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            }

            Button("もう一度占う") {
                currentView = .input
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

struct ErrorView: View {
    @Binding var currentView: ContentView.ViewType

    var body: some View {
        VStack {
            Text("エラーが発生しました")
            Button("再試行") {
                currentView = .home
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
