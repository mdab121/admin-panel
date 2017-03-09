import Foundation
import Vapor
import HTTP
import Flash
import Auth

public struct Configuration {
    
    public static var shared: Configuration?
    
    public enum Field: String {
        case name                       = "adminpanel.name"
        case unauthorizedPath           = "adminpanel.unauthorizedPath"
        case loadRoutes                 = "adminpanel.loadRoutes"
        case profileImageFallbackUrl    = "adminpanel.profileImageFallbackUrl"
        case loginSuccessPath           = "adminpanel.loginSuccessPath"
        case welcomeMailViewPath        = "adminpanel.welcomeMailViewPath"
        case resetPasswordViewPath      = "adminpanel.resetPasswordViewPath"
        case autoLoginFirstUser         = "adminpanel.autoLoginFirstUser"
        case ssoCallbackPath            = "adminpanel.ssoCallbackPath"
        case roles                      = "adminpanel.roles"
        
        var path: [String] {
            return rawValue.components(separatedBy: ".")
        }
        
        var error: Abort {
            return .custom(status: .internalServerError,
                           message: "Admin panel error - \(rawValue) config is missing.")
        }
    }
    
    public let name: String
    public let unauthorizedPath: String
    public let loadRoutes: Bool
    public let profileImageFallbackUrl: String
    public let loginSuccessPath: String
    public let welcomeMailViewPath: String
    public let resetPasswordViewPath: String
    public let autoLoginFirstUser: Bool
    public var ssoProvider: SSOProtocol?
    public let ssoCallbackPath: String?
    public let roles: [Role]
    public var roleNodes: [Node] {
        
            return roles.map({
                $0.makeNode()
            })
       
    }
    
    public var defaultRole: String {
        return "admin"
    }
    
    public init(drop: Droplet) throws {
        try self.init(config: drop.config)
    }
    
    public init(config: Config) throws {
        name                       = try Configuration.extract(field: .name, config: config)
        unauthorizedPath           = try Configuration.extract(field: .unauthorizedPath, config: config)
        loadRoutes                 = try Configuration.extract(field: .loadRoutes, config: config)
        profileImageFallbackUrl    = try Configuration.extract(field: .profileImageFallbackUrl, config: config)
        loginSuccessPath           = try Configuration.extract(field: .loginSuccessPath, config: config)
        welcomeMailViewPath        = try Configuration.extract(field: .welcomeMailViewPath, config: config)
        resetPasswordViewPath      = try Configuration.extract(field: .resetPasswordViewPath, config: config)
        autoLoginFirstUser         = try Configuration.extract(field: .autoLoginFirstUser, config: config)
        ssoCallbackPath            = config[Field.ssoCallbackPath.path]?.string
        roles                      = try Configuration.extract(field: .roles, config: config)
    }
    
    public func makeNode() -> Node {
        return Node([
            "name"                      : Node(name),
            "unauthorizedPath"          : Node(unauthorizedPath),
            "loadRoutes"                : Node(loadRoutes),
            "profileImageFallbackUrl"   : Node(profileImageFallbackUrl),
            "loginSuccessPath"          : Node(loginSuccessPath),
            "welcomeMailViewPath"       : Node(welcomeMailViewPath),
            "resetPasswordViewPath"     : Node(resetPasswordViewPath),
            "sso"                       : Node(ssoProvider != nil)
        ])
    }
    
    private static func extract(field: Field, config: Config) throws -> String {
        guard let string = config[field.path]?.string else {
            throw field.error
        }
        
        return string
    }
    
    
    private static func extract(field: Field, config: Config) throws -> Bool {
        guard let bool = config[field.path]?.bool else {
            throw field.error
        }
        
        return bool
    }
    
    private static func extract(field: Field, config: Config) throws -> [Role] {
        guard let array = config[field.path]?.array else {
            throw field.error
        }
        
        var roleArray: [Role] = []
        
        for role in array {
            guard let config = role as? Config else {
                print("adminpanel.roles failed to parse a role")
                continue
            }
            do {
                try roleArray.append(Role(config: config))
            } catch {
                print(error)
                print("adminpanel.roles failed to parse a role")
            }
        }
        
        return roleArray
    }
}
