//
//  ReduxRoot.swift
//  CombiningReducers (iOS)
//
//  Created by paige on 2022/01/17.
//

import Foundation

typealias Dispatcher = (Action) -> Void
typealias Reducer<State: ReduxState> = (_ state: State, _ action: Action) -> State
typealias Middleware<StoreState: ReduxState> = (StoreState, Action, @escaping Dispatcher) -> Void

protocol ReduxState { }

protocol Action { }
