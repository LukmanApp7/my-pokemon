//
//  PagerTabStripRepresentable.swift
//  mypokemon
//
//  Created by Lukman Hakim on 07/11/25.
//

import SwiftUI
import UIKit

struct PagerTabStripRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> LandingPagerViewController {
        return LandingPagerViewController()
    }

    func updateUIViewController(_ uiViewController: LandingPagerViewController, context: Context) {
        // Nothing dynamic to update for now.
    }
}

struct PagerTabStripRepresentable_Previews: PreviewProvider {
    static var previews: some View {
        PagerTabStripRepresentable()
    }
}
