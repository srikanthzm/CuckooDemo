//
//  Network.swift
//  Demo
//
//  Created by Srikanth Thangavel on 31/05/21.
//


import Alamofire
import Foundation

// MARK: - Request Extensions

// Make an Alamofire Request conform to Bedrock's Cancellable protocol so that it can be appended to a MockRequest.
// This will allow the request to be cancelled via the MockRequest Cancellable returned from KRNetworkClient's start request
// funtions in Test and Debug builds.
extension Alamofire.Request: Bedrock.Cancellable {
    public func cancel() {
        // We need to call the Request function cancel(), which returns a Request. We need to disambiguate
        // on the return type to be able to do this.
        let _: Request = cancel()
    }
}

// MARK: - Data Response Extensions
// TODO: This should look at the response codes and override the result if a failure code is detected.
extension DataResponse where Failure == AFError {

    /// Creates an Alamofire DataResponse from a mock response and other parameters.
    ///
    /// - Note:
    ///     The Result provided to this function will be overriden in the case that the MockResponse's status code is outside of the acceptableStatusCodes.
    ///     In this case the Result will be replaced with a failure case with the same error Alamofire would generate for an unacceptable status code.
    ///
    /// - Parameters:
    ///   - request: The URLRequest used to generate the response..
    ///   - response: The MockResponse instance this DataResponse represents.
    ///   - acceptableStatusCodes: A Range<Int> representing the valid status codes for the response. Defaults to 200 through 299, the same defaults as Alamofire.
    ///   - result: A Result based on the MockResponse.
    init(
        request: URLRequest,
        response: MockResponse,
        acceptableStatusCodes: Range<Int> = 200..<300,
        result: Result<Success, Failure>)
    {
        let resolvedResult: Result<Success, Failure>

        // If the status code on the MockResponse is acceptable use the result provided at initialization.
        if acceptableStatusCodes.contains(response.statusCode) {
            resolvedResult = result
        } else {
            // If the status code was not acceptable generate an Alamofire error for an uncacceptable status code.
            let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: response.statusCode))
            resolvedResult = .failure(error)
        }

        self.init(
            request: request,
            response: HTTPURLResponse(mock: response),
            data: response.data,
            metrics: nil,
            serializationDuration: 0,
            result: resolvedResult
        )
    }
}

extension DataResponseSerializerProtocol {

    /// Serializes a MockResponse with the receiving data response serializer.
    func serializeMock(response mockResponse: MockResponse) -> DataResponse<SerializedObject, AFError> {
        let request = URLRequest(url: mockResponse.url)
        let response = HTTPURLResponse(mock: mockResponse)
        let data = mockResponse.data

        let result: Result<SerializedObject, AFError>

        do {
            let serialized = try serialize(request: request, response: response, data: data, error: nil)
            result = .success(serialized)
        } catch {
            result = .failure(.responseSerializationFailed(reason: .customSerializationFailed(error: error)))
        }

        return DataResponse(request: request, response: mockResponse, result: result)
    }
}

//
//  CuckooDataSource.swift
//  KrogerNetworking
//
//  Created by David Barry on 9/16/20.
//  Copyright © 2020 Kroger. All rights reserved.
//

import Foundation

public class CuckooDataSource: ConditionalMockDataSource {
    public var bootstrapString: String = "" {
        didSet { updateMocks() }
    }

    // This lock is used to protect access to the mocks property, which will be accessed from a background thread
    // by Cuckoo, and will be updated on the main thread by Bootstrap.
    private let lock = NSRecursiveLock()
    private var mocks: [EnabledConditionalMock] = []

    public func enabledMocks() -> [EnabledConditionalMock] {
        lock.lock(); defer { lock.unlock() }

        return mocks
    }

    private func updateMocks() {
        let ids = bootstrapString.split(separator: ",").map(String.init)
        var newMocks = [EnabledConditionalMock]()

        for rawID in ids {
            var id = rawID.trimmingCharacters(in: .whitespacesAndNewlines)
            var isOneTime = false

            if id.hasPrefix("-") {
                isOneTime = true
                id = String(id.dropFirst())
            }

            newMocks.append(EnabledConditionalMock(id: id, isOneTimeMock: isOneTime))
        }

        lock.whileLocked {
            mocks = newMocks
        }
    }
}

//
//  Cuckoo.swift
//  KrogerNetworking
//
//  Created by David Barry on 5/13/21.
//  Copyright © 2021 Kroger. All rights reserved.
//

import Foundation

/// Public and internal API for interfacing with the Cuckoo singleton instance.
public enum Cuckoo {

    // MARK: - Public API

    /// Indicates whether Cuckoo mocks are enabled.
    public static var mockingIsEnabled: Bool {
        get { cuckooInstance.mockingIsEnabled }

        set { cuckooInstance.mockingIsEnabled = newValue }
    }

