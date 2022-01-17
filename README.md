# Swift Redux Composition

- state - structs
- actions - structs
- reducers - functions
- store

# Redux

### ReduxRoot

```swift
typealias Dispatcher = (Action) -> Void
typealias Reducer<State: ReduxState> = (_ state: State, _ action: Action) -> State
typealias Middleware<StoreState: ReduxState> = (StoreState, Action, @escaping Dispatcher) -> Void

protocol ReduxState { }

protocol Action { }
```

### Store

```swift
class Store<StoreState: ReduxState>: ObservableObject {

    var reducer: Reducer<StoreState>
    @Published var state: StoreState
    var middlewares: [Middleware<StoreState>]

    init(reducer: @escaping Reducer<StoreState>,
         state: StoreState,
         middlewares: [Middleware<StoreState>] = []) {
        self.reducer = reducer
        self.state = state
        self.middlewares = middlewares
    }

    func dispatch(action: Action) {
        DispatchQueue.main.async {
            self.state = self.reducer(self.state, action)
        }

        // run all middlewares
        middlewares.forEach { middleware in
            middleware(state, action, dispatch)
        }

    }

}
```

### State

```swift
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
```

### Counter, Reducer & Action

- Reducer

```swift
func counterReducer(_ state: CounterState, _ action: Action) -> CounterState {

    var state = state

    switch action {
        case _ as IncrementAction:
            state.counter += 1
        case _ as DecrementAction:
            state.counter -= 1
        case let action as AddAction:
            state.counter += action.value
        default:
            break
    }

    print(state)
    return state
}
```

- Actions

```swift
struct IncrementAction: Action { }
struct DecrementAction: Action { }
struct IncrementActionAsync: Action { }
struct AddAction: Action {
    let value: Int
}
```

### Task, Reducer & Action

- reducer

```swift
func taskReducer(_ state: TaskState, _ action: Action) -> TaskState {

    var state = state

    switch action {
        case let action as AddTaskAction:
            state.tasks.append(action.task)
        default:
            break
    }

    return state
}
```

- action

```swift
struct AddTaskAction: Action {
    let task: Task
}
```

### AppReducer

```swift
func appReducer(_ state: AppState, _ action: Action) -> AppState {

    var state = state
    state.counterState = counterReducer(state.counterState, action)
    state.taskState = taskReducer(state.taskState, action)
    return state
}
```

### Middlewares

- LogMiddleware

```swift
func logMiddleware() -> Middleware<AppState> {
    return { state, action, dispatch in
        print("LOG MIDDLEWARE")
    }
}
```

- IncrementMiddleware

```swift
func incrementMiddleware() -> Middleware<AppState> {
    return { state, action, dispatch in
        switch action {
        case _ as IncrementActionAsync:
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                dispatch(IncrementAction())
            }
        default:
            break
        }
    }
}
```

# Presentation

### App

```swift
@main
struct HelloReduxApp: App {
    var body: some Scene {

        let store = Store(reducer: appReducer, state: AppState(), middlewares: [
            logMiddleware(),
            incrementMiddleware() // This will be invoked when only incrementActionAsync is called
        ])

        WindowGroup {
            ContentView().environmentObject(store)
        }
    }
}
```

### ContentView

```swift
struct ContentView: View {

    @State private var isPresented: Bool = false
    @EnvironmentObject var store: Store<AppState>

    struct Props {
        let counter: Int
        let onIncrement: () -> Void
        let onDecrement: () -> Void
        let onAdd: (Int) -> Void
        let onIncrementAsync: () -> Void
    }

    private func map(state: CounterState) -> Props {
        Props(counter: state.counter, onIncrement: {
            store.dispatch(action: IncrementAction())
        }, onDecrement: {
            store.dispatch(action: DecrementAction())
        }, onAdd: {
            store.dispatch(action: AddAction(value: $0))
        }, onIncrementAsync: {
            store.dispatch(action: IncrementActionAsync())
        })
    }

    var body: some View {

        let props = map(state: store.state.counterState)

        VStack {
            Spacer()

            Text("\(props.counter)")
                .padding()
            Button("Increment") {
                props.onIncrement()
            }
            Button("Decrement") {
                props.onDecrement()
            }
            Button("Add") {
                props.onAdd(100)
            }
            Button("Increment Async") {
                props.onIncrementAsync()
            }

            Spacer()

            Button("Add Task") {
                isPresented = true
            }

            Spacer()
        }.sheet(isPresented: $isPresented, content: {
            AddTaskView()
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {

        let store = Store(reducer: appReducer, state: AppState())
        return ContentView().environmentObject(store)
    }
}
```

### AddTaskView

```swift
import SwiftUI

struct AddTaskView: View {

    @EnvironmentObject var store: Store<AppState>
    @State private var name: String = ""

    struct Props {

        // props
        let tasks: [Task]
        // dispatch
        let onTaskAdded: (Task) -> ()
    }

    private func map(state: TaskState) -> Props {
        return Props(tasks: state.tasks, onTaskAdded: { task in
            store.dispatch(action: AddTaskAction(task: task))
        })
    }

    var body: some View {

        let props = map(state: store.state.taskState)

        return VStack {
            TextField("Enter task", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Add") {
                let task = Task(title: self.name)
                props.onTaskAdded(task)
            }

            List(props.tasks, id: \.id) { task in
                Text(task.title)
            }

            Spacer()
        }.padding()
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {

        let store = Store(reducer: appReducer, state: AppState())
        return AddTaskView().environmentObject(store)
    }
}
```
