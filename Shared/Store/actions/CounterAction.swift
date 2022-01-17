//
//  CounterAction.swift
//  CombiningReducers (iOS)
//
//  Created by paige on 2022/01/17.
//

import Foundation

struct IncrementAction: Action { }
struct DecrementAction: Action { }
struct IncrementActionAsync: Action { }
struct AddAction: Action {
    let value: Int
}
