//
//  Petition.swift
//  Petitions
//
//  Created by Mihai Leonte on 9/11/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation


struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
}
