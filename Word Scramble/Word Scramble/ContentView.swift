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
    
    @State private var showingRoles = false
    
    let roles = [
        "- It is not valid to use words that contain less than 3 words;",
        "- The repetition of words is not valid;",
        "- The same word that is being displayed is not valid;",
        "- Words that do not exist in your language are not valid;"
    ]
    
    @ViewBuilder var roleView: some View {
        VStack {
            VStack {
                
                Text("In this game, you will be given a random word with 8 letters and your challenge will be to write the maximum number of words that contain the letters of the original word!")
                    .font(.subheadline.bold())
                    .multilineTextAlignment(.center)
                    .frame(width: 300)
            }
            .padding(10)
            
            VStack {
                Text("Roles:")
                    .font(.title.bold())
                
                Text("\(roles[0])\n\(roles[1])\n\(roles[2])\n\(roles[3])")
                    .font(.subheadline.bold())
            }
            .frame(width: 300)
            
            Button("Start", action: {
                gameIsOn = true
                displayedWord()
            })
            .buttonStyle(.borderedProminent)
        }
    }
    
    @ViewBuilder var gameView: some View {
        NavigationView {
            List {
                VStack {
                    Spacer()
                    
                    Text(rootWord)
                        .font(.title3.bold())
                        .frame(maxWidth: 430)
                    
                    Rectangle()
                        .frame(width: 300, height: 1)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    HStack {
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
                    }
                    Spacer()
                }
                
                if !usedWord.isEmpty {
                    Section("Typed Word") {
                        ForEach(usedWord, id: \.self) { word in
                            HStack {
                                Image(systemName: "\(usedWord.count).circle.fill")
                                Text(word)
                            }
                        }
                    }
                }
            }
            .navigationTitle(gameIsOn ? "Word Scramble" : "")
            .toolbar {
                if gameIsOn {
                    Button("New Word", action: {
                        usedWord.removeAll()
                        points = 0
                        displayedWord()
                    })
                }
            }
            .toolbar {
                if gameIsOn {
                    ToolbarItemGroup(placement: .bottomBar, content: {
                        Text("Points: \(points)")
                            .font(.headline.bold())
                            .foregroundColor(.gray)
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
    
    var body: some View {
        ZStack {
            if gameIsOn == false {
                gameView.blur(radius: 10)
                VStack {
                    Text(showingRoles ? "Word Scramble" : "Welcome to Word Scramble")
                        .font(.title.bold())
                        .foregroundColor(.blue)
                        .padding(5)
                        .transition(.asymmetric(insertion: .scale, removal: .opacity))
                    
                    Text(showingRoles ? "" : "A fun word game that will make sure you never get bored again 😉")
                        .frame(width: 350)
                        .font(.title3.bold())
                        .multilineTextAlignment(.center)
                    
                    if showingRoles == false {
                        Button("Show Roles", action: {
                            withAnimation {
                                showingRoles = true
                            }
                        })
                        .buttonStyle(.borderedProminent)
                        .padding(15)
                    }
                    
                    roleView
                        .frame(width: 350, height: showingRoles ? 400 : 0)
                        .background(.thinMaterial)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                }
            } else {
                gameView
            }
        }
    }
    
    func addNewWord() {
        let lowercaseAnswer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard lowercaseAnswer.count >= 3 else {
            alertError(title: "Short Word", message: "That word seems too short!\nChoose a bigger word!")
            newWord = ""
            return
        }
        
        guard newWord != rootWord else {
            alertError(title: "Same word as the orginal", message: "Choose a word that is different from the original!")
            newWord = ""
            return
        }
        
        guard isOriginal(word: lowercaseAnswer) else {
            alertError(title: "Word already used!", message: "It is not allowed to use two identical words as an answer!")
            newWord = ""
            return
        }
        
        guard isPossible(word: lowercaseAnswer) else {
            alertError(title: "Word not recognized", message: "It is not possible to spell this word from \"\(rootWord)\"!")
            newWord = ""
            return
        }
        
        guard isReal(word: lowercaseAnswer) else {
            alertError(title: "Unavailable word", message: "This word is unavailable in this language or does not exist!")
            newWord = ""
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
