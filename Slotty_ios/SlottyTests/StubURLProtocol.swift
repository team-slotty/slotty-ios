//
//  StubURLProtocol.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/21/26.
//

import Foundation

/// 테스트용 가짜 네트워크 - 실제 서버 대신 handler가 정한 응답(상태 코드, 본문)을 돌려준다
final class StubURLProtocol: URLProtocol {
    /// 주소(host)별로 요청을 받아 (상태 코드, 본문)을 정한다
    /// 테스트 묶음마다 다른 host를 써서 동시에 돌아도 섞이지 않게 한다
    nonisolated(unsafe) static var handlers: [String: (URLRequest) -> (Int, String)] = [:]
    
    /// 이 가짜 네트워크를 쓰는 URLSession
    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return URLSession(configuration: configuration)
    }
    
    override nonisolated class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override nonisolated class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override nonisolated func startLoading() {
        let handler = request.url?.host.flatMap { Self.handlers[$0] }
        let (statusCode, body) = handler?(request) ?? (500, "")
        let response = HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(body.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override nonisolated func stopLoading() {}
}
