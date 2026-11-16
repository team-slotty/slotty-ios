//
//  ServerDateDecodingTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/16/26.
//

import Foundation
import Testing
@testable import Slotty

/// 서버 날짜 해석 (시간대 없는 LocalDateTime → 한국 시간)
struct ServerDateDecodingTests {
    /// 날짜 글자 하나를 서버 규칙으로 해석
    private func decode(_ text: String) throws -> Date {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(APIClient.decodeServerDate)
        return try decoder.decode(Date.self, from: Data("\"\(text)\"".utf8))
    }

    /// 2026-11-16 19:12 (한국 시간)
    private let expected = DateComponents(
        calendar: Calendar(identifier: .gregorian),
        timeZone: TimeZone(identifier: "Asia/Seoul"),
        year: 2026, month: 11, day: 16, hour: 19, minute: 12
    ).date!

    @Test func 시간대_없는_날짜를_한국_시간으로_읽는다() throws {
        #expect(try decode("2026-11-16T19:12:00") == expected)
    }

    @Test func 소수점_초가_붙어도_초까지만_읽는다() throws {
        #expect(try decode("2026-11-16T19:12:00.123456") == expected)
    }

    @Test func 형식이_다르면_에러를_던진다() {
        #expect(throws: DecodingError.self) {
            try decode("2026/11/16 19:12")
        }
    }
}
