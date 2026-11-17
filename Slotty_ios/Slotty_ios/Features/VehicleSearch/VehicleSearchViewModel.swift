//
//  VehicleSearchViewModel.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/17/26.
//

import Foundation
import Observation

/// 차량 검색 화면의 상태와 동작
@Observable
final class VehicleSearchViewModel {
    /// 입력한 숫자 - 4자리까지만 받는다
    var query = "" {
        didSet {
            let digits = String(query.filter(\.isNumber).prefix(4))
            if digits != query { query = digits }
        }
    }
    /// 검색 결과 - 아직 검색하지 않았으면 nil
    private(set) var results: [VehicleSearchResult]?
    /// 오늘 남은 검색 횟수 - 한 번도 검색하지 않았으면 nil
    private(set) var remainingCount: Int?
    /// 화면에 띄울 오류 문구 - 없으면 nil
    private(set) var errorMessage: String?
    
    private let repository: any VehicleSearchRepository
    
    init(repository: any VehicleSearchRepository) {
        self.repository = repository
    }
    
    /// 4자리를 다 입력해야 검색할 수 있다
    var canSearch: Bool {
        query.count == 4
    }
    
    /// 검색 - 성공하면 결과와 남은 횟수를 교체
    func search() async {
        guard canSearch else { return }
        do {
            let found = try await repository.search(last4: query)
            results = found.items
            remainingCount = found.remainingCount
            errorMessage = nil
        } catch VehicleSearchError.limitExceeded {
            errorMessage = "오늘 검색 횟수를 모두 사용했어요"
        } catch {
            errorMessage = "검색하지 못했어요"
        }
    }
}
