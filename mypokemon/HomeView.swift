//
//  HomeView.swift
//  My Pokemon
//
//  Created by Lukman Hakim on 05/11/25.
//

import SwiftUI
import Alamofire
import MBProgressHUD

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
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }

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

// MARK: - MBProgressHUD Wrapper for SwiftUI
struct HUDWrapper: UIViewControllerRepresentable {
    @Binding var isVisible: Bool
    let text: String?
    
    class Coordinator {
        var hud: MBProgressHUD?
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .clear
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isVisible {
            if context.coordinator.hud == nil {
                let hud = MBProgressHUD.showAdded(to: uiViewController.view, animated: true)
                hud.label.text = text ?? "Loading..."
                hud.backgroundView.style = .solidColor
                hud.backgroundView.color = UIColor.black.withAlphaComponent(0.3)
                context.coordinator.hud = hud
            }
        } else {
            if let hud = context.coordinator.hud {
                hud.hide(animated: true)
                context.coordinator.hud = nil
            }
        }
    }
}

// MARK: - SwiftUI View
struct HomeView: View {
    @StateObject private var viewModel = PokemonViewModel()
    @State private var isRefreshing = false

    var body: some View {
        ZStack {
            NavigationView {
                List(viewModel.pokemons) { pokemon in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(pokemon.name.capitalized)
                            .font(.headline)
                    }
                    .padding(.vertical, 6)
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Pokémon List")
                .onAppear {
                    viewModel.fetchPokemons()
                }
                .refreshable {
                    viewModel.fetchPokemons()
                }
            }

            // Overlay HUD
            HUDWrapper(isVisible: $viewModel.isLoading, text: "Loading...")
                .allowsHitTesting(false)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
