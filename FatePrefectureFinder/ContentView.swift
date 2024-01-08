//
//  ContentView.swift
//  FatePrefectureFinder
//
//  Created by 持田晴生 on 2023/12/14.
//

import SwiftUI

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
            // 必要に応じて、再試行またはキャンセルのオプションを提供
        }
    }
}

struct ResultView: View {
    @Binding var currentView: ContentView.ViewType
    // 結果表示用の状態変数（例）
    @State private var prefectureName: String = "富山県"
    // 他の情報も同様に表示

    var body: some View {
        VStack {
            Text("結果")
                .font(.title)
            Text(prefectureName)
            // 他の都道府県情報の表示
            Button("もう一度占う") {
                currentView = .input
            }
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
