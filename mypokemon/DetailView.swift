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
import RxSwift

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

class DetailService {
    static let shared = DetailService()
    
    func fetchDetail(for name: String) -> Single<PokemonDetail> {
        let url = "https://pokeapi.co/api/v2/pokemon/\(name.lowercased())"
        return Single.create { single in
            let request = AF.request(url)
                .validate()
                .responseDecodable(of: PokemonDetail.self) { response in
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
class PokemonDetailRxViewModel: ObservableObject {
    private let disposeBag = DisposeBag()

    // Output
    @Published var detail: PokemonDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Trigger
    let loadTrigger = PublishSubject<String>()
    
    init() {
        bind()
    }
    
    private func bind() {
        loadTrigger
            .do(onNext: { [weak self] _ in
                self?.isLoading = true
                self?.errorMessage = nil
            })
            .flatMapLatest { name in
                DetailService.shared.fetchDetail(for: name)
                    .asObservable()
                    .catch { error in
                        Observable<PokemonDetail>.empty().do(onSubscribe: {
                            DispatchQueue.main.async {
                                self.errorMessage = error.localizedDescription
                            }
                        })
                    }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] detail in
                self?.detail = detail
                self?.isLoading = false
            })
            .disposed(by: disposeBag)
    }
    
    func loadDetail(for name: String) {
        loadTrigger.onNext(name)
    }
}

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
    @StateObject private var viewModel = PokemonDetailRxViewModel()

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
                                .frame(width: 200, height: 200)
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
                        viewModel.loadDetail(for: name)
                    }
                }
            } else {
                EmptyView()
            }

            // HUD overlay
            HUDWrapper(isVisible: $viewModel.isLoading, text: "Loading...")
                .allowsHitTesting(false)
        }
        .onAppear {
            viewModel.loadDetail(for: name)
        }
    }
}

//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView()
//    }
//}
