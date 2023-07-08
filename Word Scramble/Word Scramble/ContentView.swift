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
    @State private var points = 0
    
    @ViewBuilder var gameView: some View {
        VStack {
            Text(gameIsOn ? rootWord : "Press the Start Button!")
                .frame(maxWidth: 430)
                .font(.headline.bold())
                .multilineTextAlignment(.center)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray)
            
            Spacer()
            
            HStack{
                TextField("Enter your word", text: $newWord)
                    .textInputAutocapitalization(.never)
                
                Image(systemName: "\(newWord.count).circle")
                
                if newWord.count > 0 {
                    Button(action: {
                        newWord.removeAll()
                    }, label: {
                        Image(systemName: "x.circle.fill")
                            .foregroundColor(.black)
                    })
                }
                
                if !newWord.isEmpty {
                    Section("Typed Words") {
                        ForEach(usedWord, id: \.self) { word in
                            HStack {
                                Image(systemName: "\(newWord.count).circle")
                                Text(word)
                            }
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                
            }
            .navigationTitle("Word Scramble")
            .toolbar {
                if gameIsOn {
                    Button("New Word", action: {
                        usedWord.removeAll()
                        points = 0
                        displayedWord()
                    })
                } else {
                    Button("Start the Game", action: {
                        gameIsOn = true
                        displayedWord()
                    })
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar, content: {
                    Text("Points: \(points)")
                        .font(.headline.bold())
                        .foregroundColor(.gray)
                })
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
        
        guard gameIsOn else {
            alertError(title: "Game not started", message: "Start the game to be able to answer!")
            return
        }
        
        guard lowercaseAnswer.count >= 3 else {
            alertError(title: "Short Word", message: "That word seems too short!\nChoose a bigger word!")
            return
        }
        
        guard newWord != rootWord else {
            alertError(title: "Same word as the orginal", message: "Choose a word that is different from the original!")
            return
        }
        
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
        
        if newWord.count >= 3 && newWord.count < 6 {
            points += 2
        } else if newWord.count >= 6 && newWord.count < 8 {
            points += 4
        } else if newWord.count >= 8  {
            points += 8
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
