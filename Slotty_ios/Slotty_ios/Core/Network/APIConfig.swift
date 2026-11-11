//
//  APIConfig.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/11/26.
//

import Foundation

enum APIConfig {
    static let baseURL: URL = {
        guard
            let value = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
            let url = URL(string: value)
        else {
            fatalError("Info.plist에 API_BASE_URL이 없거나 형식이 잘못됐습니다.")
        }
        return url
    } ()
}
