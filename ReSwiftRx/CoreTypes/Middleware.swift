//
//  Middleware.swift
//  FPExamples
//
//  Created by Charlotte Tortorella on 25/11/16.
//  Copyright © 2016 Charlotte Tortorella. All rights reserved.
//

// swiftlint:disable line_length

public typealias DispatchFunction = (Action) -> Void

public struct Middleware<State: StateType> {
    private let transform: (State, DispatchFunction, Action) -> Action

    public init(_ transform: @escaping (State, DispatchFunction, Action) -> Action) {
        self.transform = transform
    }

    public init(_ first: Middleware<State>, _ rest: Middleware<State>...) {
        self = rest.reduce(first) {
            $0.concat($1)
        }
    }

    public func run(state: State, dispatch: DispatchFunction, argument: Action) -> Action {
        return transform(state, dispatch, argument)
    }

    public func concat(_ other: Middleware<State>) -> Middleware<State> {
        return map(other.transform)
    }

    public func map(_ transform: @escaping (State, DispatchFunction, Action) -> Action) -> Middleware<State> {
        return Middleware<State> {
            transform($0, $1, self.transform($0, $1, $2))
        }
    }

    public func flatMap(_ transform: @escaping (State, DispatchFunction, Action) -> Middleware<State>) -> Middleware<State> {
        return Middleware<State> {
            transform($0, $1, self.transform($0, $1, $2)).transform($0, $1, $2)
        }
    }
}
