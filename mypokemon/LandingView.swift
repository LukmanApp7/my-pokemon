//
//  LandingView.swift
//  My Pokemon
//
//  Created by Lukman Hakim on 05/11/25.
//

import SwiftUI

struct LandingView: View {
    var body: some View {
        NavigationView {
            PagerTabStripRepresentable()
                .navigationBarTitleDisplayMode(.inline)
                .edgesIgnoringSafeArea(.bottom) // supaya pager bar tidak terpotong
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
    }
}
