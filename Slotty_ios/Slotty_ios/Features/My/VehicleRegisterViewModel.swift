//
//  VehicleRegisterViewModel.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation
import Observation

/// 차량 등록 화면의 입력과 동작
@Observable
final class VehicleRegisterViewModel {
    var plateNumber = ""
    /// 등록하지 못한 이유 - 없으면 nil
    private(set) var errorMessage: String?
    /// 등록 요청 중인지
    private(set) var isRegistering = false
    
    private let repository: any VehicleRepository
    
    init(repository: any VehicleRepository) {
        self.repository = repository
    }
    
    /// 공백을 뺀 차량번호 - 서버도 공백을 빼고 저장한다
    var normalizedPlateNumber: String {
        plateNumber.filter { !$0.isWhitespace }
    }
    
    /// 서버와 같은 형식인지 - 지역(한글 0~2자) + 숫자 2~3자리 + 한글 1자 + 숫자 4자리
    /// 예: 12가3456, 123가4567, 서울12가3456
    var isValidPlateNumber: Bool {
        normalizedPlateNumber.wholeMatch(of: /[가-힣]{0,2}[0-9]{2,3}[가-힣][0-9]{4}/) != nil
    }
    
    /// 형식이 맞고 요청 중이 아닐 때만 [등록하기]를 누를 수 있다
    var canRegister: Bool {
        isValidPlateNumber && !isRegistering
    }
    
    /// 등록 - 성공하면 true, 실패하면 서버 문구(같은 번호가 이미 있음 등)를 보여 준다
    func register() async -> Bool {
        guard isValidPlateNumber else { return false }
        isRegistering = true
        defer { isRegistering = false }
        do {
            try await repository.register(plateNumber: normalizedPlateNumber)
            errorMessage = nil
            return true
        } catch VehicleError.plateDuplicated {
            errorMessage = "이미 등록된 차량번호예요"
            return false
        } catch {
            errorMessage = (error as? APIError)?.serverMessage ?? "차량을 등록하지 못했어요"
            return false
        }
    }
}
