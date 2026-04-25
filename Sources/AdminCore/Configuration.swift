#if SERVER
  import Foundation

  public struct Configuration: Sendable {
    public var baseRoute: String
    public init(baseRoute: String = "/admin-console") {
      self.baseRoute = baseRoute
    }
    public nonisolated(unsafe) static var shared = Configuration()
  }
#endif
