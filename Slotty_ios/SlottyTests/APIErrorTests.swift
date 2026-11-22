//
//  APIErrorTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/20/26.
//

import Foundation
import Testing
@testable import Slotty

/// 실패 응답을 에러로 바꾸기
@MainActor
struct APIErrorTests {
    @Test func 서버_에러_형식이면_code와_message를_읽는다() {
        let json = """
            { "code": "INVALID_LOGIN", "message": "아이디 또는 비밀번호가 올바르지 않습니다.", "details": {} }
            """
        
        let error = APIClient.error(statusCode: 401, data: Data(json.utf8))
        
        #expect(error == .server(statusCode: 401, code: "INVALID_LOGIN", message: "아이디 또는 비밀번호가 올바르지 않습니다."))
    }
    
    @Test func 서버_에러_형식이_아니면_상태_코드만_남긴다() {
        let error = APIClient.error(statusCode: 500, data: Data())
        
        #expect(error == .badStatus(500))
    }
}
