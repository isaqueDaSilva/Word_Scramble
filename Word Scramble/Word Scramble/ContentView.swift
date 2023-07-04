//
//  ContentView.swift
//  Word Scramble
//
//  Created by Isaque da Silva on 30/06/23.
//

import SwiftUI

struct ContentView: View {
    @State private var gameIsOn = false
    @State private var usedWord = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Text(gameIsOn ? rootWord : "Press the Start Button!")
                        .frame(maxWidth: 430)
                        .font(.headline.bold())
                        .multilineTextAlignment(.center)
                        .listRowBackground(Color(CGColor(red: 240, green: 246, blue: 246, alpha: 0)))
                    
                    HStack{
                        TextField("Enter your word", text: $newWord)
                            .textInputAutocapitalization(.never)
                        Image(systemName: "\(newWord.count).circle")
                    }
                }
                
                Section("Typed Words:") {
                    ForEach(usedWord, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle.fill")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle("Word Scramble")
            .toolbar {
                if gameIsOn {
                    Button("New Word", action: {
                        displayedWord()
                    })
                } else {
                    Button("Start the Game", action: {
                        gameIsOn = true
                        displayedWord()
                    })
                }
            }
            .onSubmit(addNewWord)
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK", role: .cancel, action: { })
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func addNewWord() {
        let lowercaseAnswer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard lowercaseAnswer.count > 0 else { return }
        
        guard isOriginal(word: lowercaseAnswer) else {
            alertError(title: "Word already used!", message: "It is not allowed to use two identical words as an answer!")
            return
        }
        
        guard isPossible(word: lowercaseAnswer) else {
            alertError(title: "Word not recognized", message: "It is not possible to spell this word from \"\(rootWord)\"!")
            return
        }
        
        guard isReal(word: lowercaseAnswer) else {
            alertError(title: "Unavailable word", message: "This word is unavailable in this language or does not exist!")
            return
        }
        withAnimation {
            usedWord.insert(lowercaseAnswer, at: 0)
        }
        newWord = ""
    }
    
    func displayedWord() {
        if let startWordURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let contentFile = try? String(contentsOf: startWordURL) {
                let allWord = contentFile.components(separatedBy: "\n")
                rootWord = allWord.randomElement() ?? "Unknown Value"
                return
            }
        }
        fatalError("Unable to load file start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWord.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let letterPosition = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: letterPosition)
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
    
    func alertError(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
