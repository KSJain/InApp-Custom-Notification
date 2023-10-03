//
//  ContentView.swift
//  InApp Custom Notification
//
//  Created by Kartikeya Saxena Jain on 10/3/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Button("Show Notification") {
                    UIApplication.shared.inAppNotification(adaptForDynamicIsland: true,
                                                           timeout: 7,
                                                           swpipeToClose: true) {
                        HStack {
                            Image("ksjain")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(.circle)
                            
                            VStack(alignment: .leading, spacing: 6, content: {
                                Text("K S Jain")
                                    .font(.callout.bold())
                                    .foregroundStyle(.white)
                                
                                Text("Hello There")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            })
                            .padding(.top, 20)
                            
                            Spacer(minLength: 0)
                            
                            Button(action: {}, label: {
                                Image(systemName: "speaker.slash.fill")
                                    .font(.title2)
                            })
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.circle)
                            .tint(.white)
                        }
                        .padding(15)
                        .background {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.black)
                        }
                    }
                }
            }
            .navigationTitle("In App notification")
        }
    }
}

#Preview {
    ContentView()
}