    /// Updates the list of enabled conditional responses using comma separated list of IDs that comes from Bootstrap.
    public static func setEnabledConditionalResponseIDs(_ enabledIDsString: String) {
        cuckooInstance.setEnabledConditionalResponseIDs(enabledIDsString)
    }

    /// Resets one time mock responses. Any one time response that has been fulfilled can be fulfilled again.
    public static func resetOneTimeMockResponses() {
        cuckooInstance.resetOneTimeMockResponses()
    }

    // MARK: - Non Release Properties

    #if !RELEASE
    static var mockRepository: MockRepository { cuckooInstance.mockRepository }
    #endif

    // A singleton instance of a Cuckoo mock repository used to back the public static functionality.
    // It uses the launch arguments passed to the application.
    private static let cuckooInstance = CuckooInstance(
        launchArguments: CuckooLaunchArguments(launchArguments: ProcessInfo.processInfo.arguments)
    )
}

// MARK: -

/// An instance of a Cuckoo mock respository and configuration, intended to use as a singleton. All interfacing with Cuckoo should be done through the Cuckoo
/// type above. This is internal, and not private, soley for the purpose of covering with unit tests.
///
/// Using a singleton instances ensures that all KRNetworkClient instances can share the same mock repository, and that the switchboard
/// settings will apply regardless of the KRNetworkClient instance used. Currently there is no reason to have multiple instances of a MockRepository
/// or its data source, as there is only one set of configuration files in use by the application. Using a singleton instance ensures that we don't parse those configuration
/// files more than once per application run and have one set of state for all mocks.
class CuckooInstance {

    // MARK: Properties

    var mockingIsEnabled: Bool {
        get {
            #if !RELEASE
            return mockRepository.isEnabled
            #else
            return false
            #endif
        }

        set {
            guard mockingEnabledWithLaunchArguments == false else { return }
            #if !RELEASE
            mockRepository.isEnabled = newValue
            #endif
        }
    }

    /// Updates the list of enabled conditional responses using comma separated list of IDs that comes from Bootstrap.
    func setEnabledConditionalResponseIDs(_ enabledIDsString: String) {
        guard mockingEnabledWithLaunchArguments == false else { return }
        #if !RELEASE
        mockDataSource.bootstrapString = enabledIDsString
        #endif
    }
/// Resets one time mock responses. Any one time response that has been fulfilled can be fulfilled again.
    func resetOneTimeMockResponses() {
        #if !RELEASE
        mockRepository.resetOneTimeMocks()
        #endif
    }

    // MARK: Non Release Properties

    #if !RELEASE
    let mockRepository: MockRepository
    let mockDataSource = CuckooDataSource()
    #endif

    /// Indicates whether Cuckoo was enabled via launch arguments. If this is true configuring Cuckoo via the public functions will have no effect. The
    /// configuration supplied by the launch arguments will always take precedence.
    private let mockingEnabledWithLaunchArguments: Bool

    // MARK: Initialization

    /// Creates a CuckooInstance instance with the specified launch arguments.
    ///
    /// - Parameter launchArguments: Launch arguments passed to configure Cuckoo, likely from automation tests.
    init(launchArguments: CuckooLaunchArguments) {
        #if !RELEASE
        // Configure the default date formatter. This is the formatter used to encode Date Templates found in
        // mock responses. If no format is specified by a date template this formatter will be used to generate
        // a date string. The format and time zone should represent the most commonly used date string formats
        // in network responses. Outlier formats can be customized on a per-template basis.
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        let configuration = MockConfiguration(
            dataSource: mockDataSource,
            dateFormatter: dateFormatter,
            bundle: .main
        )

        // Create the mock repository
        let repository = MockRepository(configuration: configuration, telemeter: StandardTelemeter.main)

        // Sets the initial enabled state of Cuckoo mocks based on the launch arguments. If this was enabled
        // via launch arguments this will enable Cuckoo. If not it will set it to disabled until is enabled manually
        // through the switchboard.
        repository.isEnabled = launchArguments.enableMocking
        mockingEnabledWithLaunchArguments = launchArguments.enableMocking

        mockRepository = repository

        // Configure the data source with any conditional mocks specified in the launch arguments.
        if !launchArguments.enableConditionalMockIDs.isEmpty {
            let bootstrapString = launchArguments.enableConditionalMockIDs.joined(separator: ",")
            mockDataSource.bootstrapString = bootstrapString
        }
        #else
        mockingEnabledWithLaunchArguments = false
        #endif
    }
}

//
//  KRNetworkClient.swift
//  Pods
//
//  Created by Galluzzo, Eric (NonEmp) on 2/28/17.
//
//

import Alamofire
import Bedrock
import Cuckoo
import Foundation

//#if DEBUG
//    import krogernetfox
//#endif

internal let jsonConvertibleKey = "KRJsonConvertibleKey"

