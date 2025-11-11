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
import RxCocoa

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
    let pokemons = BehaviorRelay<[Pokemon]>(value: [])
    let filteredPokemons = BehaviorRelay<[Pokemon]>(value: [])
    @Published var isLoading: Bool = false
    let errorMessage = BehaviorRelay<String?>(value: nil)
    let refreshUrl = BehaviorRelay<String?>(value: nil)

    // Trigger
    let refreshTrigger = PublishSubject<Void>()
    let searchText = BehaviorRelay<String>(value: "")

    init() {
        bind()
    }

    private func bind() {
        refreshTrigger
            .do(onNext: { [weak self] _ in
                self?.isLoading = true
                self?.errorMessage.accept(nil)
            })
            .flatMapLatest { [weak self] _ -> Observable<PokemonResponse> in
                guard let self = self else { return .empty() }
                
                // jika nextURL ada, pakai itu, kalau tidak pakai default
                let urlToUse = self.refreshUrl.value ?? "https://pokeapi.co/api/v2/pokemon?offset=0&limit=10"
                return PokemonService.shared.fetchPokemons(from: urlToUse)
                    .asObservable()
                    .catch { error in
                        self.errorMessage.accept(error.localizedDescription)
                        self.isLoading = false
                        return .empty()
                    }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                self.pokemons.accept(response.results)
                self.filteredPokemons.accept(response.results)
                self.refreshUrl.accept(response.next)
                self.isLoading = false
            })
            .disposed(by: disposeBag)
        
        // === Filter Search ===
        Observable.combineLatest(pokemons.asObservable(), searchText.asObservable())
            .map { pokemons, query in
                guard !query.isEmpty else { return pokemons }
                return pokemons.filter { $0.name.lowercased().contains(query.lowercased()) }
            }
            .bind(to: self.filteredPokemons)
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
    @State private var disposeBag = DisposeBag()
    @State private var filteredList: [Pokemon] = []

    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    SearchBar(text: Binding(
                        get: { viewModel.searchText.value },
                        set: { viewModel.searchText.accept($0) }
                    ))
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .background(Color(UIColor.systemBackground))
                    
                    if let error = viewModel.errorMessage.value {
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
                        List(filteredList) { pokemon in
                            NavigationLink(destination: DetailView(name: pokemon.name)) {
                                Text(pokemon.name.capitalized)
                                    .font(.headline)
                                    .padding(.vertical, 6)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .refreshable {
                            viewModel.refresh()
                        }
                    }
                }
            }

            // Overlay HUD
            HUDWrapper(isVisible: $viewModel.isLoading, text: "Loading...")
                .allowsHitTesting(false)
        }
        .onFirstAppear {
            bindViewModel()
            viewModel.refresh()
        }
    }
    
    private func bindViewModel() {
        // Bind hasil filter ke state SwiftUI
        viewModel.filteredPokemons
            .asDriver()
            .drive(onNext: { list in
                self.filteredList = list
            })
            .disposed(by: disposeBag)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
