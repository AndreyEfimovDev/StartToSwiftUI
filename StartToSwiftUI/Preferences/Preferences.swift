//
//  _Preferences.swift
//  SelfLearningENApp2
//
//  Created by Andrey Efimov on 02.04.2025.
//

import SwiftUI


struct PreferencesView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var vm: PostsViewModel

    let action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
 
        ZStack (alignment: .topLeading) {
            CircleButtonView(iconName: "xmark") {
                action()
            }

            NavigationStack {
                
                    Form {
                        Section(header: Text("Layout")) {
    //                        Picker("Color Mode", selection: $defaults.selectedMode) {
    //                            Text("Dark").tag("dark")
    //                            Text("Light").tag("light")
    //                            Text("System").tag("system")
    //                        }
                            NavigationLink("Text Size") {
//                                TextSizeSection().padding()
                            }
                        } //Section "Layout"
                        Section(header: Text("Dictionary")) {
                            NavigationLink("Managing Cards") {
//                                CardsSegmentsView()
                            }
                            NavigationLink("BackUP") {
                                Text("Back Up")
                            }
                        }
                        Section(header: Text("About APP")) {
                            HStack {
                                Text("Name")
                                Spacer()
                                Text("Start To SwiftUI")}
                            HStack {
                                Text("Version")
                                Spacer()
                                Text("01.10")}
                            HStack {
                                Text("Developed by")
                                Spacer()
                                Text("Andrey Efimov") }
                        } //Section "About APP"
                        
                        
                    } //Form
                    .navigationTitle("Preferences")
    //                .onAppear {
    //                    states.selectedMode = defaults.selectedMode
    //                } // .onAppear
    //                .onDisappear () {
    //                    defaults.selectedMode = states.selectedMode
    //                } // .onDisappear

            } // NavigationStack
        }

        
    }
}



#Preview {
    PreferencesView{
        
    }
    .environmentObject(PostsViewModel())
}