extension KRJsonConvertible {
    internal func kr_asParameters() -> Parameters {
        [jsonConvertibleKey: self]
    }
}

extension KRNetworkEndPoint.RequestMethod {
    var afHTTPMethod: Alamofire.HTTPMethod {
        switch self {
        case .get:      return .get
        case .post:     return .post
        case .delete:   return .delete
        case .put:      return .put
        }
    }
}

public protocol SensorDataDelegate: AnyObject {
    func getSensorData() -> String
}

public protocol NetworkClientDecodableRequest {

    func start<T: Decodable>(decodableRequest request: KRNetworkRequest,
                             success: @escaping (_ decodedObject: T) -> Void,
                             failure: @escaping (_ error: KRNetworkClient.StartDecodableRequestError) -> Void)
}

public protocol NetworkClientDataRequest {
    func start(request: KRNetworkRequest,
               result: @escaping (Result<Data, KRNetworkClient.StartDecodableRequestError>) -> Void)
}

/// Encodes a Parameters object with a single key of jsonConvertibleKey
public struct KRJsonConvertibleEncoding: ParameterEncoding {

    /// Creates a URL request by encoding parameters and applying them onto an existing request.
    ///
    /// - parameter urlRequest: The request to have parameters applied.
    /// - parameter parameters: The parameters to apply.
    ///
    /// - throws: An Error if the encoding process encounters an error.
    ///
    /// - returns: The encoded request.
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()

        guard let parameters = parameters, let jsonConvertible = parameters[jsonConvertibleKey] as? KRJsonConvertible else {
            return urlRequest
        }

        do {
            let data = try jsonConvertible.toJsonData()

            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }

            urlRequest.httpBody = data
        } catch {
            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }

        return urlRequest
    }
}

/**
 A class that allows you to make JSON and data requests, especially to Kroger APIs.
 - Note: Generally, you should use the static methods in KRNetworking unless you have a specific reason to create a new KRNetworkClient, such as pharmacy code or mocking out for unit tests.
 */
@objc
open class KRNetworkClient: NSObject {

    public enum StartDecodableRequestError: Error, Equatable {
        case decoding(DecodingError)
        case network(NSError)
        case unknown

        public static func == (lhs: StartDecodableRequestError, rhs: StartDecodableRequestError) -> Bool {
            switch (lhs, rhs) {
            case (.unknown, .unknown):
                return true
            case let (.network(a), .network(b)):
                return a == b
            case let (.decoding(a), .decoding(b)):
                return a.failureReason == b.failureReason
            default:
                return false
            }
        }
    }

    //---------------------------------
    // MARK: - Properties
    //---------------------------------

    public static let defaultConfiguration: KRNetworkConfiguration = {
        var configuration = KRNetworkConfiguration()
        configuration.currentEnvironment = .production
        return configuration
    }()

    public static let defaultError = NSError(domain: "com.kroger.krogernetworking.error", code: 1)
    public let configuration: KRNetworkConfiguration
    public let sessionManager: Session

    let errorHandler: KRNetworkErrorHandler

    /// The default session manager.
    public static let defaultSessionManager: Session = {

        let configuration = URLSessionConfiguration.default
        var protocols: [AnyClass] = []
        //        #if DEBUG
        //            protocols.append(NFXProtocol.self)
        //        #endif
        protocols.append(KRNetworkMockController.self)
        configuration.protocolClasses = protocols

        let manager = Session(configuration: configuration)

        return manager
    }()

    public static let defaultAuthorizationErrorHandler: KRNetworkErrorHandler.KRAuthorizationErrorHandler = { returnError in

        // Sign Out if necessary
        KRNetworkAuthenticationController.shared.clearAuthentication(for: .oauth)

        if (returnError.userInfo["X-UnauthorizedReason"] as? String) == "failedauthentication" || (returnError.userInfo["X-UnauthorizedReason"] as? String) == "InvalidCredentials" {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name.Networking.Failed, object: returnError)
            }
        } else if (returnError.userInfo["X-UnauthorizedReason"] as? String) == "useridlocked" || (returnError.userInfo["X-UnauthorizedReason"] as? String) == "Locked" || returnError.userInfo["X-UnauthorizedReason"] as? String == "userid locked" {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name.Networking.Locked, object: returnError)
            }
        } else if (returnError.userInfo["X-UnauthorizedReason"] as? String) == "accountreset" {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name.Networking.FailedDueToRemotePasswordChange, object: returnError)
            }
        } else if (returnError.userInfo["X-UnauthorizedReason"] as? String) == "invalid refresh_token" {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name.Networking.InvalidRefreshToken, object: returnError)
            }
        } else {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name.Networking.Failed, object: returnError)
            }
        }
    }

    public weak var sensorDataDelegate: SensorDataDelegate?

    #if !RELEASE
    private let mockRepository: MockRepository = Cuckoo.mockRepository
    #endif

}
