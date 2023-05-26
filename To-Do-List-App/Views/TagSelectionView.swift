//
//  TagSelectionView.swift
//  To-Do-List-App
//
//  Created by Isaiah Ojo on 26/04/2023.
//

import Foundation
import SwiftUI

struct TagSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var taskListViewModel: TaskListViewModel
    
    @Binding var selectedTags: [Tag]
    
    @State private var newTagName = ""
    @State private var newTagColor = Color.red
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Create New Tag")) {
                        HStack {
                            TextField("Tag Name", text: $newTagName)
                            
                            Spacer()
                            
                            ColorPicker("Tag Color", selection: $newTagColor)
                                .labelsHidden()
                        }
                        Button(action: {
                            if !newTagName.isEmpty {
                                let newTag = Tag(name: newTagName, color: newTagColor)
                                taskListViewModel.tags.append(newTag)
                                newTagName = ""
                                newTagColor = .red
                            }
                        }) {
                            Text("Add Tag")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    
                    Section(header: Text("Available Tags")) {
                        ForEach(taskListViewModel.tags) { tag in
                            Button(action: {
                                if let index = selectedTags.firstIndex(of: tag) {
                                    selectedTags.remove(at: index)
                                } else {
                                    selectedTags.append(tag)
                                }
                            }) {
                                HStack {
                                    Text(tag.name)
                                    Spacer()
                                    Circle()
                                        .fill(selectedTags.contains(tag) ? Color.clear : tag.color)
                                        .frame(width: 16, height: 16)
                                    if selectedTags.contains(tag) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .navigationTitle("Tags")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
    }
}
