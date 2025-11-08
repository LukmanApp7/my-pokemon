//
//  DetailView.swift
//  mypokemon
//
//  Created by Lukman Hakim on 09/11/25.
//

import SwiftUI
import Alamofire
import MBProgressHUD
import Kingfisher

// MARK: - Detail Model
struct PokemonDetail: Decodable {
    struct Sprite: Decodable {
        let front_default: String?
    }
    struct AbilityEntry: Decodable {
        struct Ability: Decodable {
            let name: String
        }
        let ability: Ability
    }

    let name: String
    let sprites: Sprite
    let abilities: [AbilityEntry]
}

// MARK: - ViewModel
class PokemonDetailViewModel: ObservableObject {
    @Published var detail: PokemonDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchDetail(for name: String) {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }

        let url = "https://pokeapi.co/api/v2/pokemon/\(name.lowercased())"

        AF.request(url)
            .validate()
            .responseDecodable(of: PokemonDetail.self) { response in
                DispatchQueue.main.async {
                    self.isLoading = false
                    switch response.result {
                    case .success(let data):
                        self.detail = data
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
    }
}

struct DetailView: View {
    let name: String
    @StateObject private var viewModel = PokemonDetailViewModel()

    var body: some View {
        ZStack {
            if let detail = viewModel.detail {
                ScrollView {
                    VStack(spacing: 20) {
                        if let imageUrl = detail.sprites.front_default,
                           let url = URL(string: imageUrl) {
                            KFImage(url)
                                .placeholder {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                }
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        }

                        Text(detail.name.capitalized)
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Abilities")
                                .font(.headline)
                            ForEach(detail.abilities, id: \.ability.name) { entry in
                                Text("• \(entry.ability.name.capitalized)")
                            }
                        }

                        Spacer()
                    }
                    .padding()
                }
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 10) {
                    Text("Failed to load Pokémon")
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                    Button("Retry") {
                        viewModel.fetchDetail(for: name)
                    }
                }
            } else {
                EmptyView()
            }

            // HUD overlay
            HUDWrapper(isVisible: $viewModel.isLoading, text: "Loading...")
                .allowsHitTesting(false)
        }
//        .navigationTitle(name.capitalized)
        .onAppear {
            viewModel.fetchDetail(for: name)
        }
    }
}

//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView()
//    }
//}
