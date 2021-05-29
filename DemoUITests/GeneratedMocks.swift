// MARK: - Mocks generated from file: Demo/UrlSession.swift at 2021-05-29 06:52:53 +0000

//
//  UrlSession.swift
//  Demo
//
//  Created by Srikanth Thangavel on 28/05/21.
//

import Cuckoo
@testable import Demo

import Foundation


 class MockUrlSession: UrlSession, Cuckoo.ClassMock {
    
     typealias MocksType = UrlSession
    
     typealias Stubbing = __StubbingProxy_UrlSession
     typealias Verification = __VerificationProxy_UrlSession

     let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: true)

    
    private var __defaultImplStub: UrlSession?

     func enableDefaultImplementation(_ stub: UrlSession) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    
    
    
     override var url: URL! {
        get {
            return cuckoo_manager.getter("url",
                superclassCall:
                    
                    super.url
                    ,
                defaultCall: __defaultImplStub!.url)
        }
        
        set {
            cuckoo_manager.setter("url",
                value: newValue,
                superclassCall:
                    
                    super.url = newValue
                    ,
                defaultCall: __defaultImplStub!.url = newValue)
        }
        
    }
    
    
    
     override var session: URLSession! {
        get {
            return cuckoo_manager.getter("session",
                superclassCall:
                    
                    super.session
                    ,
                defaultCall: __defaultImplStub!.session)
        }
        
        set {
            cuckoo_manager.setter("session",
                value: newValue,
                superclassCall:
                    
                    super.session = newValue
                    ,
                defaultCall: __defaultImplStub!.session = newValue)
        }
        
    }
    

    

    
    
    
     override func getUser(completion: @escaping (Result<User, Error>) -> Void)  {
        
    return cuckoo_manager.call("getUser(completion: @escaping (Result<User, Error>) -> Void)",
            parameters: (completion),
            escapingParameters: (completion),
            superclassCall:
                
                super.getUser(completion: completion)
                ,
            defaultCall: __defaultImplStub!.getUser(completion: completion))
        
    }
    

	 struct __StubbingProxy_UrlSession: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    var url: Cuckoo.ClassToBeStubbedOptionalProperty<MockUrlSession, URL> {
	        return .init(manager: cuckoo_manager, name: "url")
	    }
	    
	    
	    var session: Cuckoo.ClassToBeStubbedOptionalProperty<MockUrlSession, URLSession> {
	        return .init(manager: cuckoo_manager, name: "session")
	    }
	    
	    
	    func getUser<M1: Cuckoo.Matchable>(completion: M1) -> Cuckoo.ClassStubNoReturnFunction<((Result<User, Error>) -> Void)> where M1.MatchedType == (Result<User, Error>) -> Void {
	        let matchers: [Cuckoo.ParameterMatcher<((Result<User, Error>) -> Void)>] = [wrap(matchable: completion) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockUrlSession.self, method: "getUser(completion: @escaping (Result<User, Error>) -> Void)", parameterMatchers: matchers))
	    }
	    
	}

	 struct __VerificationProxy_UrlSession: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	     init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	    
	    var url: Cuckoo.VerifyOptionalProperty<URL> {
	        return .init(manager: cuckoo_manager, name: "url", callMatcher: callMatcher, sourceLocation: sourceLocation)
	    }
	    
	    
	    var session: Cuckoo.VerifyOptionalProperty<URLSession> {
	        return .init(manager: cuckoo_manager, name: "session", callMatcher: callMatcher, sourceLocation: sourceLocation)
	    }
	    
	
	    
	    @discardableResult
	    func getUser<M1: Cuckoo.Matchable>(completion: M1) -> Cuckoo.__DoNotUse<((Result<User, Error>) -> Void), Void> where M1.MatchedType == (Result<User, Error>) -> Void {
	        let matchers: [Cuckoo.ParameterMatcher<((Result<User, Error>) -> Void)>] = [wrap(matchable: completion) { $0 }]
	        return cuckoo_manager.verify("getUser(completion: @escaping (Result<User, Error>) -> Void)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

 class UrlSessionStub: UrlSession {
    
    
     override var url: URL! {
        get {
            return DefaultValueRegistry.defaultValue(for: (URL?).self)
        }
        
        set { }
        
    }
    
    
     override var session: URLSession! {
        get {
            return DefaultValueRegistry.defaultValue(for: (URLSession?).self)
        }
        
        set { }
        
    }
    

    

    
     override func getUser(completion: @escaping (Result<User, Error>) -> Void)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
}


// MARK: - Mocks generated from file: Demo/User.swift at 2021-05-29 06:52:53 +0000

//
//  User.swift
//  Demo
//
//  Created by Srikanth Thangavel on 28/05/21.
//

import Cuckoo
@testable import Demo

import Foundation


 class MockUser: User, Cuckoo.ClassMock {
    
     typealias MocksType = User
    
     typealias Stubbing = __StubbingProxy_User
     typealias Verification = __VerificationProxy_User

     let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: true)

    
    private var __defaultImplStub: User?

     func enableDefaultImplementation(_ stub: User) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    

    

    

	 struct __StubbingProxy_User: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	}

	 struct __VerificationProxy_User: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	     init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	
	    
	}
}

 class UserStub: User {
    

    

    
}

