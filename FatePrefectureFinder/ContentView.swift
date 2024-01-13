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
            ResultView(currentView: $currentView, prefectureData: prefectureData, parent: self)
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
                    self.saveResultToUserDefaults(prefectureData: data) // 関数をインスタンスメソッドとして呼び出す
                    self.currentView = .result // 結果画面に遷移
                case .failure:
                    self.showError = true  // エラーフラグを設定
                    self.currentView = .error // エラー画面に遷移
                }
            }
        }
    }

    func saveResultToUserDefaults(prefectureData: Prefecture) {
        //Prefectureのようなカスタム型のデータを保存するために、Data型に変換（エンコード）
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(prefectureData) {
            //UserDefaultsにデータを追加
            UserDefaults.standard.set(encodedData, forKey: "savedResults")
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
            }
            .buttonStyle(PressableButtonStyle())
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
            Section(header: Text("プロフィール情報を入力").font(.headline)) {
                ZStack(alignment: .leading) {
                    if username.isEmpty {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red.opacity(0.2)) // Light red fill for empty TextField
                            .frame(height: 36)
                    }
                    TextField("名前", text: $username)
                        .padding(.horizontal, 4)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(username.isEmpty ? Color.red : Color.gray, lineWidth: 1) // Softer border color
                )
                .padding(.vertical, 4)

                DatePicker("生年月日", selection: $birthday, displayedComponents: .date)
                Picker("血液型", selection: $bloodType) {
                    ForEach(["A", "B", "AB", "O"], id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                DatePicker("今日の日付", selection: $today, displayedComponents: .date)
            }

            Button("占う") {
                let birthdayData = convertDateToYearMonthDay(birthday)
                let todayData = convertDateToYearMonthDay(today)
                startLoading(username, birthdayData, bloodType, todayData)
            }
            .buttonStyle(PrimaryButtonStyle(disabled: username.isEmpty))
            .disabled(username.isEmpty)
            .opacity(username.isEmpty ? 0.5 : 1)
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
            CustomProgressView()
            Text("結果を取得中です。しばらくお待ちください。").padding()
        }
    }
}

struct CustomProgressView: View {
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.8)
            .stroke(AngularGradient(gradient: .init(colors: [.blue, .purple]), center: .center), style: StrokeStyle(lineWidth: 8, lineCap: .round))
            .frame(width: 50, height: 50)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            .onAppear() {
                self.isAnimating = true
            }
    }
}

struct ResultView: View {
    @Binding var currentView: ContentView.ViewType
    var prefectureData: Prefecture?

    var body: some View {
        VStack {
            if let data = prefectureData {
                Text("結果").font(.title).padding()
                ResultCardView(prefectureData: data)
                Button("もう一度占う") {
                    currentView = .input
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }
}

struct ResultCardView: View {
    var prefectureData: Prefecture

    var body: some View {
        VStack(alignment: .leading) {
            Text(prefectureData.name).font(.headline)
            Text("県庁所在地: \(prefectureData.capital)")
            if let day = prefectureData.citizenDay {
                Text("県民の日: \(day.month)月\(day.day)日")
            }
            Text("海岸線: \(prefectureData.hasCoastLine ? "あり" : "なし")")
            Text(prefectureData.brief).padding()
            KFImage(URL(string: prefectureData.logoUrl))
                .resizable().scaledToFit().frame(width: 100, height: 100)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding()
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
    var disabled: Bool = false  // Make the disabled parameter optional with a default value

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .background(disabled ? Color.gray : Color.blue)  // Use the disabled state
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(10)
            .shadow(radius: 5)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: configuration.isPressed)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
