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
    
    init(baseURL: URL = APIConfig.baseURL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    /// GET 요청을 보내고 응답 JSON을 원하는 타입으로 변환
    func get<Response: Decodable>(_ path: String) async throws -> Response
    {
        let url = baseURL.appending(path: path)
        let (data, response) = try await session.data(from: url)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(statusCode) else {
            throw APIError.badStatus(statusCode)
        }
        return try decoder.decode(Response.self, from: data)
    }
}
