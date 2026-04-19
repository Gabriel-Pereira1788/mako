# MVVM Architecture - Mako

## Overview

This document describes the modular MVVM architecture implemented in Mako, a macOS app for debugging React Native applications. Use this guide as a reference to maintain consistency when adding new features or modifying existing code.

---

## Directory Structure

```
Mako/
├── App/                          # Entry point and root views
│   ├── MakoApp.swift             # @main - app configuration
│   ├── MainView.swift            # Root view with main layout
│   └── RightSidebarView.swift    # Quick actions sidebar
│
├── Common/                       # Shared code between modules
│   ├── Models/                   # Data models (SwiftData, enums)
│   ├── Services/                 # Infrastructure services
│   ├── Extensions/               # UI extensions for domain types
│   ├── UI/                       # Reusable UI components
│   └── Utilities/                # Utility functions
│
└── Modules/                      # Feature modules
    ├── Logs/
    │   ├── Views/
    │   └── ViewModels/
    ├── Network/
    │   ├── Views/
    │   └── ViewModels/
    ├── Workspace/
    │   ├── Views/
    │   ├── ViewModels/
    │   └── Models/               # Module-specific models
    └── Devices/
        ├── Views/
        └── ViewModels/
```

---

## Patterns and Conventions

### 1. ViewModels

**Location:** `Modules/{Feature}/ViewModels/{Feature}ViewModel.swift`

**Required pattern:**

```swift
import Foundation
import Observation

@MainActor
@Observable
final class {Feature}ViewModel {
    // MARK: - Dependencies
    private let someService: SomeService

    // MARK: - State
    var searchText = ""
    var selectedItem: Item?

    // MARK: - Computed Properties
    var filteredItems: [Item] {
        // Filter logic here
    }

    var hasItems: Bool { !items.isEmpty }

    // MARK: - Init
    init(someService: SomeService) {
        self.someService = someService
    }

    // MARK: - Actions
    func selectItem(_ item: Item) {
        selectedItem = item
    }

    func clearFilters() {
        searchText = ""
    }
}
```

**Rules:**
- Always use `@MainActor` to ensure main thread execution
- Always use `@Observable` (not `ObservableObject`)
- Always use `final class` (not struct)
- All business logic belongs in the ViewModel, **never in the View**
- ViewModels don't import SwiftUI (except when necessary for types like `Color`)

---

### 2. Views

**Location:** `Modules/{Feature}/Views/{Feature}View.swift`

**Required pattern:**

```swift
import SwiftUI

struct {Feature}View: View {
    @Bindable var viewModel: {Feature}ViewModel

    var body: some View {
        VStack {
            // Main layout
        }
    }

    // MARK: - Subviews

    private var someSubview: some View {
        // Extracted subview for clarity
    }

    @ViewBuilder
    private var conditionalSubview: some View {
        if viewModel.hasItems {
            // Conditional content
        }
    }
}

#Preview {
    {Feature}View(viewModel: {Feature}ViewModel(...))
}
```

**Rules:**
- Use `@Bindable` for two-way binding with `@Observable` ViewModels
- Views are **purely declarative** - no business logic
- Extract subviews as `private var` for clarity
- Use `@ViewBuilder` for conditional subviews
- Always include `#Preview` for development

---

### 3. Container Views (SwiftData Query)

**Location:** `Modules/{Feature}/Views/{Feature}ContainerView.swift`

**Purpose:** Perform SwiftData query and instantiate the ViewModel.

```swift
import SwiftUI
import SwiftData

struct {Feature}ContainerView: View {
    let device: Device?

    @Query private var allItems: [Item]

    private var filteredItems: [Item] {
        guard let device else { return [] }
        return allItems.filter { $0.device?.id == device.id }
            .sorted { $0.timestamp > $1.timestamp }
    }

    var body: some View {
        {Feature}View(viewModel: {Feature}ViewModel(
            items: filteredItems,
            deviceName: device?.name
        ))
    }
}

// Type alias for compatibility
typealias {Feature}ContentView = {Feature}ContainerView
```

**Rules:**
- Responsible only for query and instantiation
- Contains no UI logic
- Add `typealias` if renaming from existing files

---

### 4. Models

**Location:**
- `Common/Models/` - Shared models (Device, LogEntry, NetworkEntry)
- `Modules/{Feature}/Models/` - Module-specific models

**SwiftData Models:**

```swift
import Foundation
import SwiftData

@Model
final class SomeModel {
    @Attribute(.unique) var id: String
    var name: String
    var timestamp: Date

    @Relationship(deleteRule: .cascade, inverse: \OtherModel.parent)
    var children: [OtherModel] = []

    init(id: String, name: String, timestamp: Date = .now) {
        self.id = id
        self.name = name
        self.timestamp = timestamp
    }
}
```

**Domain enums:**

```swift
// Common/Models/LogLevel.swift
import Foundation

enum LogLevel: String, Codable, CaseIterable {
    case debug
    case info
    case warn
    case error
}
```

