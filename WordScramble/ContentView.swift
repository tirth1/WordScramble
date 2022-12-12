//
//  ContentView.swift
//  WordScramble
//
//  Created by Tirth on 10/23/22.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var errorTitle = ""
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter a new word", text: $newWord)
                        .autocapitalization(.none)
                        .onSubmit(addNewWord)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle.fill")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        if(validateNewWord(word: answer)) {
            withAnimation {
                usedWords.insert(answer, at: 0)
            }
        }
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempRoot = rootWord
        
        for letter in word {
            if let idx = tempRoot.firstIndex(of: letter) {
                tempRoot.remove(at: idx)
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
    
    func validateNewWord(word: String) -> Bool {
        if(!isOriginal(word: word)) {
            wordError(title: "Word used already", message: "Be original.")
            return false
        }
        
        if(!isPossible(word: word)) {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return false
        }
        
        if(!isReal(word: word)) {
            wordError(title: "Word not recongized", message: "You just can't make them up, you know!")
            return false
        }
        
        return true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
