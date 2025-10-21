////
////  EmbedPickerInFocusView.swift
////  StartToSwiftUI
////
////  Created by Andrey Efimov on 13.09.2025.
////
//
//import SwiftUI
//
//enum Field {
//    case name
//    case language
//    case email
//}
//
//
//
//struct EmbedPickerInFocusView: View {
//    
//    @State private var name = ""
//    @State private var email = ""
//    @State private var selectedLanguage: LanguageOptions = .english
//    
//    @FocusState private var focusedField: Field?
//    
//    var body: some View {
//        Form {
//            // 🔹 Первое текстовое поле
//            TextField("Имя", text: $name)
//                .focused($focusedField, equals: .name)
//                .submitLabel(.next)
//                .onSubmit {
//                    focusedField = .language
//                }
//            
//            // 🔹 Сегментированный Picker
//            Picker("Язык", selection: $selectedLanguage) {
//                ForEach(LanguageOptions.allCases, id: \.self) { lang in
//                    Text(lang.displayName).tag(lang)
//                }
//            }
//            .pickerStyle(.segmented)
//            .padding(.vertical, 8)
//            .overlay(
//                RoundedRectangle(cornerRadius: 8)
//                    .stroke(focusedField == .language ? Color.blue : Color.clear, lineWidth: 2)
//            )
//            .onChange(of: focusedField) { newValue in
//                // как только "фокус" попадает на Picker → ждем выбора и сразу двигаем дальше
//                if newValue == .language {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                        focusedField = .email
//                    }
//                }
//            }
//            
//            // 🔹 Второе текстовое поле
//            TextField("Email", text: $email)
//                .keyboardType(.emailAddress)
//                .focused($focusedField, equals: .email)
//                .submitLabel(.done)
//        }
//        .onAppear {
//            focusedField = .name
//        }
//    }
//}
//
//#Preview {
//    EmbedPickerInFocusView()
//}
