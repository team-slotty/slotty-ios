//
//  AdminHouseholdsViewModel.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation
import Observation

/// 관리 탭 세대 목록의 상태와 동작
@Observable
final class AdminHouseholdsViewModel {
    /// 세대 목록 - 불러오기 전에는 nil
    private(set) var households: [AdminHousehold]?
    /// 화면에 띄울 오류 문구 - 없으면 nil
    private(set) var errorMessage: String?
    
    private let repository: any AdminRepository
    
    init(repository: any AdminRepository) {
        self.repository = repository
    }
    
    func load() async {
        do {
            households = try await repository.fetchHouseholds()
            errorMessage = nil
        } catch {
            errorMessage = (error as? APIError)?.serverMessage ?? "세대 목록을 불러오지 못했어요"
        }
    }
    
    func add(unitNumber: String) async {
        let unit = unitNumber.trimmingCharacters(in: .whitespaces)
        guard !unit.isEmpty else { return }
        await run { try await self.repository.addHousehold(unitNumber: unit) }
    }
    
    func delete(_ household: AdminHousehold) async {
        await run { try await self.repository.deleteHousehold(id: household.id) }
    }
    
    func reissueInviteCode(of household: AdminHousehold) async {
        await run { try await self.repository.reissueInviteCode(householdId: household.id) }
    }
    
    func remove(_ member: AdminHousehold.Member, from household: AdminHousehold) async {
        await run { try await self.repository.removeMember(householdId: household.id, memberId: member.id) }
    }
    
    /// 동작을 하고 목록을 다시 불러온다 - 실패하면 서버 문구 (예: 세대원이 남은 세대는 삭제 불가)
    private func run(_ action: () async throws -> Void) async {
        do {
            try await action()
            await load()
        } catch {
            errorMessage = (error as? APIError)?.serverMessage ?? "처리하지 못했어요"
        }
    }
}
