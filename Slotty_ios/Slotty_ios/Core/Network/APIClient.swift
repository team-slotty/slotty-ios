//
//  APIClient.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/16/26.
//

import Foundation

/// 서버와 JSON으로 주고받는 공통 클라이언트
struct APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    /// 요청에 붙일 로그인 토큰을 읽는 곳
    private let tokenStore: any TokenStore
    
    init(baseURL: URL = APIConfig.baseURL, session: URLSession = .shared, tokenStore: any TokenStore = KeychainTokenStore()) {
        self.baseURL = baseURL
        self.session = session
        self.tokenStore = tokenStore
        decoder.dateDecodingStrategy = .custom(Self.decodeServerDate)
    }
    
    /// GET 요청을 보내고 응답 JSON을 원하는 타입으로 변환
    func get<Response: Decodable>(_ path: String) async throws -> Response {
        let request = URLRequest(url: baseURL.appending(path: path))
        return try await send(request)
    }
    
    /// POST 요청으로 JSON을 보내고 응답 JSON을 원하는 타입으로 변환
    func post<Body: Encodable, Response: Decodable>(_ path: String, body: Body) async throws -> Response {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        return try await send(request)
    }
    
    /// 요청을 보내고 200번대가 아니면 에러, 맞으면 응답 변환
    private func send<Response: Decodable>(_ request: URLRequest) async throws -> Response {
        let (data, response) = try await session.data(for: authorized(request))
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(statusCode) else {
            throw Self.error(statusCode: statusCode, data: data)
        }
        return try decoder.decode(Response.self, from: data)
    }
    
    /// 저장된 토큰이 있으면 Authorization: Bearer 헤더를 붙인다
    func authorized(_ request: URLRequest) -> URLRequest {
        guard let accessToken = tokenStore.load()?.accessToken else {
            return request
        }
        var request = request
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    /// 실패 응답을 에러로 - 서버 에러 형식이면 code까지, 아니면 상태 코드만
    static func error(statusCode: Int, data: Data) -> APIError {
        guard let body = try? JSONDecoder().decode(ErrorResponse.self, from: data) else {
            return .badStatus(statusCode)
        }
        return .server(statusCode: statusCode, code: body.code)
    }
    
    /// 서버 날짜 해석
    nonisolated static func decodeServerDate(_ decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let text = try container.decode(String.self)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        // 소수점 아래 초 (.123456)가 붙어 와도 앞 글자(초까지)만 사용
        guard let date = formatter.date(from: String(text.prefix(19))) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "날짜 형식이 아니에요 : \(text)")
        }
        return date
    }
}
