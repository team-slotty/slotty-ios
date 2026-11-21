//
//  StubURLProtocol.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/21/26.
//

import Foundation

/// 테스트용 가짜 네트워크 - 실제 서버 대신 handler가 정한 응답(상태 코드, 본문)을 돌려준다
final class StubURLProtocol: URLProtocol {
    /// 요청을 받아 (상태 코드, 본문)을 정한다 - 테스트마다 바꿔 쓰므로 그 테스트는 .serialized로 돌린다
    nonisolated(unsafe) static var handler: ((URLRequest) -> (Int, String))?

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
        let (statusCode, body) = Self.handler?(request) ?? (500, "")
        let response = HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(body.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }

    override nonisolated func stopLoading() {}
}
