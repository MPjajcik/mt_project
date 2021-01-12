//
//  ContentView.swift
//  mt_project
//
//  Created by Pjajčík Marián on 02.01.2021.
//

import SwiftUI

struct Joke: Codable, Identifiable {
    public var id: Int
    public var type: String
    public var setup: String
    public var punchline: String
}

class FetchJoke: ObservableObject {
    @Published var jokes = [Joke]()
    @Published var selectedType: Int = 0
    @Published var loaded: Bool
    @ObservedObject var userSettings = UserSettings()
    public var url = URL(string: "https://official-joke-api.appspot.com/random_ten")!
    
    init() {
        self.loaded = false
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
        switch selectedType {
        case 0:
            url = URL(string: "https://official-joke-api.appspot.com/random_ten")!
            print("random")
        case 1:
            url = URL(string: "https://official-joke-api.appspot.com/jokes/knock-knock/ten")!
            print("konec")
        case 2:
            url = URL(string: "https://official-joke-api.appspot.com/jokes/programming/ten")!
            print("program")
        case 3:
            url = URL(string: "https://official-joke-api.appspot.com/jokes/general/ten")!
            print("general")
        default:
            url = URL(string: "https://official-joke-api.appspot.com/random_ten")!
            print("default")
        }
        self.loaded = false
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
    var types = ["Random", "Knock Knock", "Programming", "General"]
    public var type: String = ""
    @ObservedObject var fetchJoke = FetchJoke()
    @ObservedObject var userSettings = UserSettings()
    
    
    var body: some View {
        VStack(alignment: .center, content: {
            Image("jokefylogo");
            Spacer()
            Text("Hi \(userSettings.username) here are your \(types[fetchJoke.selectedType]) jokes")
                .font(.headline);
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
                    Spacer()
                    Group{
                        if fetchJoke.loaded == false {
                            ProgressView()
                            Spacer()
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
                NavigationView{
                    Form{
                        Section{
                            HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                                Text("Profile Picture (TBD)").font(.headline)
                                Spacer()
                                Image(systemName: "person.crop.circle")
                                
                            })
                            
                        }
                        Section{
                            Text("Name").font(.headline)
                            TextField("Enter your name", text: $userSettings.username).textFieldStyle(RoundedBorderTextFieldStyle()).padding()
                        }
                        Section {
                            Picker(selection: $fetchJoke.selectedType, label: Text("Prefered Jokes")){
                                ForEach(0 ..< types.count) {
                                    Text(self.types[$0])
                                }
                            }.pickerStyle(DefaultPickerStyle())
                            Text("Refresh jokes after selection").font(.caption)
                            
                        }
                    }.navigationBarHidden(true)
                    
                }
                .padding()
                
                
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
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
