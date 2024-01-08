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

    var body: some View {
        switch currentView {
        case .home:
            HomeView(currentView: $currentView)
        case .input:
            InputView(currentView: $currentView)
        case .loading:
            LoadingView()
        case .result:
            ResultView(currentView: $currentView)
        case .error:
            ErrorView(currentView: $currentView)
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
                currentView = .loading
            }
        }
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
    
    // APIから受け取るデータを表す状態変数
    @State private var prefectureName: String = "富山県"
    @State private var capital: String = "富山市"
    @State private var citizenDay: MonthDay? = MonthDay(month: 5, day: 9)
    @State private var hasCoastLine: Bool = true
    @State private var logoUrl: String = "https://japan-map.com/wp-content/uploads/toyama.png"
    @State private var brief: String = "富山県（とやまけん）は、日本の中部地方に位置する県。県庁所在地は富山市。\n中部地方の日本海側、新潟県を含めた場合の北陸地方のほぼ中央にある。\n※出典: フリー百科事典『ウィキペディア（Wikipedia）』"

    var body: some View {
        VStack {
            Text("結果")
                .font(.title)
            
            // 都道府県名の表示
            Text(prefectureName)
                .font(.headline)
            
            // 県庁所在地の表示
            Text("県庁所在地: \(capital)")
            
            // 県民の日（あれば）の表示
            if let day = citizenDay {
                Text("県民の日: \(day.month)月\(day.day)日")
            }
            
            // 海岸線の有無の表示
            Text("海岸線: \(hasCoastLine ? "あり" : "なし")")
            
            // 都道府県の概要の表示
            Text(brief)
                .padding()
            
            // Kingfisherを使用してロゴ画像を表示
            KFImage(URL(string: logoUrl))
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
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