**Rules:**
- Domain enums belong in `Common/Models/`
- Enums should NOT have UI properties (Color, icon) - use Extensions
- SwiftData models use `@Model` and `final class`

---

### 5. UI Extensions

**Location:** `Common/Extensions/{Type}+UI.swift`

**Purpose:** Separate presentation logic from domain types.

```swift
// Common/Extensions/LogLevel+UI.swift
import SwiftUI

extension LogLevel {
    var color: Color {
        switch self {
        case .debug: return .secondary
        case .info: return .blue
        case .warn: return .orange
        case .error: return .red
        }
    }

    var icon: String {
        switch self {
        case .debug: return "ladybug"
        case .info: return "info.circle"
        case .warn: return "exclamationmark.triangle"
        case .error: return "xmark.circle"
        }
    }
}
```

**Static helpers:**

```swift
// Common/Extensions/HTTPStatusCode+UI.swift
import SwiftUI

enum HTTPStatusCode {
    static func color(for code: Int?) -> Color {
        guard let code else { return .gray }
        switch code {
        case 200..<300: return .green
        case 300..<400: return .blue
        case 400..<500: return .orange
        case 500..<600: return .red
        default: return .gray
        }
    }
}
```

**Rules:**
- Always create in a separate file with `+UI` suffix
- Import `SwiftUI` only in extension files
- Use `enum` without cases for static helpers

---

### 6. Services

**Location:** `Common/Services/{ServiceName}.swift`

**Pattern:**

```swift
import Foundation
import Observation

@MainActor
@Observable
final class SomeService {
    private let dependency: SomeDependency

    // Observable state
    var isRunning = false
    var lastError: String?

    init(dependency: SomeDependency) {
        self.dependency = dependency
    }

    func start() {
        // Implementation
    }

    func stop() {
        // Implementation
    }
}
```

**Rules:**
- Services use `@MainActor @Observable`
- Services are injected via initializer, not `@Environment`
- Services live at the App level (MainView)

---

### 7. Utilities

**Location:** `Common/Utilities/{UtilityName}.swift`

```swift
// Common/Utilities/JSONFormatter.swift
import Foundation

enum JSONFormatter {
    static func format(_ string: String) -> String {
        guard let data = string.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data),
              let formatted = try? JSONSerialization.data(
                  withJSONObject: json,
                  options: .prettyPrinted
              ),
              let result = String(data: formatted, encoding: .utf8) else {
            return string
        }
        return result
    }
}
```

**Rules:**
- Use `enum` without cases for static function namespacing
- Functions should be pure (no side effects)
- Don't depend on global state

---

## Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                          MainView                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │   Services   │  │  @State UI   │  │  WorkspaceViewModel  │  │
│  │ (WebSocket,  │  │ (selection,  │  │  (panels, tabs)      │  │
│  │  LogStore)   │  │  sidebar)    │  │                      │  │
│  └──────┬───────┘  └──────────────┘  └──────────┬───────────┘  │
│         │                                        │              │
│         ▼                                        ▼              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                     HSplitView                            │  │
│  │  ┌─────────────┐  ┌─────────────────┐  ┌──────────────┐  │  │
│  │  │DeviceList   │  │  WorkspaceView  │  │RightSidebar  │  │  │
│  │  │View         │  │                 │  │View          │  │  │
│  │  └─────────────┘  └────────┬────────┘  └──────────────┘  │  │
│  │                            │                              │  │
│  │                            ▼                              │  │
│  │               ┌────────────────────────┐                  │  │
│  │               │      PanelView         │                  │  │
│  │               │  ┌──────────────────┐  │                  │  │
│  │               │  │{Feature}Container│  │                  │  │
│  │               │  │     View         │  │                  │  │
│  │               │  │  ┌────────────┐  │  │                  │  │
│  │               │  │  │  @Query    │  │  │                  │  │
│  │               │  │  │    │       │  │  │                  │  │
│  │               │  │  │    ▼       │  │  │                  │  │
│  │               │  │  │ ViewModel  │  │  │                  │  │
│  │               │  │  │    │       │  │  │                  │  │
│  │               │  │  │    ▼       │  │  │                  │  │
│  │               │  │  │ {Feature}  │  │  │                  │  │
│  │               │  │  │   View     │  │  │                  │  │
│  │               │  │  └────────────┘  │  │                  │  │
│  │               │  └──────────────────┘  │                  │  │
│  │               └────────────────────────┘                  │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Naming Conventions

### Files

| Type | Pattern | Example |
|------|---------|---------|
| ViewModel | `{Feature}ViewModel.swift` | `LogsViewModel.swift` |
| Main View | `{Feature}View.swift` | `LogsView.swift` |
| Container View | `{Feature}ContainerView.swift` | `LogsContainerView.swift` |
| Row View | `{Feature}RowView.swift` | `LogRowView.swift` |
| Detail View | `{Feature}DetailView.swift` | `NetworkDetailView.swift` |
| UI Extension | `{Type}+UI.swift` | `LogLevel+UI.swift` |

