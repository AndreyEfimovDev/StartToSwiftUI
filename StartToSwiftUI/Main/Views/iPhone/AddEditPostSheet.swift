//
//  EditCard.swift
//  SelfLearningENApp2
//
//  Created by Andrey Efimov on 04.04.2025.
//

import SwiftUI

struct AddEditPostSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostsViewModel
    
    private let hapticManager = HapticService.shared
    
    @FocusState private var focusedField: PostFields?
    @State private var focusedFieldSaved: PostFields?
    
    private var viewTitle: String {
        isNewPost ? "Add" : "Edit"
    }
    
    @State private var editedPost: Post
    @State private var draftPost: Post?
    @State private var isNewPost: Bool
    
    @State private var isPostDraftSaved: Bool = false
    @State private var isShowingExitMenuConfirmation: Bool = false
    
    private let sectionBackground: Color = Color.mycolor.mySectionBackground
    private let sectionCornerRadius: CGFloat = 8
    
    private let fontSubheader: Font = .caption
    private let fontTextInput: Font = .callout
    private let colorSubheader: Color = Color.mycolor.myAccent.opacity(0.5)
    
    // set beginning year for choice
    private let startingDate: Date = Calendar.current.date(from: DateComponents(year: 2019)) ?? Date.distantPast
    
    private let endingDate: Date = .now
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
    
    let templateForNewPost: Post = Post(
//        category: "",
//        title: "",
//        intro: "",
//        author: "",
//        urlString: "https://",
//        postPlatform: .youtube,
//        postDate: nil,
//        studyLevel: .beginner,
//        favoriteChoice: .no,
//        notes: "",
        origin: .local,
        draft: true
    )
    
    enum PostAlerts {
        case success
        case error
    }
    
    init(post: Post?) {
        
        if let post = post { // if post is passed to edit - post for editing initialising
            _editedPost = State(initialValue: post)
            _draftPost = State(initialValue: post)
            self.isNewPost = false
        } else { // if post is not passed (nil) - add a new post initialising
            _editedPost = State(initialValue: templateForNewPost)
            _draftPost = State(initialValue: templateForNewPost)
            self.isNewPost = true
        }
    }
    
    // MARK: BODY
    
    var body: some View {
        
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
                notesSection
            } // ScrollView
            .foregroundStyle(Color.mycolor.myAccent)
            .padding(.horizontal, 8)
        }
        .navigationTitle(viewTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
//        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .background(Color.mycolor.myBackground)
        .toolbar {
            toolbarForAddEditView()
        }
        .overlay(
            hideKeybordButton
        )
        .opacity(isShowingExitMenuConfirmation ? 0.5 : 1.0)
        .alert(isPresented: $showAlert) {
            getAlert(
                alertTitle: alertTitle,
                alertMessage: alertMessage)
        }
        .onAppear {
            focusedField = .postTitle
        }
        .overlay {
            if isShowingExitMenuConfirmation {
                exitMenuConfirmation
                    .opacity(isShowingExitMenuConfirmation ? 1 : 0)
                    .transition(.move(edge: .bottom))
            }
        }
    }
    
    // MARK: Subviews
    
    private var exitMenuConfirmation: some View {
        ZStack {
            Color.mycolor.myAccent.opacity(0.001)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    isShowingExitMenuConfirmation = false
                }
            
            VStack(spacing: 8) {
                
                Text("Data is not saved!")
                    .font(.headline)
                    .bold()
                    .foregroundColor(Color.mycolor.myRed)
                
                Text("Are you sure to exit without saving your data?")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.mycolor.myAccent.opacity(0.8))
                
                
                ClearCupsuleButton(
                    primaryTitle: "Don't save",
                    primaryTitleColor: Color.mycolor.myRed) {
                            dismiss()
                    }
                
                ClearCupsuleButton(
                    primaryTitle: "Save draft",
                    primaryTitleColor: Color.mycolor.myBlue) {
                        editedPost.draft = true
                        isShowingExitMenuConfirmation = false
                        checkPostAndSave()
                    }
                
                ClearCupsuleButton(
                    primaryTitle: "Cancel",
                    primaryTitleColor: Color.mycolor.myAccent) {
                        focusedField = focusedFieldSaved
                        isShowingExitMenuConfirmation = false
                    }
            } // VStack
            .padding()
            .background(.ultraThinMaterial)
            .menuFormater()
            .padding(.horizontal, 40)
        } // ZStack
        .opacity(isPostDraftSaved ? 0 : 1)
    }
    
    @ToolbarContentBuilder
    private func toolbarForAddEditView() -> some ToolbarContent {
        
        ToolbarItem(placement: .topBarLeading) {
            // SAVE button
            CircleStrokeButtonView(
                iconName: "checkmark",
                isShownCircle: false)
            {
                if editedPost.draft == false && editedPost == draftPost {  // if no changes
                    dismiss()
                } else {
                    editedPost.draft = false
                    checkPostAndSave()
                }
            }
            .disabled(isShowingExitMenuConfirmation)
        }
        ToolbarItem(placement: .topBarTrailing) {
            // Exit button
            CircleStrokeButtonView(
                iconName: "xmark",
                imageColorPrimary: Color.mycolor.myRed,
                isShownCircle: false)
            {
                if editedPost == draftPost {  // if no changes
                    print(" editedPost == draftPost - dismiss()")
                    
                    dismiss()
                } else {
                    print(" editedPost != draftPost - dismiss()")
                    withAnimation(.easeInOut) {
                        isShowingExitMenuConfirmation = true
                        hapticManager.notification(type: .warning)
                        focusedFieldSaved = focusedField ?? nil
                        focusedField = nil
                    }
                }
            }
            .disabled(isShowingExitMenuConfirmation)
        }
    }
    
    @ViewBuilder
    private func textEditorRightButton(
        text: String,
        iconName: String = "xmark",
        iconColor: Color = Color.mycolor.myRed,
        completion: @escaping () -> ()
    ) -> some View {
        
        if !text.isEmpty {
            Button {
                completion()
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
            ZStack {
                HStack {
                    Button(editedPost.postDate == nil ? "Set date" : "Set no date") {
                        if editedPost.postDate == nil {
                            editedPost.postDate = Date()
                        } else {
                            editedPost.postDate = nil
                        }
                    }
                    .foregroundColor(editedPost.postDate == nil ? .blue : .red)
                    .padding(8)
                    .background(
                        .ultraThinMaterial,
                        in: .capsule
                    )
                    Spacer()
                }
                .padding(8)
                .zIndex(1)
                
                DatePicker("",
                           selection: bindingPostDate,
                           in: startingDate...endingDate,
                           displayedComponents: .date
                )
                .tint(Color.mycolor.myBlue)
                .padding(.trailing, 8)
                .datePickerStyle(.compact)
                .disabled(editedPost.postDate == nil)
                .opacity(editedPost.postDate == nil ? 0 : 1)
            }
            .background(
                sectionBackground,
                in: RoundedRectangle(cornerRadius: sectionCornerRadius)
            )
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
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Notes")
                .textCase(.uppercase)
                .sectionSubheaderFormater(
                    fontSubheader: fontSubheader,
                    colorSubheader: colorSubheader
                )
            HStack(spacing: 0) {
                TextEditor(text: $editedPost.notes)
                    .font(fontTextInput)
                    .frame(minHeight: 200)
                    .scrollContentBackground(.hidden)
                    .focused($focusedField, equals: .additionalInfo)
                    .onSubmit {focusedField = nil }
                    .submitLabel(.return)
                VStack {
                    textEditorRightButton(text: editedPost.notes) {
                        editedPost.notes = ""
                    }
                    textEditorRightButton(
                        text: editedPost.notes,
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
                                focusedField = nil
                            }
                            .padding(.bottom, 16)
                    }
                }
            }
        }
    }
    
    // MARK: Functions
    
    private func checkPostAndSave() {
        
        if !isTexLengthAppropriate(text: editedPost.title, limit: 3) {
            alertType = .error
            alertTitle = "The Title must contain at least 3 characters."
            alertMessage = "Please correct the Title."
            focusedField = .postTitle
            showAlert.toggle()
        } else if !isTexLengthAppropriate(text: editedPost.author, limit: 2) {
            alertType = .error
            alertTitle = "The Author must contain at least 2 characters."
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
                vm.addPost(editedPost)
            case false:
                vm.updatePost(editedPost)
            }
            alertType = .success
            showAlert.toggle()
        }
    }
    
    private func isTexLengthAppropriate(text: String, limit: Int) -> Bool {
        return text.count >= limit
    }
    
    private func getAlert(
        alertTitle: String,
        alertMessage: String
    ) -> Alert {
        switch alertType {
        case .error:
            if editedPost.draft == true {
                editedPost.draft = false
            }
            return Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {}
            )
        case .success:
            if editedPost.draft {
                return Alert(
                    title: Text("Draft saved successfully"),
                    message: Text("Tap OK to continue"),
                    dismissButton: .default(Text("OK")) {
                        isPostDraftSaved = true
                        dismiss()
                    }
                )
            }
            if isNewPost {
                return Alert(
                    title: Text("New Post added successfully"),
                    message: Text("Tap OK to continue"),
                    dismissButton: .default(Text("OK")) {
                        dismiss()
                    }
                )
            }
            return Alert(
                title: Text("Post saved successfully"),
                message: Text("Tap OK to continue"),
                dismissButton: .default(Text("OK")) {
                    dismiss()
                }
            )
            
        default:
            return Alert(title: Text("ERROR"))
        }
    }
    
}

#Preview {
    NavigationStack {
        AddEditPostSheet(post: PreviewData.samplePost1)
            .environmentObject(PostsViewModel())
    }
}

#Preview {
    NavigationStack {
        AddEditPostSheet(post: nil)
            .environmentObject(PostsViewModel())
    }
}

