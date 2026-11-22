//
//  MyVehicleViewModel.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation
import Observation

/// 내 차량 관리 화면의 목록과 삭제
@Observable
final class MyVehiclesViewModel {
    /// 우리 세대 차량 - 불러오기 전에는 nil
    private(set) var vehicles: [RegisteredVehicle]?
    /// 화면에 띄울 오류 문구 - 없으면 nil
    private(set) var errorMessage: String?
    
    let repository: any VehicleRepository
    
    init(repository: any VehicleRepository) {
        self.repository = repository
    }
    
    /// 목록 불러오기
    func load() async {
        do {
            vehicles = try await repository.fetchVehicles()
            errorMessage = nil
        } catch {
            errorMessage = (error as? APIError)?.serverMessage ?? "차량 목록을 불러오지 못했어요"
        }
    }
    
    /// 삭제 - 성공하면 목록을 다시 불러오고 true
    func delete(_ vehicle: RegisteredVehicle) async -> Bool {
        do {
            try await repository.delete(vehicleId: vehicle.id)
            await load()
            return true
        } catch {
            errorMessage = (error as? APIError)?.serverMessage ?? "차량을 삭제하지 못했어요"
            return false
        }
    }
}
