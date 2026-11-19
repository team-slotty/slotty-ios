//
//  AuthError.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/19/26.
//

import Foundation

/// 로그인/회원가입 중에 생길 수 있는 오류
enum AuthError: Error, Equatable {
    /// 아이디 또는 비밀번호가 맞지 않음
    case invalidCredentials
    /// 이미 쓰는 아이디
    case loginIdDuplicated
    /// 서버에 아직 없는 기능
    case notSupported
}
