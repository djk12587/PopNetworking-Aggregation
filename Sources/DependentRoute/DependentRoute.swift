//
//  File.swift
//  
//
//  Created by Dan_Koza on 5/26/21.
//

import Foundation
import PopNetworking

public protocol DependentNetworkingRoute: NetworkingRoute {
    associatedtype ParentRoute: NetworkingRoute
    associatedtype RequiredParams

    init(parentResponseModel: ParentRoute.ResponseSerializer.SerializedObject, with requiredParams: RequiredParams?) throws
}

extension NetworkingRoute {

    @discardableResult
    public func andThen<DependentRoute: DependentNetworkingRoute>(run dependentRouteType: DependentRoute.Type,
                                                                  initializeWith dependentRouteRequiredParams: DependentRoute.RequiredParams? = nil,
                                                                  completion: @escaping (Result<(Self.ResponseSerializer.SerializedObject,
                                                                                                 DependentRoute.ResponseSerializer.SerializedObject), Error>) -> Void) -> Cancellable
                                                                  where Self.ResponseSerializer.SerializedObject == DependentRoute.ParentRoute.ResponseSerializer.SerializedObject {
        let cancellableTasks = CancellableTasks()

        let parentTask = request { parentResult in
            switch parentResult {
                case .success(let parentResponseModel):
                    do {
                        let dependentRoute = try dependentRouteType.init(parentResponseModel: parentResponseModel, with: dependentRouteRequiredParams)
                        let dependentTask = dependentRoute.request { result in
                            let aggregatedResult = result.map { (parentResponseModel, $0) }
                            completion(aggregatedResult)
                        }
                        cancellableTasks.append(cancellablesTask: dependentTask)
                    }
                    catch {
                        completion(.failure(error))
                    }

                case .failure(let error):
                    completion(.failure(error))
            }
        }

        cancellableTasks.append(cancellablesTask: parentTask)
        return cancellableTasks
    }
}
