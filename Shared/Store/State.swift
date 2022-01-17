//
//  State.swift
//  CombiningReducers (iOS)
//
//  Created by paige on 2022/01/17.
//

import Foundation

struct AppState: ReduxState {
    var counterState = CounterState()
    var taskState = TaskState()
}

struct TaskState: ReduxState {
    var tasks: [Task] = [Task]()
}

struct CounterState: ReduxState {
    var counter = 0
}
