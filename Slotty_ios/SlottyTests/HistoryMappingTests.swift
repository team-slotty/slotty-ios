//
//  HistoryMappingTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation
import Testing
@testable import Slotty

/// 입출차 이력과 미확인 기록 응답 해석
@MainActor
struct HistoryMappingTests {
    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(APIClient.decodeServerDate)
        return decoder
    }
    
    @Test func 주차_중인_기록은_출차가_비어_있다() throws {
        // 배포 서버 응답 그대로
        let json = #"{"items":[{"recordId":1,"plateNumber":"12가3456","slotLabel":"1번","enteredAt":"2026-11-20T18:30:06","enteredBy":{"userId":1,"name":"김민준"},"enterMethod":"MANUAL","exitedAt":null,"exitedBy":null,"exitMethod":null}],"page":0,"size":20,"total":1}"#
        
        let items = try decoder.decode(ParkingHistoryResponse.self, from: Data(json.utf8)).toItems()
        
        #expect(items[0].enteredBy == "김민준")
        #expect(items[0].exitedAt == nil)
        #expect(ParkingHistoryItem.methodLabel(items[0].enterMethod) == "직접")
    }
    
    @Test func 해제된_미확인_기록은_해제_방식을_보여_준다() throws {
        let json = #"{"items":[{"reportId":1,"slotLabel":"6번","plateNumber":null,"reportedBy":{"userId":1,"name":"김민준"},"reportedAt":"2026-11-23T10:38:07","resolvedAt":"2026-11-23T10:38:08","resolveType":"LEFT"}],"page":0,"size":20,"total":1}"#
        
        let items = try decoder.decode(UnidentifiedReportsResponse.self, from: Data(json.utf8)).toItems()
        
        #expect(items[0].plateNumber == nil)
        #expect(items[0].resolveLabel == "차량 떠남")
    }
}
