//
//  HostingPagerItem.swift
//  mypokemon
//
//  Created by Lukman Hakim on 07/11/25.
//

import XLPagerTabStrip
import SwiftUI

final class HostingPagerItem<Content: View>: UIHostingController<Content>, IndicatorInfoProvider {
    private let info: IndicatorInfo

    init(title: String, rootView: Content) {
        self.info = IndicatorInfo(title: title)
        super.init(rootView: rootView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return info
    }
}