### Classes and Structs

| Type | Pattern | Example |
|------|---------|---------|
| ViewModel | `{Feature}ViewModel` | `LogsViewModel` |
| SwiftData Model | `{Entity}` | `LogEntry`, `Device` |
| Enum | `{Concept}` | `LogLevel`, `TabType` |
| Service | `{Responsibility}Service/Manager/Store` | `DeviceManager`, `LogStore` |

---

## Decision Rules

### Where to place a new file?

```
Is it shared between modules?
├── YES → Common/
│   ├── Is it a data model? → Common/Models/
│   ├── Is it a service? → Common/Services/
│   ├── Is it a UI extension? → Common/Extensions/
│   ├── Is it a reusable UI component? → Common/UI/
│   └── Is it a utility function? → Common/Utilities/
│
└── NO → Modules/{Feature}/
    ├── Is it a View? → Modules/{Feature}/Views/
    ├── Is it a ViewModel? → Modules/{Feature}/ViewModels/
    └── Is it a module-specific Model? → Modules/{Feature}/Models/
```

### When to create a ViewModel?

**CREATE a ViewModel if the View has:**
- Filter/search logic
- Selection state
- Computed properties derived from data
- Actions that modify state

**DON'T create a ViewModel if the View is:**
- Purely presentational (Row, Item views)
- A simple wrapper (Container views)
- A reusable component (ActionButton)

---

## New Feature Checklist

### New Module

- [ ] Create folder `Modules/{Feature}/`
- [ ] Create subfolders `Views/` and `ViewModels/`
- [ ] Create `{Feature}ViewModel.swift` with `@MainActor @Observable` pattern
- [ ] Create `{Feature}View.swift` with `@Bindable var viewModel`
- [ ] Create `{Feature}ContainerView.swift` if using SwiftData
- [ ] Add preview to all Views

### New Model

- [ ] If shared → `Common/Models/`
- [ ] If module-specific → `Modules/{Feature}/Models/`
- [ ] If enum with UI → create extension in `Common/Extensions/`

### New UI Extension

- [ ] Create file `{Type}+UI.swift` in `Common/Extensions/`
- [ ] Import only `SwiftUI`
- [ ] Remove UI properties from the original type

---

## Implementation Examples

### Adding a new filter to LogsViewModel

```swift
// In LogsViewModel.swift

// 1. Add state
var minLogLevel: LogLevel?

// 2. Update computed property
var filteredLogs: [LogEntry] {
    logs.filter { entry in
        let matchesSearch = searchText.isEmpty ||
            entry.message.localizedStandardContains(searchText)
        let matchesLevel = selectedLevel == nil ||
            entry.logLevel == selectedLevel
        let matchesMinLevel = minLogLevel == nil ||
            entry.logLevel.severity >= minLogLevel!.severity
        return matchesSearch && matchesLevel && matchesMinLevel
    }
}

// 3. Add action
func setMinLogLevel(_ level: LogLevel?) {
    minLogLevel = level
}
```

### Adding a picker to LogsView

```swift
// In LogsView.swift

// Use the viewModel state
Picker("Min Level", selection: $viewModel.minLogLevel) {
    Text("All").tag(nil as LogLevel?)
    ForEach(LogLevel.allCases, id: \.self) { level in
        Text(level.rawValue.capitalized).tag(level as LogLevel?)
    }
}
```

---

## Anti-Patterns to Avoid

### ❌ Business logic in the View

```swift
// WRONG
struct LogsView: View {
    let logs: [LogEntry]
    @State var searchText = ""

    var filteredLogs: [LogEntry] {  // ❌ Should be in ViewModel
        logs.filter { $0.message.contains(searchText) }
    }
}
```

### ❌ UI properties in domain enums

```swift
// WRONG
enum LogLevel: String {
    case error

    var color: Color {  // ❌ Should be in LogLevel+UI.swift
        .red
    }
}
```

### ❌ ViewModel depending on View

```swift
// WRONG
class LogsViewModel {
    func updateUI() {  // ❌ ViewModel should not know about the View
        someView.refresh()
    }
}
```

### ❌ Using @StateObject with @Observable

```swift
// WRONG
struct SomeView: View {
    @StateObject var viewModel: SomeViewModel  // ❌ Use @State or @Bindable
}

// CORRECT for @Observable
struct SomeView: View {
    @Bindable var viewModel: SomeViewModel  // ✅
}
```

---

## References

- [Swift Observation Framework](https://developer.apple.com/documentation/observation)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [SwiftUI Data Flow](https://developer.apple.com/documentation/swiftui/model-data)

---

## History

| Date | Change |
|------|--------|
| 2026-04-12 | Initial creation of modular MVVM architecture |
| 2026-04-19 | Translated to English |
