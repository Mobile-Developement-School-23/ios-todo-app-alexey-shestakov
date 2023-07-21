//
//  ListRowView.swift
//  ToDoList-SwiftUI
//
//  Created by Alexey Shestakov on 19.07.2023.
//

import SwiftUI

struct ListRowView: View {
    
    @EnvironmentObject var listViewModel: ListViewModel
    
    let item: TodoItem
    
    var body: some View {
        VStack {
            HStack(spacing: 15) {
                Image(systemName: item.done ? "checkmark.circle" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(item.done ? .green : .red)
                    .onTapGesture {
                        listViewModel.makeDoneUndone(todoItem: item)
                    }
                if item.importance == .important {
                    Image("Importance")
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text(item.text)
                        .font(.title3)
                        .lineLimit(3)
                        .foregroundColor(item.done ? .gray : .black)
                        .strikethrough(item.done, color: .gray)
                    if let deadline = item.deadline {
                         HStack {
                             Image("Calendar")
                             Text(deadline.stringFromDateShort())
                                 .font(.footnote)
                                 .foregroundColor(.gray)
                         }
                    }
                }
            }
        }
        .frame(minHeight: 60)
    }
}
