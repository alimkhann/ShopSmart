//
//  ShoppingListView.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 26/4/2025.
//

import SwiftUI

struct ShoppingListRowView: View {
    @ObservedObject var vm: ShoppingListRowViewModel
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Text(vm.emoji)
                .font(.system(size: 36))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(vm.name)
                    .font(.system(size: 17, weight: .semibold))
                
                HStack(alignment: .center, spacing: 4) {
                    Text(dateFormatter.string(from: vm.date ?? Date()))
                        .font(.system(size: 12))
                    
                    Text("•")
                        .font(.system(size: 12))
                    
                    Text("\(vm.nOfItems) items")
                        .font(.system(size: 12))
                    
                    //                    Text("•")
                    //                        .font(.system(size: 12))
                    //
                    //                    HStack(alignment: .center, spacing: -8) {
                    //                        ForEach(vm.collaboratorAvatars, id: \.self) { url in
                    //                            AsyncImage(url: url) { img in
                    //                                img.resizable()
                    //                                    .frame(width:32, height:32)
                    //                                    .clipShape(Circle())
                    //                            } placeholder: {
                    //                                Circle().fill(Color.gray).frame(width:32, height:32)
                    //                            }
                    //                            .frame(width:24, height:24)
                    //                            .clipShape(Circle())
                    //                        }
                    //                    }
                    //                    .padding(0)
                }
            }
            
            Spacer()
            
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.primary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(red: 0.94, green: 0.94, blue: 0.94).opacity(0.5))
            .cornerRadius(4)
            
        }
        .padding(.leading, 4)
        .padding(.trailing, 8)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 2)
        .errorAlert($vm.errorMessage)
    }
}
