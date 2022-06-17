//
//  RegisterError.swift
//  TEST
//
//  Created by  Erwin on 2022/5/31.
//

import Foundation
enum RegError: Error {
    case emailFormat
    case pwtooShort
    case emailUsed
    case others
}
