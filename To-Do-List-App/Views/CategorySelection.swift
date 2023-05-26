//
//  CategorySelection.swift
//  To-Do-List-App
//
//  Created by Isaiah Ojo on 26/04/2023.
//

import Foundation
import SwiftUI

struct CategorySelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var selectedCategory: Category?
    
    let categories: [Category] = [
        Category(name: "Personal", systemName: "person.fill", color: .blue),
        Category(name: "Work", systemName: "briefcase.fill", color: .green),
        Category(name: "Family", systemName: "house.fill", color: .purple),
        Category(name: "Shopping", systemName: "cart.fill", color: .orange)
    ]
    
    var body: some View {
        NavigationView {
            List(categories) { category in
                Button(action: {
                    selectedCategory = category
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(category.name)
                        Spacer()
                        if category == selectedCategory {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Categories")
        }
    }
}
