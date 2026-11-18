//
//  VisitFormTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/18/26.
//

import Foundation
import Testing
@testable import Slotty

/// 방문 등록 입력 검사
@MainActor
struct VisitFormTests {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    @Test func 처음_값은_지금부터_4시간이고_번호를_넣으면_등록할_수_있다() {
        var form = VisitForm(now: now)
        #expect(form.endAt.timeIntervalSince(form.startAt) == 4 * 60 * 60)
        form.plateNumber = "12가 3456"
        #expect(form.trimmedPlateNumber == "12가3456")
        #expect(form.problem == nil)
    }

    @Test func 차량번호가_비어_있으면_등록할_수_없다() {
        var form = VisitForm(now: now)
        form.plateNumber = "   "
        #expect(form.problem == "차량번호를 입력해 주세요")
    }

    @Test func 종료가_시작보다_빠르면_등록할_수_없다() {
        var form = VisitForm(now: now)
        form.plateNumber = "12가3456"
        form.endAt = form.startAt - 60
        #expect(form.problem == "종료 시각은 시작 시각보다 늦어야 해요")
    }

    @Test func 최대_24시간을_넘으면_등록할_수_없다() {
        var form = VisitForm(now: now)
        form.plateNumber = "12가3456"
        form.endAt = form.startAt + 24 * 60 * 60 + 60
        #expect(form.problem == "방문은 최대 24시간까지 등록할 수 있어요")
    }
}
