//
//  ContentView.swift
//  Word Scramble
//
//  Created by Isaque da Silva on 30/06/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        List(0..<10) {
            Text("Texto de Exemplo \($0 + 1)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
