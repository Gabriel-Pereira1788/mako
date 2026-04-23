//
//  NetworkFilterPicker.swift
//  Mako
//
//  Filter controls for Network tab
//

import SwiftUI

struct NetworkFilterPicker: View {
    @Bindable var context: FilterContext

    var body: some View {
        methodPicker
    }

    private var methodPicker: some View {
        Picker("Method", selection: Binding(
            get: { context.selectedMethod },
            set: { context.selectedMethod = $0 }
        )) {
            Text("All Methods").tag(nil as String?)
            Divider()
            ForEach(FilterContext.availableMethods, id: \.self) { method in
                Text(method).tag(method as String?)
            }
        }
        .frame(width: 130)
    }
}
