//
//  ServerEventParser.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation

/// 서버가 보내는 이벤트(SSE) 줄을 읽어 이벤트 이름을 꺼낸다
/// 예: "event:board-changed" 다음 "data:{...}" 줄에서 board-changed 하나
/// ":ping" 같은 주석 줄은 연결 유지용이라 무시한다
struct ServerEventParser {
    /// 지금 읽고 있는 이벤트 이름 - event 줄이 없으면 기본 이름 message
    private var eventName: String?
    
    /// 한 줄을 읽고, 이벤트 하나가 끝났으면(data 줄) 그 이름을 돌려준다
    mutating func read(_ line: String) -> String? {
        if line.hasPrefix("event:") {
            eventName = line.dropFirst("event:".count).trimmingCharacters(in: .whitespaces)
            return nil
        }
        if line.hasPrefix("data:") {
            defer { eventName = nil }
            return eventName ?? "message"
        }
        return nil
    }
}
