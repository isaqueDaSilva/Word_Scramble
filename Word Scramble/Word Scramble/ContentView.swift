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
                Section {
                    VStack {
                        Text(rootWord == "" ? "Press start" : rootWord)
                            .font(.title2.bold())
                            .frame(maxWidth: 430)
                    }
                    .listRowBackground(Color(CGColor(red: 240, green: 240, blue: 246, alpha: 0)))
                    
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.none)
                }
                
                Section("Typed Words:") {
                    ForEach(usedWord, id: \.self) { word in
                        HStack{
                            Image(systemName: "\(word.count).circle.fill")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle("Word Scramble")
            .toolbar {
                Button("Start Game", action: {
                    gameIsOn = true
                })
            }
        }.onSubmit(addNewWord)
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        withAnimation {
            usedWord.insert(answer, at: 0)
        }
        newWord = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
