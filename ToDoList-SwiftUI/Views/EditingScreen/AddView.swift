//
//  AddView.swift
//  ToDoList-SwiftUI
//
//  Created by Alexey Shestakov on 19.07.2023.
//

import SwiftUI

struct AddView: View {
    
    // MARK: PROPERTIES
    
    @Binding var todoItem: TodoItem?
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var listViewModel: ListViewModel
    
    @State private var disableButtons = true
    @State private var selectedSegment = 1
    
    @State private var isSwitchOn = false
    @State private var deadlineShown = false
    @State private var showCalendar = false
    
    
    
    @State var text: String?
    
    var importance: Importance {
        get {
            switch selectedSegment {
            case 0: return Importance.unimportant
            case 1: return Importance.normal
            case 2: return Importance.important
            default:
                return Importance.normal
            }
        }
    }
    
    @State private var deadline: Date?
    
    func configureProperties() {
        guard let todoItem else {return}
        text = todoItem.text
        switch todoItem.importance {
        case .unimportant:
            selectedSegment = 0
        case .normal:
            selectedSegment = 1
        case .important:
            selectedSegment = 2
        }
        deadline = todoItem.deadline
        guard deadline != nil else {return}
        isSwitchOn = true
        deadlineShown = true
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16.0) {
                    TextField("Что надо сделать?", text: $text.bound, axis: .vertical)
                        .lineLimit(5...)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .font(.system(size: 17))
                        .onChange(of: text, perform: { _ in
                            guard text != nil else {
                                disableButtons = true
                                return
                            }
                            disableButtons = false
                        })
                        .onTapGesture {
                            hideKeyboard()
                        }
                    
                    VStack() {
                        HStack {
                            Text("Важность")
                            Spacer()
                            Picker("", selection: $selectedSegment) {
                                Image("Arrow").tag(0)
                                Text("нет").tag(1)
                                Image("Importance").tag(2)
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 150, height: 36)
                            .cornerRadius(9)
                            
                            .onChange(of: selectedSegment) { newValue in
                                guard text != nil else {
                                    disableButtons = true
                                    return
                                }
                                disableButtons = false
                            }
                        }
                        Divider()
                        HStack {
                                VStack(alignment: .leading) {
                                Text("Сделать до")
                                if deadlineShown {
                                    Text(provideDeadline().stringFromDate())
                                        .font(.system(size: 13))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                        .onTapGesture {
                                            showCalendar = true
                                            deadline = provideDeadline()
                                        }
                                }
                            }
                            Toggle("", isOn: $isSwitchOn)
                                .onChange(of: isSwitchOn) { newValue in
                                    if newValue {
                                        deadlineShown = true
                                        deadline = Date().offsetDays(days: 1)
                                    } else {
                                        deadlineShown = false
                                        deadline = nil
                                    }
                                    guard text != nil else {
                                        disableButtons = true
                                        return
                                    }
                                    disableButtons = false
                                }
                        }
                        
                        if showCalendar {
                            
                            Divider()
                            DatePicker("",
                                       selection: $deadline.bound,
                                       in: Date()...,
                                       displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .environment(\.locale, Locale.init(identifier: "ru"))
                            .onChange(of: deadline) { newValue in
                                guard text != nil else {
                                    disableButtons = true
                                    return
                                }
                                disableButtons = false
                            }
                        }
                    }
                    .padding(.all, 16)
                    .background(Color.white)
                    .cornerRadius(16)
                    
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Удалить")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, minHeight: 56)
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                }
                .padding( .all, 16)
            }
            .background(Color(ColorAdditional.specialBackground))
            .navigationTitle("Дело")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        saveButtonPressed()
                    } label: {
                        Text("Сохранить")
                            .bold()
                    }
                    .disabled(disableButtons)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отменить") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear{self.configureProperties()}
    }
    
    private func provideDeadline() -> Date {
        if let deadline {
            return deadline
        }
        return Date().offsetDays(days: 1)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    
    func saveButtonPressed() {
        guard let text else {return}
        if todoItem == nil {
            let item = TodoItem(text: text,
                                importance: importance,
                                deadline: deadline,
                                done: false,
                                dateCreation: Date().localDate(),
                                dateChanging: Date().localDate())
            listViewModel.addItem(todoItem: item)
        } else {
            guard let todoItem else {return}
            let item = TodoItem(id: todoItem.id,
                                text: text,
                                importance: importance,
                                deadline: deadline,
                                done: false,
                                dateCreation: todoItem.dateCreation,
                                dateChanging: Date().localDate())
            listViewModel.updateItem(todoItem: item)
            print(item)
        }
        presentationMode.wrappedValue.dismiss()
    }
}
