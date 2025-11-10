//
//  HomeView.swift
//  My Pokemon
//
//  Created by Lukman Hakim on 05/11/25.
//

import SwiftUI
import Alamofire
import MBProgressHUD
import RxSwift

// MARK: - Model
struct Pokemon: Identifiable, Decodable {
    var id: String { name }            // untuk SwiftUI List
    let name: String
    let url: String
}

// MARK: - Response wrapper
struct PokemonResponse: Decodable {
    let next: String
    let results: [Pokemon]
}

class PokemonService {
    static let shared = PokemonService()

    func fetchPokemons(from url: String? = nil) -> Single<PokemonResponse> {
        let endpoint = url ?? "https://pokeapi.co/api/v2/pokemon?offset=0&limit=10"
        
        return Single.create { single in
            let request = AF.request(endpoint)
                .validate()
                .responseDecodable(of: PokemonResponse.self) { response in
                    switch response.result {
                    case .success(let result):
                        single(.success(result))
                    case .failure(let error):
                        single(.failure(error))
                    }
                }

            return Disposables.create {
                request.cancel()
            }
        }
    }
}

// MARK: - ViewModel
class PokemonRxViewModel: ObservableObject {
    private let disposeBag = DisposeBag()

    // Output
    @Published var pokemons: [Pokemon] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var refreshUrl: String?

    // Trigger
    let refreshTrigger = PublishSubject<Void>()

    init() {
        bind()
    }

    private func bind() {
        refreshTrigger
            .do(onNext: { [weak self] _ in
                self?.isLoading = true
                self?.errorMessage = nil
            })
            .flatMapLatest { [weak self] _ -> Observable<PokemonResponse> in
                guard let self = self else { return .empty() }
                
                // jika nextURL ada, pakai itu, kalau tidak pakai default
                let urlToUse = self.refreshUrl ?? "https://pokeapi.co/api/v2/pokemon?offset=0&limit=10"
                return PokemonService.shared.fetchPokemons(from: urlToUse)
                    .asObservable()
                    .catch { error in
                        DispatchQueue.main.async {
                            self.errorMessage = error.localizedDescription
                            self.isLoading = false
                        }
                        return .empty()
                    }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                self.pokemons = response.results
                self.refreshUrl = response.next
                self.isLoading = false
            })
            .disposed(by: disposeBag)
    }

    func refresh() {
        refreshTrigger.onNext(())
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

// MARK: - Reusable Modifier: onFirstAppear
extension View {
    func onFirstAppear(perform action: @escaping () -> Void) -> some View {
        modifier(FirstAppearModifier(action: action))
    }
}

struct FirstAppearModifier: ViewModifier {
    let action: () -> Void
    @State private var didAppear = false

    func body(content: Content) -> some View {
        content.onAppear {
            guard !didAppear else { return }
            didAppear = true
            action()
        }
    }
}

// MARK: - SwiftUI View
struct HomeView: View {
    @StateObject private var viewModel = PokemonRxViewModel()

    var body: some View {
        ZStack {
            NavigationView {
                if let error = viewModel.errorMessage {
                    VStack(spacing: 10) {
                        Text("Failed to load data")
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                        Button("Retry") {
                            viewModel.refresh()
                        }
                        .padding(.top, 8)
                    }
                } else {
                    List(viewModel.pokemons) { pokemon in
                        NavigationLink(destination: DetailView(name: pokemon.name)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(pokemon.name.capitalized)
                                    .font(.headline)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .navigationTitle("Pokémon List")
                    .refreshable {
                        viewModel.refresh()
                    }
                }
            }

            // Overlay HUD
            HUDWrapper(isVisible: $viewModel.isLoading, text: "Loading...")
                .allowsHitTesting(false)
        }
        .onFirstAppear {
            viewModel.refresh()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
