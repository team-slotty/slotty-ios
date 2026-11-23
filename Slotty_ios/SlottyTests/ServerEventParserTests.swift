//
//  ServerEventParserTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Testing
@testable import Slotty

/// 서버 이벤트(SSE) 줄 읽기
@MainActor
struct ServerEventParserTests {
    @Test func 서버가_보내는_순서대로_이벤트_이름을_꺼낸다() {
        // 연결 직후 connected, 25초마다 주석 ping, 바뀌면 board-changed
        let lines = [
            "event:connected", "data:{}", "",
            ":ping", "",
            "event:board-changed", #"data:{"slotIds":[2, 5]}"#, "",
        ]
        var parser = ServerEventParser()
        
        let names = lines.compactMap { parser.read($0) }
        
        #expect(names == ["connected", "board-changed"])
    }
    
    @Test func 이벤트_이름이_없으면_message다() {
        var parser = ServerEventParser()
        
        #expect(parser.read("data:hello") == "message")
    }
}
