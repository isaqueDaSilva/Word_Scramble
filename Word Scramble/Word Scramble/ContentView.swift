//
//  ContentView.swift
//  Word Scramble
//
//  Created by Isaque da Silva on 30/06/23.
//

import SwiftUI

struct ContentView: View {
    @State private var gameIsOn = false
    var body: some View {
        NavigationView {
            List {
                
            }
            .navigationTitle("Word Scramble")
            .toolbar {
                Button("Start Game", action: {
                    gameIsOn = true
                })
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
