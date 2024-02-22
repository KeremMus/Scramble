//
//  ContentView.swift
//  Scramble
//
//  Created by Kerem Can Bakır on 18.09.2023.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord).autocapitalization(.none)
                }

                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack{
                            Image(systemName:  "\(word.count).circle.fill")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    func addNewWord(){
        if !newWord.isEmpty{
            let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            guard isOriginal(word: answer) else {
                wordError(title: "Word used already", message: "Be more original")
                return
            }

            guard isPossible(word: answer) else {
                wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
                return
            }

            guard isReal(word: answer) else {
                wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
                return
            }
            usedWords.insert(answer, at: 0)
            newWord = ""
        }
    }
    func startGame(){
        if let startingWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startingWords = try? String(contentsOf: startingWordsURL){
                let startingWordsList = startingWords.components(separatedBy: "\n")
                rootWord = startingWordsList.randomElement() ?? "notorious"
                return
            }
        }
        fatalError("Could not load start.txt.")
    }
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
