import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: Store
    @EnvironmentObject private var purchaseManager: PurchaseManager

    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingItem: Playdate?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.items) { item in
                        Button {
                            editingItem = item
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(describing: item.childName))
                                    .font(Theme.headlineFont)
                                    .foregroundStyle(Theme.accent)
                                Text(String(describing: item.friendName))
                                    .font(Theme.bodyFont)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .accessibilityIdentifier("row_\(item.id.uuidString)")
                    }
                    .onDelete(perform: store.delete)
                    .listRowBackground(Theme.cardBackground)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Playdate Planner")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("button_settings")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.isAtFreeLimit {
                            showingPaywall = true
                        } else {
                            showingAdd = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("button_add")
                }
            }
            .sheet(isPresented: $showingAdd) {
                EntryFormView(mode: .add)
            }
            .sheet(item: $editingItem) { item in
                EntryFormView(mode: .edit(item))
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

enum FormMode: Equatable {
    case add
    case edit(Playdate)
}

struct EntryFormView: View {
    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss

    let mode: FormMode
    @State private var draft: Playdate

    init(mode: FormMode) {
        self.mode = mode
        switch mode {
        case .add:
            _draft = State(initialValue: Playdate())
        case .edit(let item):
            _draft = State(initialValue: item)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("ChildName", text: $draft.childName)
                    .accessibilityIdentifier("field_childName")
                TextField("FriendName", text: $draft.friendName)
                    .accessibilityIdentifier("field_friendName")
                TextField("Location", text: $draft.location)
                    .accessibilityIdentifier("field_location")
                DatePicker("Date", selection: $draft.date, displayedComponents: .date)
                    .accessibilityIdentifier("field_date")
                TextField("Notes", text: $draft.notes)
                    .accessibilityIdentifier("field_notes")
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle(mode == .add ? "Add" : "Edit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("button_cancel")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        switch mode {
                        case .add:
                            _ = store.add(draft)
                        case .edit:
                            store.update(draft)
                        }
                        dismiss()
                    }
                    .accessibilityIdentifier("button_save")
                }
            }
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
