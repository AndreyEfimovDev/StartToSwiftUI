//
//  EditCard.swift
//  SelfLearningENApp2
//
//  Created by Andrey Efimov on 04.04.2025.
//

import SwiftUI

// edit and add cards

enum PostFields: Hashable {
    case postTitle
    case intro
    case author
    case urlString
    case additionalInfo
    case date
}

struct AddEditPostSheet: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostsViewModel
    
    @FocusState private var focusedField: PostFields?
    
    private var viewTitle: String {
        isNewPost ? "Add Post" : "Edit Post"
    }
    
    @State private var editedPost: Post
    @State private var draftPost: Post?
    @State private var isNewPost: Bool
    
    init(post: Post?) {
        
        if let post = post {
            _editedPost = State(initialValue: post)
            _draftPost = State(initialValue: post)
            self.isNewPost = false
        } else {
            _editedPost = State(initialValue: Post(
                title: "",
                intro: "",
                author: "",
                postLanguage: .english,
                urlString: "",
                postPlatform: .youtube,
                postDate: nil,
                studyLevel: .beginner,
                favoriteChoice: .no,
                additionalText: "",
                date: Date()
            ))
            self.isNewPost = true
        }
    }
    
    private let fontSubheader: Font = .caption
    private let fontTextInput: Font = .callout
    private let colorSubheader: Color = Color.mycolor.mySecondaryText
    
    private let startingDate: Date = Calendar.current.date(from: DateComponents(year: 2019)) ?? Date()
    private let endingDate: Date = Date()
    private var bindingPostDate: Binding<Date> {
        Binding<Date>(
            get: { editedPost.postDate ?? Date() },
            set: { editedPost.postDate = $0 }
        )
    }
    
    @State private var showAlert = false
    @State var alertType: PostAlerts? = nil
    @State var alertTitle: String = ""
    @State var alertMessage: String = ""
    
    enum PostAlerts {
        case success
        case error
    }
    
    // MARK: BODY
    
    var body: some View {
        
        NavigationStack {
            VStack {
                ScrollView {
                    titleSection
                    introSection
                    authorSection
                    languageSection
                    urlSection
                    platformSection
                    postDateSection
                    studyLevelSection
                    favoviteChoiceSection
                    addInforSection
                } // ScrollView
                .foregroundStyle(Color.mycolor.myAccent)
                .padding(.horizontal, 8)
            } // VStack
            .navigationTitle(viewTitle)
            .scrollIndicators(.hidden)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CircleStrokeButtonView(
                        iconName: "checkmark",
                        iconFont: .title2,
                        isShownCircle: false) { // square.and.arrow.down
                            checkPostAndSave()
                        }
//                        .foregroundStyle(editedPost == draftPost ? Color.mycolor.secondaryText : Color.mycolor.blue)
                        .alert(isPresented: $showAlert) {
                            getAlert(
                                alertTitle: alertTitle,
                                alertMessage: alertMessage)
                        }
                }
                ToolbarItem(placement: .topBarTrailing) { //
                    CircleStrokeButtonView(
                        iconName: "xmark",
                        isIconColorToChange: true,
                        imageColorSecondary: Color.mycolor.myRed,
                        isShownCircle: false)
                    {
                        dismiss()
                    }
                }
            }
            .overlay(
                Group {
                    if focusedField != nil {
                        VStack {
                            Spacer()
                            HStack {
                                CircleStrokeButtonView(
                                    iconName: "keyboard.chevron.compact.down",
                                    iconFont: .title2,
                                    imageColorPrimary: Color.mycolor.myBlue,
                                    widthIn: 55,
                                    heightIn: 55) {
                                        withAnimation {
                                            focusedField = nil
                                        }
                                    }
//                                    .padding(.leading, 16)
                                    .padding(.bottom, 16) // Indent from the bottom edge (above the keyboard)
//                                Spacer()
                            }
                        }
                        .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: focusedField != nil)
            )
        } //NavigationStack
        .onAppear {
            focusedField = .postTitle
        }
    }
    
    func checkPostAndSave() {
        if !textIsAppropriate(text: editedPost.title) {
            alertType = .error
            alertTitle = "The Title must contain at least 3 characters."
            alertMessage = "Please correct the Title."
            focusedField = .postTitle
            showAlert.toggle()
        } else if !textIsAppropriate(text: editedPost.author) {
            alertType = .error
            alertTitle = "The Author must contain at least 3 characters."
            alertMessage = "Please correct the Author."
            focusedField = .author
            showAlert.toggle()
        } else if vm.checkNewPostForUniqueTitle(editedPost.title, excludingPostId: isNewPost ? nil : editedPost.id) {
            alertType = .error
            alertTitle = "The Title must be unique."
            alertMessage = "Please correct the Title."
            focusedField = .postTitle
            showAlert.toggle()
        } else {
            switch isNewPost {
            case true:
                print("Added a new post: \(editedPost.title)")
                print("\(isNewPost.description)")
                vm.addPost(editedPost)
            case false:
                print("Updated a current post : \(editedPost.title)")
                print("\(isNewPost.description)")
                vm.updatePost(editedPost)
            }
            alertType = .success
            showAlert.toggle()
        }
    }
    
    func textIsAppropriate(text: String) -> Bool {
        return text.count >= 3
    }
    
    func getAlert(alertTitle: String,
                  alertMessage: String) -> Alert {
        switch alertType {
        case .error:
            return Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")))
        case .success:
            if isNewPost {
                return Alert(title: Text("New Post added successfully"), message: Text("Tap OK to continue"), dismissButton: .default(Text("OK"), action: {
                    dismiss()
                }))
            } else {
                return Alert(title: Text("Edited Post saved successfully"), message: Text("Tap OK to continue"), dismissButton: .default(Text("OK"), action: {
                    dismiss()
                }))
            }
            
        default:
            return Alert(title: Text("ERROR"))
        }
    }
    
    
    @ViewBuilder
    private func textEditorRightButton(
        text: String,
        iconName: String,
        iconColor: Color,
        action: @escaping () -> ()
    ) -> some View {
        
        if !text.isEmpty {
            Button {
                action()
            } label: {
                Image(systemName: iconName)
                    .foregroundStyle(iconColor)
            }
            .frame(width: 50, height: 50)
            .background(.black.opacity(0.001))
        }
    }
    
    private var titleSection: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            Text("Title")
                .sectionSubheaderFormater(fontSubheader: fontSubheader,
                                          colorSubheader: colorSubheader)
            HStack(spacing: 0) {
                TextField("", text: $editedPost.title)
                    .font(fontTextInput)
                    .padding(.leading, 5)
                    .frame(height: 50)
                    .focused($focusedField, equals: .postTitle)
                    .onSubmit {focusedField = .intro }
                    .submitLabel(.next)
                textEditorRightButton(
                    text: editedPost.title,
                    iconName: "xmark",
                    iconColor: Color.mycolor.myRed) {
                        editedPost.title = ""
                    }
                    .background(.ultraThickMaterial,
                                in: RoundedRectangle(cornerRadius: 8)
                    )
            }
            .sectionBackgroundInAddEditView()
        }
    }
    
    private var introSection: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            Text("Intro")
                .sectionSubheaderFormater(fontSubheader: fontSubheader,
                                          colorSubheader: colorSubheader)
            HStack(spacing: 0) {
                TextEditor(text: $editedPost.intro)
                    .font(fontTextInput)
                    .frame(height: 200)
                    .scrollContentBackground(.hidden)
                    .focused($focusedField, equals: .intro)
                    .onSubmit {focusedField = .author }
                    .submitLabel(.return)
                VStack {
                    textEditorRightButton(
                        text: editedPost.intro,
                        iconName: "xmark",
                        iconColor: Color.mycolor.myRed) {
                            editedPost.intro = ""
                        }
                        .background(.ultraThickMaterial,
                                    in: RoundedRectangle(cornerRadius: 8)
                        )
                    textEditorRightButton(
                        text: editedPost.intro,
                        iconName: "arrow.turn.right.down",
                        iconColor: Color.mycolor.myBlue) {
                            focusedField = .author
                        }
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .background(.ultraThickMaterial,
                                    in: RoundedRectangle(cornerRadius: 8)
                        )
                }
            }
            .sectionBackgroundInAddEditView()
        }
    }
    
    private var authorSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Author")
                .sectionSubheaderFormater(fontSubheader: fontSubheader,
                                          colorSubheader: colorSubheader)
            HStack(spacing: 0) {
                TextField("", text: $editedPost.author)
                    .font(fontTextInput)
                    .padding(.leading, 5)
                    .frame(height: 50)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .author)
                    .onSubmit {focusedField = nil }
                    .submitLabel(.next)
                textEditorRightButton(
                    text: editedPost.author,
                    iconName: "xmark",
                    iconColor: Color.mycolor.myRed) {
                        editedPost.author = ""
                    }
                    .background(.ultraThickMaterial,
                                in: RoundedRectangle(cornerRadius: 8)
                    )
            }
            .sectionBackgroundInAddEditView()
        }
    }
    
    private var languageSection: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            Text("Post Language")
                .sectionSubheaderFormater(fontSubheader: fontSubheader,
                                          colorSubheader: colorSubheader)
            HStack {
                Text("Select Language:")
                    .font(fontTextInput)
                    .padding(.leading, 5)
                Spacer()
                Picker("", selection: $editedPost.postLanguage) {
                    ForEach(LanguageOptions.allCases, id: \.self) { language in
                        Text(language.displayName)
                            .tag(language)
                            .foregroundColor(.blue)
                    }
                }
                .pickerStyle(.menu)
                .tint(.blue)
                .frame(height: 50)
            }
            .sectionBackgroundInAddEditView()
        }
        .onChange(of: editedPost.postLanguage) {
            focusedField = .urlString
        }
    }
    
    private var urlSection: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            Text("URL")
                .sectionSubheaderFormater(fontSubheader: fontSubheader,
                                          colorSubheader: colorSubheader)
            HStack(spacing: 0) {
                TextField("", text: $editedPost.urlString)
                    .font(fontTextInput)
                    .padding(.leading, 5)
                    .frame(height: 50)
                    .textInputAutocapitalization(.none)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                    .focused($focusedField, equals: .urlString)
                    .onSubmit {focusedField = nil }
                    .submitLabel(.next)
                textEditorRightButton(
                    text: editedPost.urlString,
                    iconName: "xmark",
                    iconColor: Color.mycolor.myRed) {
                        editedPost.urlString = ""
                    }
                    .background(.ultraThickMaterial,
                                in: RoundedRectangle(cornerRadius: 8)
                    )
            }
            .background(.ultraThickMaterial)
            .cornerRadius(8)
        }
    }
    
    private var platformSection: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            Text("Post Platform")
                .sectionSubheaderFormater(fontSubheader: fontSubheader,
                                          colorSubheader: colorSubheader)
            UnderlineSermentedPickerNotOptional(
                selection: $editedPost.postPlatform,
                allItems: Platform.allCases,
                titleForCase: { $0.displayName },
                selectedTextColor: Color.blue,
                unselectedTextColor: Color.mycolor.mySecondaryText
            )
            .frame(height: 50)
            .sectionBackgroundInAddEditView()
        }
    }
    
    private var postDateSection: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            Text("Post Date")
                .sectionSubheaderFormater(fontSubheader: fontSubheader,
                                          colorSubheader: colorSubheader)
            DatePicker(
                "Select post date:",
                selection: bindingPostDate,
                in: startingDate...endingDate,
                displayedComponents: .date
            )
            .tint(Color.mycolor.myBlue)
            .padding(.trailing, 4)
            .frame(height: 50)
            .sectionBackgroundInAddEditView()
        }
        .onChange(of: bindingPostDate.wrappedValue) { oldValue, newValue in
            editedPost.postDate = newValue
        }
    }
    
    private var studyLevelSection: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            Text("Study Level")
                .sectionSubheaderFormater(fontSubheader: fontSubheader,
                                          colorSubheader: colorSubheader)
            UnderlineSermentedPickerNotOptional(
                selection: $editedPost.studyLevel,
                allItems: StudyLevel.allCases,
                titleForCase: { $0.displayName },
                selectedTextColor: Color.mycolor.myBlue,
                unselectedTextColor: Color.mycolor.mySecondaryText
            )
            .frame(height: 50)
            .sectionBackgroundInAddEditView()
        }
    }
    
    private var favoviteChoiceSection: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            Text("Favorite")
                .sectionSubheaderFormater(fontSubheader: fontSubheader,
                                          colorSubheader: colorSubheader)
            UnderlineSermentedPickerNotOptional(
                selection: $editedPost.favoriteChoice,
                allItems: FavoriteChoice.allCases,
                titleForCase: { $0.displayName },
                selectedTextColor: Color.mycolor.myBlue,
                unselectedTextColor: Color.mycolor.mySecondaryText
            )
            .frame(height: 50)
            .sectionBackgroundInAddEditView()
        }
        .onChange(of: editedPost.favoriteChoice) {
            focusedField = .additionalInfo
        }
    }
    
    private var addInforSection: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            Text("Additional Information")
                .sectionSubheaderFormater(
                    fontSubheader: fontSubheader,
                    colorSubheader: colorSubheader
                )
            HStack(spacing: 0) {
                TextEditor(text: $editedPost.additionalText)
                    .font(fontTextInput)
                    .frame(minHeight: 200)
                    .scrollContentBackground(.hidden)
                    .focused($focusedField, equals: .additionalInfo)
                    .onSubmit {focusedField = nil }
                    .submitLabel(.return)
                VStack {
                    textEditorRightButton(
                        text: editedPost.additionalText,
                        iconName: "xmark",
                        iconColor: Color.mycolor.myRed) {
                            editedPost.additionalText = ""
                        }
                        .background(.ultraThickMaterial,
                                    in: RoundedRectangle(cornerRadius: 8)
                        )
                    textEditorRightButton(
                        text: editedPost.additionalText,
                        iconName: "arrow.turn.right.down",
                        iconColor: Color.mycolor.myBlue) {
                            focusedField = nil
                        }
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .background(.ultraThickMaterial,
                                    in: RoundedRectangle(cornerRadius: 8)
                        )
                }
            }
            .sectionBackgroundInAddEditView()
        }
    }
}

#Preview {
    
    NavigationStack {
        AddEditPostSheet(post: DevPreview.samplePost1)
            .environmentObject(PostsViewModel())
    }
}

#Preview {
    NavigationStack {
        
        AddEditPostSheet(post: nil)
            .environmentObject(PostsViewModel())
    }
}

