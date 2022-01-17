//
//  LogMiddleware.swift
//  CombiningReducers (iOS)
//
//  Created by paige on 2022/01/17.
//

import Foundation

func logMiddleware() -> Middleware<AppState> {
    return { state, action, dispatch in
        print("LOG MIDDLEWARE")
    }
}
