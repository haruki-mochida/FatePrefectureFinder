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

            Button(action: { currentView = .input }) {
                Text("占いを始める")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .padding()
        }
        .padding()
    }
}

struct InputView: View {
    @Binding var currentView: ContentView.ViewType
    @State private var username: String = ""
    @State private var birthday: Date = Date()
    @State private var bloodType: String = "A"
    @State private var today: Date = Date()
    var startLoading: (String, YearMonthDay, String, YearMonthDay) -> Void

    var body: some View {
        Form {
            Section {
                TextField("名前", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                DatePicker("生年月日", selection: $birthday, displayedComponents: .date)
                Picker("血液型", selection: $bloodType) {
                    ForEach(["A", "B", "AB", "O"], id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                DatePicker("今日の日付", selection: $today, displayedComponents: .date)
            }

            Section {
                Button("占う") {
                    let birthdayData = convertDateToYearMonthDay(birthday)
                    let todayData = convertDateToYearMonthDay(today)
                    startLoading(username, birthdayData, bloodType, todayData)
                }
                .buttonStyle(PrimaryButtonStyle())
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
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(1.5)
                .padding()
            Text("結果を取得中です。しばらくお待ちください。")
                .padding()
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
                    .padding()

                CardView {
                    VStack(alignment: .leading) {
                        Text(data.name)
                            .font(.headline)
                        Text("県庁所在地: \(data.capital)")
                        if let day = data.citizenDay {
                            Text("県民の日: \(day.month)月\(day.day)日")
                        }
                        Text("海岸線: \(data.hasCoastLine ? "あり" : "なし")")
                        Text(data.brief)
                        KFImage(URL(string: data.logoUrl))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    }
                    .padding()
                }

                Button("もう一度占う") {
                    currentView = .input
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }
}

struct CardView<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding()
    }
}

struct ErrorView: View {
    @Binding var currentView: ContentView.ViewType

    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.red)
                .font(.largeTitle)
                .padding()
            Text("エラーが発生しました")
                .font(.title)
                .padding()
            Text("何か問題が発生したようです。もう一度試してください。")
                .padding()
            Button("再試行") {
                currentView = .home
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
