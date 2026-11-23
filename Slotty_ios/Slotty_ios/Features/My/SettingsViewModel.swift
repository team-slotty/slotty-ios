//
//  SettingsViewModel.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation
import Observation

/// 설정 화면의 연락처 공개와 탈퇴
@Observable
final class SettingsViewModel {
    /// 연락처 공개 - 불러오기 전에는 nil
    private(set) var phonePublic: Bool?
    /// 화면에 띄울 오류 문구 - 없으면 nil
    private(set) var errorMessage: String?

    private let repository: any AccountRepository

    init(repository: any AccountRepository) {
        self.repository = repository
    }

    func load() async {
        do {
            phonePublic = try await repository.fetchPhonePublic()
            errorMessage = nil
        } catch {
            errorMessage = (error as? APIError)?.serverMessage ?? "설정을 불러오지 못했어요"
        }
    }

    /// 연락처 공개 바꾸기 - 실패하면 원래 값으로 되돌린다
    func setPhonePublic(_ isPublic: Bool) async {
        let previous = phonePublic
        phonePublic = isPublic
        do {
            try await repository.updatePhonePublic(isPublic)
            errorMessage = nil
        } catch {
            phonePublic = previous
            errorMessage = (error as? APIError)?.serverMessage ?? "설정을 바꾸지 못했어요"
        }
    }

    /// 탈퇴 - 성공하면 true, 관리자처럼 거절되면 서버 문구
    func withdraw() async -> Bool {
        do {
            try await repository.withdraw()
            return true
        } catch {
            errorMessage = (error as? APIError)?.serverMessage ?? "탈퇴하지 못했어요"
            return false
        }
    }
}
