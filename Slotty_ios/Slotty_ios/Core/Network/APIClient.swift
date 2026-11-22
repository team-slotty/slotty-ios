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
        let data = try await data(for: request)
        return try decoder.decode(Response.self, from: data)
    }
    
    /// DELETE 요청 - 성공 응답(204)에 본문이 없어서 돌려주는 값이 없다
    func delete(_ path: String) async throws {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = "DELETE"
        _ = try await data(for: request)
    }
    
    /// 요청을 보내고 200번대 응답의 본문을 돌려준다
    /// access 토큰이 만료됐으면(UNAUTHORIZED) 재발급받아 한 번만 다시 보낸다
    private func data(for request: URLRequest, retrying: Bool = true) async throws -> Data {
        let (data, response) = try await session.data(for: authorized(request))
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(statusCode) else {
            let error = Self.error(statusCode: statusCode, data: data)
            if retrying, case .server(_, code: "UNAUTHORIZED", _) = error, await reissue() {
                return try await self.data(for: request, retrying: false)
            }
            expireSessionIfNeeded(error)
            throw error
        }
        return data
    }
    
    /// refresh 토큰으로 새 토큰 두 개를 받아 저장한다 - 성공하면 true
    /// 실패(INVALID_REFRESH_TOKEN 등)하면 false를 돌려주고, 부른 쪽이 로그인 화면으로 보낸다
    private func reissue() async -> Bool {
        guard let refreshToken = tokenStore.load()?.refreshToken else { return false }
        var request = URLRequest(url: baseURL.appending(path: "/api/auth/reissue"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try encoder.encode(ReissueRequest(refreshToken: refreshToken))
            // 재발급 요청에는 만료된 access 토큰을 붙이지 않는다
            let (data, response) = try await session.data(for: request)
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200..<300).contains(statusCode) else {
                return false
            }
            let tokens = try decoder.decode(TokenResponse.self, from: data)
            try tokenStore.save(AuthTokens(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken))
            return true
        } catch {
            return false
        }
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
        return .server(statusCode: statusCode, code: body.code, message: body.message)
    }
    
    /// 로그인이 풀렸다는 응답(UNAUTHORIZED)이면 토큰을 지우고 앱에 알린다
    func expireSessionIfNeeded(_ error: APIError) {
        guard case .server(_, code: "UNAUTHORIZED", _) = error else { return }
        tokenStore.clear()
        NotificationCenter.default.post(name: .sessionExpired, object: nil)
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
