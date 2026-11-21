//
//  KeychainTokenStore.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/20/26.
//

import Foundation
import Security

/// 토큰을 KeyChain에 저장하는 저장소 - 기기 안에 암호화되어 남고 앱을 다시 켜도 유지된다
struct KeychainTokenStore: TokenStore {
    /// KeyChain 안에서 이 앱의 토큰을 묶는 이름
    private let service: String
    
    init(service: String = "com.slotty.auth") {
        self.service = service
    }
    
    func save(_ tokens: AuthTokens) throws {
        try write(tokens.accessToken, account: Key.accessToken)
        try write(tokens.refreshToken, account: Key.refreshToken)
    }
    
    func load() -> AuthTokens? {
        guard
            let accessToken = read(account: Key.accessToken),
            let refreshToken = read(account: Key.refreshToken)
        else {
            return nil
        }
        return AuthTokens(accessToken: accessToken, refreshToken: refreshToken)
    }
    
    func clear() {
        delete(account: Key.accessToken)
        delete(account: Key.refreshToken)
    }
    
    // MARK: - Keychain
    
    private enum Key {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
    }
    
    /// 항목 하나를 찾는 기본 조건 (비밀번호 종류 + 서비스 이름 + 키)
    private func query(account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }
    
    /// 지우고 새로 넣는다 - 같은 키가 이미 있으면 추가가 실패하기 때문
    private func write(_ value: String, account: String) throws {
        delete(account: account)
        var item = query(account: account)
        item[kSecValueData as String] = Data(value.utf8)
        // 기기 잠금을 한 번 푼 뒤에만 읽을 수 있고, 다른 기기로 백업/이전되지 않음
        item[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        let status = SecItemAdd(item as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }
    
    private func read(account: String) -> String? {
        var item = query(account: account)
        item[kSecReturnData as String] = true
        item[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: AnyObject?
        guard SecItemCopyMatching(item as CFDictionary, &result) == errSecSuccess, let data = result as? Data
        else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    private func delete(account: String) {
        SecItemDelete(query(account: account) as CFDictionary)
    }
}

/// Keychain 저장 실패 - OSStatus 코드
enum KeychainError: Error, Equatable {
    case saveFailed(OSStatus)
}
