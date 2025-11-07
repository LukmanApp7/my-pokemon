//
//  LandingPagerViewController.swift
//  mypokemon
//
//  Created by Lukman Hakim on 06/11/25.
//

import UIKit
import XLPagerTabStrip
import SwiftUI

class LandingPagerViewController: ButtonBarPagerTabStripViewController {

    override func viewDidLoad() {
        // styling (tetap)
        settings.style.buttonBarBackgroundColor = .systemBackground
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = .systemBlue
        settings.style.selectedBarHeight = 3
        settings.style.buttonBarItemFont = .systemFont(ofSize: 15, weight: .semibold)
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 8
        settings.style.buttonBarRightContentInset = 8

        super.viewDidLoad()

        buttonBarView.backgroundColor = .systemBackground
        buttonBarView.selectedBar.layer.cornerRadius = 1.5
        buttonBarView.selectedBar.layer.masksToBounds = true

        // ---- gunakan closure hook (kompatibel dengan v8.1.1) ----
        // signature: (oldCell?, newCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void
        changeCurrentIndexProgressive = { [weak self] oldCell, newCell, progressPercentage, changeCurrentIndex, animated in
            guard changeCurrentIndex else { return }

            // warna teks
            oldCell?.label.textColor = .secondaryLabel
            newCell?.label.textColor = .systemBlue

            // animasi scale
            UIView.animate(withDuration: 0.25) {
                oldCell?.transform = .identity
                newCell?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }
        }

        // alternatif: jika kamu ingin juga handler saat index berubah secara langsung
        changeCurrentIndex = { [weak self] oldCell, newCell, animated in
            oldCell?.label.textColor = .secondaryLabel
            newCell?.label.textColor = .systemBlue
        }
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let home = HostingPagerItem(
            title: "Home",
            rootView: HomeView()
        )

        let profile = HostingPagerItem(
            title: "Profile",
            rootView: ProfileView()
        )

        return [home, profile]
    }
}
