//
//  EditCard.swift
//  SelfLearningENApp2
//
//  Created by Andrey Efimov on 04.04.2025.
//

import SwiftUI

struct AddEditPostSheet: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostsViewModel
    
    private let hapticManager = HapticManager.shared
    
    @FocusState private var focusedField: PostFields?
    @State private var focusedFieldSaved: PostFields?
    
    private var viewTitle: String {
        isNewPost ? "Add Post" : "Edit Post"
    }
    
    @State private var editedPost: Post
    @State private var draftPost: Post?
    @State private var isNewPost: Bool
    
    @State var isShowingMenuConfirmation: Bool = false
    @State var isMenuConfirmationBlocked: Bool = false
    
    @State private var deleteItem = false
    
    private let sectionBackground: Color = Color.mycolor.mySectionBackground
    private let sectionCornerRadius: CGFloat = 8

    private let fontSubheader: Font = .caption
    private let fontTextInput: Font = .callout
    private let colorSubheader: Color = Color.mycolor.myAccent.opacity(0.5)
    
    private let startingDate: Date = Calendar.current.date(from: DateComponents(year: 2019)) ?? Date() // set the limit to the beginning year for choice
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
    
    init(post: Post?) {
        
        if let post = post { // Post for editing initialising
            _editedPost = State(initialValue: post)
            _draftPost = State(initialValue: post)
            self.isNewPost = false
        } else { // Add a new post initialising
            _editedPost = State(initialValue: Post(
                title: "",
                intro: "",
                author: "",
                urlString: "",
                postPlatform: .youtube,
                postDate: nil,
                studyLevel: .beginner,
                favoriteChoice: .no,
                additionalText: "",
            ))
            self.isNewPost = true
        }
    }
    
    // MARK: BODY
    
    var body: some View {
        
        NavigationStack {
            VStack {
                ScrollView {
                    titleSection
                    introSection
                    authorSection
                    urlSection
                    postDateSection
                    typeSection
                    platformSection
                    studyLevelSection
                    favoviteChoiceSection
                    addInforSection
                } // ScrollView
                .foregroundStyle(Color.mycolor.myAccent)
                .padding(.horizontal, 8)
            }
            .navigationTitle(viewTitle)
            .background(Color.mycolor.myBackground)
            .scrollIndicators(.hidden)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar { toolbarForAddEditView() }
            .overlay(
                hideKeybordButton
            )
        } //NavigationStack
        .onAppear {
            focusedField = .postTitle
        }
        .overlay (
            exitMenuConfirmation
        )
    }
    
    // MARK: Subviews
    
    @ToolbarContentBuilder
    private func toolbarForAddEditView() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            CircleStrokeButtonView(
                iconName: "checkmark",
                isShownCircle: false)
            {
                checkPostAndSave()
            }
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
                hapticManager.notification(type: .warning)
                focusedFieldSaved = focusedField ?? nil
                focusedField = nil
                isShowingMenuConfirmation = true
            }
        }
    }
    
    @ViewBuilder
    private func textEditorRightButton(
        text: String,
        iconName: String = "xmark",
        iconColor: Color = Color.mycolor.myRed,
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
                .textCase(.uppercase)
                .sectionSubheaderFormater(
                    fontSubheader: fontSubheader,
                    colorSubheader: colorSubheader
                )
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
                    iconColor: Color.mycolor.myRed) {
                        editedPost.title = ""
                    }
            }
            .background(
                sectionBackground,
                        in: RoundedRectangle(cornerRadius: sectionCornerRadius)
            )
        }
    }
    
    private var introSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Intro")
                .textCase(.uppercase)
                .sectionSubheaderFormater(
                    fontSubheader: fontSubheader,
                    colorSubheader: colorSubheader
                )
            HStack(spacing: 0) {
                TextEditor(text: $editedPost.intro)
                    .font(fontTextInput)
                    .frame(height: 200)
                    .autocorrectionDisabled(true) // fixing leaking memory
                    .scrollContentBackground(.hidden)
                    .focused($focusedField, equals: .intro)
                    .onSubmit {focusedField = .author }
                    .submitLabel(.return)
                VStack {
                    textEditorRightButton(text: editedPost.intro) {
                        editedPost.intro = ""
                    }
                    textEditorRightButton(
                        text: editedPost.intro,
                        iconName: "arrow.turn.right.down",
                        iconColor: Color.mycolor.myBlue) {
                            focusedField = .author
                        }
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
            .background(
                sectionBackground,
                        in: RoundedRectangle(cornerRadius: sectionCornerRadius)
            )
        }
    }
    
    private var authorSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Author")
                .textCase(.uppercase)
                .sectionSubheaderFormater(
                    fontSubheader: fontSubheader,
                    colorSubheader: colorSubheader
                )
            HStack(spacing: 0) {
                TextField("", text: $editedPost.author)
                    .font(fontTextInput)
                    .padding(.leading, 5)
                    .frame(height: 50)
                    .autocorrectionDisabled(true) // fixing leaking memory
                    .focused($focusedField, equals: .author)
                    .onSubmit {focusedField = .urlString }
                    .submitLabel(.next)
                textEditorRightButton(text: editedPost.author) {
                    editedPost.author = ""
                }
            }
            .background(
                sectionBackground,
                        in: RoundedRectangle(cornerRadius: sectionCornerRadius)
            )
        }
    }
        
    private var urlSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("URL")
                .sectionSubheaderFormater(
                    fontSubheader: fontSubheader,
                    colorSubheader: colorSubheader
                )
            HStack(spacing: 0) {
                TextField("", text: $editedPost.urlString)
                    .font(fontTextInput)
                    .padding(.leading, 5)
                    .frame(height: 50)
                    .textInputAutocapitalization(.none)
                    .autocorrectionDisabled(true) // fixing leaking memory
                    .keyboardType(.URL)
                    .focused($focusedField, equals: .urlString)
                    .onSubmit {focusedField = nil }
                    .submitLabel(.next)
                textEditorRightButton(text: editedPost.urlString) {
                    editedPost.urlString = ""
                }
            }
            .background(
                sectionBackground,
                        in: RoundedRectangle(cornerRadius: sectionCornerRadius)
            )
        }
    }
    
    private var postDateSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Post Date")
                .textCase(.uppercase)
                .sectionSubheaderFormater(
                    fontSubheader: fontSubheader,
                    colorSubheader: colorSubheader
                )
            DatePicker(
                "Pick up date:",
                selection: bindingPostDate,
                in: startingDate...endingDate,
                displayedComponents: .date
            )
            .font(fontTextInput)
            .padding(.leading, 5)
            .tint(Color.mycolor.myBlue)
            .padding(.trailing, 4)
            .frame(height: 50)
            .background(
                sectionBackground,
                        in: RoundedRectangle(cornerRadius: sectionCornerRadius)
            )
        }
        .onChange(of: bindingPostDate.wrappedValue) { _, newValue in
            editedPost.postDate = newValue
        }
    }
    
    private var typeSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Post Type")
                .textCase(.uppercase)
                .sectionSubheaderFormater(
                    fontSubheader: fontSubheader,
                    colorSubheader: colorSubheader
                )
            UnderlineSermentedPickerNotOptional(
                selection: $editedPost.postType,
                allItems: PostType.allCases,
                titleForCase: { $0.displayName },
                selectedTextColor: Color.mycolor.myBlue,
                unselectedTextColor: Color.mycolor.mySecondaryText
            )
            .padding(.horizontal, 8)
            .frame(height: 50)
            .background(
                sectionBackground,
                        in: RoundedRectangle(cornerRadius: sectionCornerRadius)
            )
        }
    }
    
    private var platformSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Platform")
                .textCase(.uppercase)
                .sectionSubheaderFormater(fontSubheader: fontSubheader,
                                          colorSubheader: colorSubheader)
            UnderlineSermentedPickerNotOptional(
                selection: $editedPost.postPlatform,
                allItems: Platform.allCases,
                titleForCase: { $0.displayName },
                selectedTextColor: Color.mycolor.myBlue,
                unselectedTextColor: Color.mycolor.mySecondaryText
            )
            .padding(.horizontal, 8)
            .frame(height: 50)
            .background(
                sectionBackground,
                        in: RoundedRectangle(cornerRadius: sectionCornerRadius)
            )
        }
    }
    
    private var studyLevelSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Study Level")
                .textCase(.uppercase)
                .sectionSubheaderFormater(fontSubheader: fontSubheader,
                                          colorSubheader: colorSubheader)
            UnderlineSermentedPickerNotOptional(
                selection: $editedPost.studyLevel,
                allItems: StudyLevel.allCases,
                titleForCase: { $0.displayName },
                selectedTextColor: Color.mycolor.myBlue,
                unselectedTextColor: Color.mycolor.mySecondaryText
            )
            .padding(.horizontal, 8)
            .frame(height: 50)
            .background(
                sectionBackground,
                        in: RoundedRectangle(cornerRadius: sectionCornerRadius)
            )
        }
    }
    
    private var favoviteChoiceSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Favorite")
                .textCase(.uppercase)
                .sectionSubheaderFormater(fontSubheader: fontSubheader,
                                          colorSubheader: colorSubheader)
            UnderlineSermentedPickerNotOptional(
                selection: $editedPost.favoriteChoice,
                allItems: FavoriteChoice.allCases,
                titleForCase: { $0.displayName },
                selectedTextColor: Color.mycolor.myBlue,
                unselectedTextColor: Color.mycolor.mySecondaryText
            )
            .padding(.horizontal, 8)
            .frame(height: 50)
            .background(
                sectionBackground,
                        in: RoundedRectangle(cornerRadius: sectionCornerRadius)
            )
        }
        .onChange(of: editedPost.favoriteChoice) {
            focusedField = .additionalInfo
        }
    }
    
    private var addInforSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Additional Information")
                .textCase(.uppercase)
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
                    textEditorRightButton(text: editedPost.additionalText) {
                        editedPost.additionalText = ""
                    }
                    textEditorRightButton(
                        text: editedPost.additionalText,
                        iconName: "arrow.turn.right.down",
                        iconColor: Color.mycolor.myBlue) {
                            focusedField = nil
                        }
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
            .background(
                sectionBackground,
                        in: RoundedRectangle(cornerRadius: sectionCornerRadius)
            )
        }
    }
    
    private var hideKeybordButton: some View {
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
                            .padding(.bottom, 16)
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: focusedField != nil)
    }
    
    private var exitMenuConfirmation: some View {
        Group {
            if isShowingMenuConfirmation {
                ZStack {
                    Color.mycolor.myAccent.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Text("DATA IS NOT SAVED!")
                            .font(.headline)
                            .bold()
                            .foregroundColor(Color.mycolor.myRed)
                        
                        Text("Are you sure to exit without saving your data?")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.mycolor.myAccent.opacity(0.8))
                        
                        ClearCupsuleButton(
                            primaryTitle: "Yes",
                            primaryTitleColor: Color.mycolor.myRed) {
                                vm.isPostDraftSaved = false // потом убрать
                                dismiss()
                            }
                            .disabled(isMenuConfirmationBlocked)
                        
                        ClearCupsuleButton(
                            primaryTitle: "Save draft",
                            secondaryTitle: "Draft saved",
                            secondaryTitleColor: Color.mycolor.myGreen,
                            isToChange: vm.isPostDraftSaved) {
                                
                                vm.titlePostSaved = editedPost.title
                                vm.introPostSaved = editedPost.intro
                                vm.authorPostSaved = editedPost.author
                                vm.typePostSaved = editedPost.postType
                                vm.urlStringPostSaved = editedPost.urlString
                                vm.platformPostSaved = editedPost.postPlatform
                                vm.datePostSaved = editedPost.postDate
                                vm.studyLevelPostSaved = editedPost.studyLevel
                                vm.favoriteChoicePostSaved = editedPost.favoriteChoice
                                vm.additionalTextPostSaved = editedPost.additionalText
                                
                                isMenuConfirmationBlocked = true
                                hapticManager.notification(type: .success)
                                vm.isPostDraftSaved = true
                                DispatchQueue.main.asyncAfter(deadline: vm.dispatchTime) {
                                    isMenuConfirmationBlocked = false
                                    dismiss()
                                }
                            }
                            .disabled(isMenuConfirmationBlocked)

                        ClearCupsuleButton(
                            primaryTitle: "No",
                            primaryTitleColor: Color.mycolor.myGreen) {
                                vm.isPostDraftSaved = false // потом убрать
                                focusedField = focusedFieldSaved
                                isShowingMenuConfirmation = false
                            }
                            .disabled(isMenuConfirmationBlocked)
                    }
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(30)
                    .padding(.horizontal, 40)
                }
            }
        }
    }
    
    // MARK: Functions
    
    private func checkPostAndSave() {
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
        } else if vm.checkNewPostForUniqueTitle(editedPost.title, editingPostId: isNewPost ? nil : editedPost.id) {
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
    
    private func textIsAppropriate(text: String) -> Bool {
        return text.count >= 3
    }
    
    private func getAlert(alertTitle: String,
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

