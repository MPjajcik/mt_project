//
//  ContentView.swift
//  mt_project
//
//  Created by Pjajčík Marián on 02.01.2021.
//

import SwiftUI

struct Joke: Codable, Identifiable {
    public var id: Int
    public var setup: String
    public var punchline: String
}

class FetchJoke: ObservableObject {
    @Published var jokes = [Joke]()
    @Published var loaded: Bool
    
    init() {
        self.loaded = false
        let url = URL(string: "https://official-joke-api.appspot.com/random_ten")!
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                if let jokeData = data {
                    let decodedData = try JSONDecoder().decode([Joke].self, from: jokeData)
                    DispatchQueue.main.async {
                        self.jokes = decodedData
                        self.loaded = true
                    }
                } else {
                    print("No data")
                }
            } catch {
                print("Error")
            }
        }.resume()
    }
    
    func getJokes() {
        self.loaded = false
        let url = URL(string: "https://official-joke-api.appspot.com/random_ten")!
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                if let jokeData = data {
                    let decodedData = try JSONDecoder().decode([Joke].self, from: jokeData)
                    DispatchQueue.main.async {
                        self.jokes = decodedData
                        self.loaded = true
                    }
                } else {
                    print("No data")
                }
            } catch {
                print("Error")
            }
        }.resume()
    }
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 0)
    }
    
}

struct ProductCard: View {
    var setup: String
    var punchline: String
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text(setup)
                    .font(.system(size: 26, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding()
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                    Text(punchline)
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                    Button(action: {
                        
                    }) {
                        Image(systemName: "heart.fill")
                    }.foregroundColor(.white)
                    .padding(7)
                    .background(Color.red)
                    .cornerRadius(8)
                })
                
            }.padding(.trailing, 20)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color(red: 32/255, green: 36/255, blue: 38/255))
        .modifier(CardModifier())
        .padding(10)
    }
}

class UserSettings: ObservableObject {
    @Published var username: String {
        didSet {
            UserDefaults.standard.set(username, forKey: "username")
        }
    }
    
    init() {
        self.username = UserDefaults.standard.object(forKey: "username") as? String ?? ""
    }
}

struct ContentView: View {
    
    @ObservedObject var fetchJoke = FetchJoke()
    @ObservedObject var userSettings = UserSettings()
    
    var body: some View {
        VStack(alignment: .center, content: {
            Image("jokefylogo");
            Spacer()
            Text("Hi \(userSettings.username)")
                .font(.headline);
            TextField("Enter your name", text: $userSettings.username).textFieldStyle(RoundedBorderTextFieldStyle()).padding()
            
            TabView {
                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                    Button(action: {
                        fetchJoke.getJokes()
                    }) {
                        Text("Refresh Jokes")
                    }.foregroundColor(.white)
                    .padding(7)
                    .background(Color.red)
                    .cornerRadius(8)
                    Group{
                        if fetchJoke.loaded == false {
                            ProgressView()
                        } else {
                            List(fetchJoke.jokes) { item in
                                VStack(alignment: .leading) {
                                    ProductCard(setup: item.setup, punchline: item.punchline)
                                }
                            }
                        }
                        
                    }
                })
                
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Jokes")
                }
                Text("Here will be your saved jokes")
                    .tabItem {
                        Image(systemName: "heart.fill")
                        Text("Saved Jokes")
                    }
            }
        })
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
