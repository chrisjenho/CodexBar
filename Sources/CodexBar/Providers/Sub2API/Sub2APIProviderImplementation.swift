import CodexBarCore
import Foundation

struct Sub2APIProviderImplementation: ProviderImplementation {
    let id: UsageProvider = .sub2api

    @MainActor
    func presentation(context _: ProviderPresentationContext) -> ProviderPresentation {
        ProviderPresentation { _ in "api" }
    }

    @MainActor
    func observeSettings(_ settings: SettingsStore) {
        _ = settings[providerConfig: .sub2api, field: .apiKey]
        _ = settings[providerConfig: .sub2api, field: .endpoint]
        _ = settings.tokenAccountsData(for: .sub2api)
    }

    @MainActor
    func isAvailable(context: ProviderAvailabilityContext) -> Bool {
        Sub2APISettingsReader.apiKey(environment: context.environment) != nil &&
            Sub2APISettingsReader.baseURL(environment: context.environment) != nil
    }

    @MainActor
    func settingsFields(context: ProviderSettingsContext) -> [ProviderSettingsFieldDescriptor] {
        [
            ProviderSettingsFieldDescriptor(
                id: "sub2api-api-key",
                title: "Fallback API key",
                subtitle: "Used when no group API key account is selected.",
                kind: .secure,
                placeholder: "sk-…",
                binding: context.providerConfigBinding(.apiKey),
                actions: [],
                isVisible: nil,
                onActivate: nil),
            ProviderSettingsFieldDescriptor(
                id: "sub2api-base-url",
                title: "Base URL",
                subtitle: "HTTPS is required, except for loopback and this fork's explicit http://64.181.225.158:8080 override. HTTP exposes the bearer key.",
                kind: .plain,
                placeholder: "https://sub2api.example.com or http://64.181.225.158:8080",
                binding: context.providerConfigBinding(.endpoint),
                actions: [],
                isVisible: nil,
                onActivate: nil),
        ]
    }
}
