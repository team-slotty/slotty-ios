//
//  UnidentifiedAPITests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation
import Testing
@testable import Slotty

/// 서버 미확인 차량 - 현황판에서 기록 id를 찾아 해제/바로잡기
@MainActor
@Suite(.serialized)
struct UnidentifiedAPITests {
    private let host = "unidentified.test"
    /// 6번 면이 미확인 (기록 id 12)
    private let board = #"{ "slots": [{ "slotId": 6, "assignedUnitNumber": "101", "status": "UNIDENTIFIED", "occupant": null, "unidentifiedReportId": 12 }] }"#
    
    /// 요청한 경로를 남기고, 현황판/내 차량/내 정보는 정상 응답
    private func makeRepository(paths: Recorder) -> LiveParkingRepository {
        let board = board
        StubURLProtocol.handlers[host] = { request in
            let path = request.url?.path ?? ""
            paths.append(path)
            switch path {
            case "/api/parking-board": return (200, board)
            case "/api/vehicles/me": return (200, #"{ "unitNumber": "101", "vehicles": [] }"#)
            case "/api/me": return (200, #"{ "household": { "unitNumber": "101" }, "villa": { "name": "슬로티빌라" } }"#)
            default: return (200, "{}")
            }
        }
        let client = APIClient(baseURL: URL(string: "http://\(host)")!, session: StubURLProtocol.makeSession(), tokenStore: InMemoryTokenStore())
        return LiveParkingRepository(client: client)
    }
    
    @Test func 차량_떠남은_그_면의_기록을_해제한다() async throws {
        let paths = Recorder()
        
        _ = try await makeRepository(paths: paths).markLeft(spotNumber: 6)
        
        #expect(paths.values.contains("/api/unidentified-reports/12/resolve"))
    }
    
    @Test func 내_차예요는_그_면의_기록으로_바로잡는다() async throws {
        let paths = Recorder()
        let vehicle = Vehicle(id: "1", plateNumber: "12가3456", unit: "101")
        
        _ = try await makeRepository(paths: paths).markAsMine(spotNumber: 6, vehicle: vehicle)
        
        #expect(paths.values.contains("/api/unidentified-reports/12/mine"))
    }
    
    @Test func 미확인이_아닌_면은_실패한다() async {
        await #expect(throws: ParkingError.notUnconfirmed) {
            _ = try await makeRepository(paths: Recorder()).markLeft(spotNumber: 1)
        }
    }
}

/// 가짜 네트워크가 받은 요청 경로를 모으는 상자 - 네트워크 쪽에서 써서 잠금으로 보호한다
final class Recorder: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [String] = []
    
    var values: [String] {
        lock.withLock { storage }
    }
    
    nonisolated func append(_ value: String) {
        lock.withLock { storage.append(value) }
    }
}
