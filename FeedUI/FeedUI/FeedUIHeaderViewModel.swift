//
//  FeedUIHeaderViewModel.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/06/30.
//

import Foundation

struct CategoryCellModel: Equatable {
    let category: String
}

struct FeedHeaderViewModel {
    @BindableObject var selectedCategory = ""
    var cellModels: [CategoryCellModel] = {[CategoryCellModel.init(category: "전체")]}()
    
    init (cellModels: [CategoryCellModel]) {
        self.cellModels.append(contentsOf: cellModels)
    }
}
