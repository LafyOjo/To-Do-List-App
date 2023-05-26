//
//  TaskDetailsView.swift
//  To-Do-List-App
//
//  Created by Isaiah Ojo on 26/04/2023.
//

import Foundation
import SwiftUI

struct TaskDetailsView: View {
    @Binding var task: Task
    
    @State private var showingTagSelection = false
    @State private var showingCategorySelection = false
    
    private var selectedTagsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(task.tags) { tag in
                    Text(tag.name)
                        .padding(4)
                        .background(tag.color.opacity(0.2))
                        .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(tag.color, lineWidth: 1)
                        )
                }
                Button(action: {
                    showingTagSelection = true
                }) {
                    Image(systemName: "tag")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.2))
                        .cornerRadius(4)
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            TextField("Task Name", text: $task.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .font(.largeTitle)
            
            Toggle(isOn: $task.isCompleted){
                Text("Completed")
                    .font(.title)
            }
            .padding()
            
            DatePicker("Due Date", selection: $task.dueDate, displayedComponents: [.date])
                .padding()
                .datePickerStyle(CompactDatePickerStyle())
            
            DatePicker("Reminder", selection: Binding<Date>(
                get: { task.reminder ?? Date() },
                set: { newValue in task.reminder = newValue }),
                       displayedComponents: [.date, .hourAndMinute])
            .padding()
            .datePickerStyle(CompactDatePickerStyle())
            
            Button(action: {
                showingCategorySelection = true
            }) {
                HStack {
                    Text("Category")
                    Spacer()
                    if let category = task.category {
                        Text(category.name)
                    }
                }
            }
            .sheet(isPresented: $showingCategorySelection) {
                CategorySelectionView(selectedCategory: $task.category)
            }
            .padding()
            
            Spacer()
        }
        Picker("Priority", selection: $task.priority) {
            ForEach(Priority.allCases) { priority in
                Text(priority.rawValue).tag(priority)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .padding()
        
        .navigationTitle("Task Details")
        
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    showingTagSelection = true
                }) {
                    Text("Edit Tags")
                }
            }
        }
        .sheet(isPresented: $showingTagSelection) {
            TagSelectionView(selectedTags: $task.tags)
        }
        .padding()
        
        selectedTagsView
            .padding(.horizontal)
    }
}
