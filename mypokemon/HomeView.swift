//
//  HomeView.swift
//  My Pokemon
//
//  Created by Lukman Hakim on 05/11/25.
//

import SwiftUI
import Alamofire

// MARK: - Model
struct Pokemon: Identifiable, Decodable {
    let id = UUID()            // untuk SwiftUI List
    let name: String
    let url: String
}

// MARK: - Response wrapper
struct PokemonResponse: Decodable {
    let next: String
    let results: [Pokemon]
}

// MARK: - ViewModel
class PokemonViewModel: ObservableObject {
    @Published var pokemons: [Pokemon] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var refresh: String?

    func fetchPokemons() {
        isLoading = true
        errorMessage = nil

        let url = refresh ?? "https://pokeapi.co/api/v2/pokemon?offset=0&limit=10"

        AF.request(url)
            .validate()
            .responseDecodable(of: PokemonResponse.self) { response in
                print("response : ", response)
                DispatchQueue.main.async {
                    self.isLoading = false
                    switch response.result {
                    case .success(let data):
                        self.pokemons = data.results
                        self.refresh = data.next
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
    }
}

struct HomeView: View {
    @StateObject private var viewModel = PokemonViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 10) {
                        Text("Failed to load data")
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                        Button("Retry") {
                            viewModel.fetchPokemons()
                        }
                        .padding(.top, 8)
                    }
                } else {
                    List(viewModel.pokemons) { pokemon in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(pokemon.name.capitalized)
                                    .font(.headline)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(PlainListStyle())
                    .navigationTitle("Pokémon List")
                    .refreshable {
                        viewModel.fetchPokemons()
                    }
                }
            }
            .onAppear {
                viewModel.fetchPokemons()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
