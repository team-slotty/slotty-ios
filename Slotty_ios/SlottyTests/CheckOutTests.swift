//
//  CheckOutTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation
import Testing
@testable import Slotty

/// 서버 출차 - 그 면의 우리 차를 찾아 출차하고 현황판을 다시 받는다
@MainActor
@Suite(.serialized)
struct CheckOutTests {
    private let host = "checkout.test"
    private let options = #"{ "mode": "AUTO", "vehicles": [{ "vehicleId": 1, "plateNumber": "12가3456", "slotId": 1, "slotLabel": "1번", "enteredAt": "2026-11-20T18:30:06" }], "suggestedVehicleId": 1 }"#
    private let board = #"{ "slots": [] }"#
    private let myVehicles = #"{ "unitNumber": "101", "vehicles": [] }"#
    private let me = #"{ "household": { "unitNumber": "101" }, "villa": { "name": "슬로티빌라" } }"#
    
    private func makeRepository() -> LiveParkingRepository {
        let client = APIClient(baseURL: URL(string: "http://\(host)")!, session: StubURLProtocol.makeSession(), tokenStore: InMemoryTokenStore())
        return LiveParkingRepository(client: client)
    }
    
    /// 출차 요청에 줄 응답만 바꾸고, 나머지(옵션, 현황판, 내 차량, 내 정보)는 정상 응답
    private func stub(checkOut: (Int, String)) {
        let (options, board, myVehicles, me) = (options, board, myVehicles, me)
        StubURLProtocol.handlers[host] = { request in
            switch request.url?.path {
            case "/api/parking/check-out-options": return (200, options)
            case "/api/parking/check-out": return checkOut
            case "/api/parking-board": return (200, board)
            case "/api/vehicles/me": return (200, myVehicles)
            case "/api/me": return (200, me)
            default: return (404, "")
            }
        }
    }
    
    @Test func 출차하면_현황판을_다시_받는다() async throws {
        stub(checkOut: (200, #"{ "recordId": 1, "slotId": 1, "slotLabel": "1번", "exitedAt": "2026-11-22T18:40:00" }"#))
        
        let result = try await makeRepository().exit(spotNumber: 1)
        
        #expect(result.villaName == "슬로티빌라")
    }
    
    @Test func 이미_출차됐으면_성공으로_본다() async throws {
        stub(checkOut: (409, #"{ "code": "NOT_PARKED", "message": "주차 중인 차량이 아닙니다.", "details": {} }"#))
        
        let result = try await makeRepository().exit(spotNumber: 1)
        
        #expect(result.villaName == "슬로티빌라")
    }
    
    @Test func 그_면에_우리_차가_없으면_실패한다() async {
        stub(checkOut: (200, ""))
        
        await #expect(throws: ParkingError.vehicleNotFound) {
            _ = try await makeRepository().exit(spotNumber: 7)
        }
    }
}
