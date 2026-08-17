import Foundation

public enum Sub2APISettingsError: LocalizedError, Equatable, Sendable {
    case invalidBaseURL

    public var errorDescription: String? {
        "sub2api base URL must use HTTPS, loopback HTTP for local development, or the explicitly trusted local override, without embedded credentials."
    }
}

public enum Sub2APISettingsReader {
    public static let apiKeyEnvironmentKey = "SUB2API_API_KEY"
    public static let baseURLEnvironmentKey = "SUB2API_BASE_URL"
    public static let missingCredentialsMessage =
        "Missing sub2api API key. Add a group API key in Settings or set SUB2API_API_KEY."
    public static let missingBaseURLMessage =
        "Missing or invalid sub2api base URL. Add one in Settings or set SUB2API_BASE_URL."

    public static func apiKey(
        environment: [String: String] = ProcessInfo.processInfo.environment) -> String?
    {
        self.cleaned(environment[self.apiKeyEnvironmentKey])
    }

    public static func baseURL(
        environment: [String: String] = ProcessInfo.processInfo.environment) -> URL?
    {
        guard let raw = self.cleaned(environment[self.baseURLEnvironmentKey]) else { return nil }
        let validator = ProviderEndpointOverrideValidator()
        if let url = validator.validatedURLAllowingLoopbackHTTP(raw),
           url.query == nil,
           url.fragment == nil
        {
            return url
        }
        guard let url = URL(string: raw),
              Self.isTrustedInsecureHTTPOrigin(url),
              url.query == nil,
              url.fragment == nil,
              ["", "/", "/v1", "/v1/"].contains(url.path)
        else { return nil }
        return url
    }

    public static func validateBaseURL(
        environment: [String: String] = ProcessInfo.processInfo.environment) throws
    {
        guard self.baseURL(environment: environment) != nil else {
            throw Sub2APISettingsError.invalidBaseURL
        }
    }

    /// This fork deliberately permits exactly one public HTTP origin for a personal
    /// Sub2API account. Do not broaden this exception: requests carry the bearer key.
    static func isTrustedInsecureHTTPOrigin(_ url: URL) -> Bool {
        url.scheme?.lowercased() == "http" &&
            url.host?.lowercased() == "64.181.225.158" &&
            url.port == 8080 &&
            url.user == nil &&
            url.password == nil
    }

    static func cleaned(_ raw: String?) -> String? {
        guard var value = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return nil
        }
        if (value.hasPrefix("\"") && value.hasSuffix("\"")) ||
            (value.hasPrefix("'") && value.hasSuffix("'"))
        {
            value = String(value.dropFirst().dropLast())
        }
        value = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}
