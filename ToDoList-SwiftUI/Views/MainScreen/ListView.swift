//
//  ListView.swift
//  ToDoList-SwiftUI
//
//  Created by Alexey Shestakov on 19.07.2023.
//

import SwiftUI

struct ListView: View {
    
    @EnvironmentObject var listViewModel: ListViewModel
    
    @State private var itemSelected: TodoItem? = nil
    
    @State private var isPresented = false
    
    @State private var onlyCompleted = false
    
    var body: some View {
        ZStack {
            List {
                Section {
                    ForEach(Array(listViewModel.items.enumerated()), id: \.element) { index, item in
                        ListRowView(item: item)
                            .onTapGesture {
                                itemSelected = listViewModel.items[index]
                                isPresented = true
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button(action: {
                                    listViewModel.makeDoneUndone(todoItem: item)
                                }) {
                                    Label("", systemImage: "checkmark.circle")
                                }
                                .tint(.green)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(action: {
                                    listViewModel.deleteItem(todoItem: item, index: index)
                                }) {
                                    Label("", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                            .contentShape(Rectangle())
                    }
                    .onMove(perform: listViewModel.moveItem)
                    .listRowBackground(Color.white)
                    Button("Новое") {
                        itemSelected = nil
                        isPresented = true
                    }
                    .frame(height: 40)
                    .foregroundColor(.gray)
                    .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 0))
                } header: {
                    HStack {
                        Text("Выполнено: \(listViewModel.countDone())")
                        Spacer()
                        Button(action: {
                            onlyCompleted = !onlyCompleted
                            if onlyCompleted {
                                listViewModel.filterArray(typeSorting: .onlyNotDone)
                            } else {
                                listViewModel.filterArray(typeSorting: .none)
                            }
                        }) {
                            Text(onlyCompleted ? "Все" : "Несделанные")
                        }
                    }
                    .textCase(nil)
                }
            }
            .navigationTitle("Todo List")
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color(ColorAdditional.specialBackground))
            VStack {
                Spacer()
                Button(action: {
                    itemSelected = nil
                    isPresented = true
                }) {
                    Image("Add")
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
                .padding(12)
                .cornerRadius(50)
                .padding(.bottom, 12)
                .shadow(radius: 10)
            }
        }
        .sheet(isPresented: $isPresented, content: {
            AddView(todoItem: $itemSelected)
        })
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ListView()
        }
        .environmentObject(ListViewModel())
    }
}

