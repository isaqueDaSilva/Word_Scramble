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
    
    var body: some View {
        NavigationView {
            List {
                VStack {
                    Text(gameIsOn ? rootWord : "Press the Start Button!")
                        .frame(maxWidth: 430)
                        .font(.headline.bold())
                        .multilineTextAlignment(.center)
                    HStack{
                        TextField("Enter your word", text: $newWord)
                            .textFieldStyle(.roundedBorder)
                        Image(systemName: "\(newWord.count).circle")
                    }
                }
                .listRowBackground(Color(CGColor(red: 240, green: 246, blue: 246, alpha: 0)))
                
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
                        
                    })
                } else {
                    Button("Start the Game", action: {
                        gameIsOn = true
                    })
                }
            }
            .onSubmit(addNewWord)
        }
    }
    
    func addNewWord() {
        let lowercaseAnswer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard lowercaseAnswer.count > 0 else { return }
        usedWord.insert(lowercaseAnswer, at: 0)
        newWord = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
