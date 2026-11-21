//
//  Notification+Session.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/21/26.
//

import Foundation

extension Notification.Name {
    /// 로그인이 풀림 (토큰 없음 / 만료) - 앱이 받아서 로그인 화면으로 돌아간다
    static let sessionExpired = Notification.Name("sessionExpired")
}
