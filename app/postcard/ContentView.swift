//
//  ContentView.swift
//  postcard
//
//  Created by Ashwin Agarwal on 5/20/23.
//

import SwiftUI

struct ContentView: View {
    @Binding var thisFridge: Fridge?
    @EnvironmentObject var dataManager: DataManager
    @State private var fridgeNumber: String = ""
    @State private var fridgeName: String = ""
    @State private var currentMessage: Message? = nil

    var login: some View {
        VStack() {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Let's login!")
            TextField(
                "Fridge Phone Number", text: $fridgeNumber
            )
            .keyboardType(.numberPad)
            Button("Submit") {
                dataManager.findThisFridge(fridgeNumber: fridgeNumber)
            }
        }
        .padding()
    }

    var chooseName: some View {
        VStack() {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Let's name your fridge!")
            TextField(
                "Fridge Name", text: $fridgeName
            )
            Button("Submit") {
                thisFridge!.fridgeName = fridgeName
                dataManager.updateThisFridge()
            }
        }
        .padding()
    }

    var itemView: some View {
        VStack() {
            let message = currentMessage!
            HStack() {
                Image(dataManager.getImageString(id: message.id, open: true))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                if (message.senderName != nil) {
                    Text(message.senderName!)
                }
            }
            .frame(height: 100)
            Text(message.note)
            WebView(url: URL(string: message.link)!)
                .border(.black)
                .padding()
            Button {
                dataManager.markMessageRead(message: message)
                currentMessage = nil
            } label: {
                Text("Toss Out")
            }
        }
    }

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()
            if (currentMessage != nil) {
                itemView
            } else if thisFridge == nil {
                login
            } else if thisFridge!.fridgeName.isEmpty {
                chooseName
            } else {
                // Main screen
                VStack(alignment: .leading) {
                    Text("\(thisFridge!.fridgeName) Shelf".uppercased())
                        .foregroundColor(Color("AppBlack"))
                        .font(.custom("Futura-CondensedExtraBold", size: 30))
//                    Button {
//                        dataManager.fetchNewMessages()
//                    } label: {
//                        Image(systemName: "arrow.clockwise.circle.fill")
//                    }
                    let freshMessages = dataManager.messages.filter { Calendar.current.isDateInToday($0.createdAt) }
                    let staleMessages = dataManager.messages.filter { !Calendar.current.isDateInToday($0.createdAt) }
                    
                    Image("fresh").resizable().aspectRatio(contentMode: .fit).frame(height:25)
                    Shelf(messages: freshMessages, borderColor: Color("AppGreen"), currentMessage: $currentMessage)
                    Image("stale").resizable().aspectRatio(contentMode: .fit).frame(height:25)
                    Shelf(messages: staleMessages, borderColor: Color("AppOrange"), currentMessage: $currentMessage)
                }
                .padding()
                .onAppear {
                    dataManager.fetchNewMessages()
                    Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { _ in
                        dataManager.fetchNewMessages()
                    })
                }
            }
        }
    }
}

struct Shelf: View {
    let messages: [Message]
    let borderColor: Color
    @EnvironmentObject var dataManager: DataManager
    @Binding var currentMessage: Message?

    var body: some View {
        ScrollView(.horizontal) {
            HStack() {
                ForEach(messages, id: \.id) { message in
                    Button {
                        currentMessage = message
                    } label: {
                        VStack() {
                            Image(dataManager.getImageString(id: message.id, open: false))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            let formattedDate = message.createdAt.formatted(Date.FormatStyle()
                                .month(.twoDigits)
                                .day(.twoDigits)
                            )
                            TapeLabel(text: message.senderName != nil ? message.senderName! + " · " + formattedDate : "No name · " + formattedDate)
                        }
                    }
                    .frame(width: 90, height: 90)
                    .padding(5)
                    .background(RoundedRectangle(cornerRadius: 10).stroke(borderColor, lineWidth: 2))
                }
            }
            .frame(height: 100)
            .padding(5)
        }
    }
}

struct TapeLabel: View {
    let text: String
    var body: some View {
        Text(text)
            .foregroundColor(Color("AppBlack"))
            .font(.system(size: 10))
//            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    @StateObject static private var dataManager = DataManager()
    static var previews: some View {
        ContentView(thisFridge: $dataManager.thisFridge).environmentObject(dataManager)
    }
}
