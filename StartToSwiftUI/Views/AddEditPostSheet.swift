//
//  EditCard.swift
//  SelfLearningENApp2
//
//  Created by Andrey Efimov on 04.04.2025.
//

import SwiftUI
import SwiftData

struct AddEditPostSheet: View {
    
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var coordinator: AppCoordinator

    @StateObject private var keyboardManager = KeyboardManager()
    private let hapticManager = HapticService.shared
    

    private var viewTitle: String {
        originalPost == nil ? "Add" : "Edit"
    }
    private var hasNoChanges: Bool {
        return editedPost.isEqual(to: copyOfThePost)
    }

    @State private var editedPost: Post
    private var originalPost: Post?
    private var copyOfThePost: Post
    
    @State private var isPostDraftSaved: Bool = false
    @State private var isShowingExitMenuConfirmation: Bool = false
    @State private var urlTrigger: Bool = true

    @FocusState private var focusedField: PostFields?
    @State private var focusedFieldSaved: PostFields?
    
    private let sectionBackground: Color = Color.mycolor.mySectionBackground
    private let sectionCornerRadius: CGFloat = 8
    
    private let fontSubheader: Font = .caption
    private let fontTextInput: Font = .callout
    private let colorSubheader: Color = Color.mycolor.myAccent.opacity(0.5)
    
    // set 2019 as a beginning year for starting in choice
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
    
    private let templateForNewPost: Post = Post(
        origin: .local,
        draft: true
    )
    
    enum PostAlerts {
        case success
        case error
    }
    
    init(post: Post?) {
        
        if let post = post { // post for editing initialising
            // Link to the original from the context
            originalPost = post
            // Copy for editing
            _editedPost = State(initialValue: post.copy())
            // Copy for comparison
            copyOfThePost = post.copy()
            
        } else { // if post is not passed (nil) - add a new post initialising
            originalPost = nil
            _editedPost = State(initialValue: templateForNewPost.copy())
            copyOfThePost = templateForNewPost.copy()
        }
    }
    
    // MARK: BODY
    
    var body: some View {
        
        Group {
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
                    //                favoviteChoiceSection
                    notesSection
                }
                .foregroundStyle(Color.mycolor.myAccent)
                .padding(.horizontal, 8)
            }
            .navigationTitle(viewTitle)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
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
                    exitConfirmation
                        .opacity(isShowingExitMenuConfirmation ? 1 : 0)
                        .transition(.move(edge: .bottom))
                }
            }
        }
    }
    
    // MARK: Subviews
    @ToolbarContentBuilder
    private func toolbarForAddEditView() -> some ToolbarContent {
        
        ToolbarItem(placement: .topBarLeading) {
            // SAVE button
            CircleStrokeButtonView(
                iconName: "checkmark",
                isShownCircle: false)
            {
                handleSave()
            }
            .disabled(isShowingExitMenuConfirmation)
        }
        ToolbarItem(placement: .topBarTrailing) {
            // EXIT button
            CircleStrokeButtonView(
                iconName: "xmark",
                imageColorPrimary: Color.mycolor.myRed,
                isShownCircle: false)
            {
                handleCancel()
            }
            .disabled(isShowingExitMenuConfirmation)
        }
    }

    private func handleSave() {
        if hasNoChanges {
            // If it is draft - save it as not draft -> .draft = false
            if editedPost.draft == true {
                editedPost.draft = false
                checkPostAndSave()
            } else {
                // If it is not draft - just exit
                navigateBack()
            }
        } else {
            // Drop draft -> .draft = false and Check&Save the post
            editedPost.draft = false
            checkPostAndSave()
        }
    }

    private func handleCancel() {
        if hasNoChanges {
            navigateBack()
        } else {
            withAnimation(.easeInOut) {
                isShowingExitMenuConfirmation = true
                hapticManager.notification(type: .warning)
                focusedFieldSaved = focusedField ?? nil
                focusedField = nil
            }
        }
    }

    private func navigateBack() {
        // Wetermine where to return
        if coordinator.modalPath.isEmpty {
            // In the main stack or this is the root modal view
            coordinator.closeModal()
        } else {
            // In the modal stack
            coordinator.popModal()
        }
    }
    
    private var exitConfirmation: some View {
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
                        navigateBack()
                    }
                
                ClearCupsuleButton(
                    primaryTitle: "Save draft",
                    primaryTitleColor: Color.mycolor.myBlue) {
                        editedPost.draft = true
                        isShowingExitMenuConfirmation = false
                        checkPostAndSave()
                        hapticManager.impact(style: .light)
                    }
                
                ClearCupsuleButton(
                    primaryTitle: "Cancel",
                    primaryTitleColor: Color.mycolor.myAccent) {
                        focusedField = focusedFieldSaved
                        isShowingExitMenuConfirmation = false
                        hapticManager.impact(style: .light)
                    }
            }
            .padding()
            .background(.ultraThinMaterial)
            .menuFormater()
            .padding(.horizontal, 40)
        }
        .opacity(isPostDraftSaved ? 0 : 1)
    }
    
    private func checkPostAndSave() {
        
        guard validatePost() else { return }
        
        if let originalPost = originalPost {
            // If originalPost != nil, then update the post
            originalPost.update(with: editedPost)
            vm.updatePost()
        } else {
            // If originalPost == nil, then add a new post
            vm.addPost(editedPost)
        }
        alertType = .success
        showAlert.toggle()
    }

    private func validatePost() -> Bool {
        
        if !isTexLengthAppropriate(
            text: editedPost.title,
            limit: 3
        ) {
            alertType = .error
            alertTitle = "The Title must contain at least 3 characters."
            alertMessage = "Please correct the Title."
            focusedField = .postTitle
            showAlert.toggle()
            return false
        }
        
        if !isTexLengthAppropriate(
            text: editedPost.author,
            limit: 2
        ) {
            alertType = .error
            alertTitle = "The Author must contain at least 2 characters."
            alertMessage = "Please correct the Author."
            focusedField = .author
            showAlert.toggle()
            return false
        }
        
        if vm.checkNewPostForUniqueTitle(
            editedPost.title,
            editingPostId: originalPost?.id // nil or valid
        ) {
            alertType = .error
            alertTitle = "The Title must be unique."
            alertMessage = "Please correct the Title."
            focusedField = .postTitle
            showAlert.toggle()
            return false
        }
        
        return true
    }
    
    @ViewBuilder
    private func textEditorXmarkButton(
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
                textEditorXmarkButton(
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
                    textEditorXmarkButton(text: editedPost.intro) {
                        editedPost.intro = ""
                    }
                    textEditorXmarkButton(
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
                textEditorXmarkButton(text: editedPost.author) {
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
            Text(editedPost.urlString)
                .font(.caption2)
            ZStack {
                HStack(spacing: 0) {
                    Button(urlTrigger ? "Set url" : "Reset url") {
                        if !urlTrigger {
                            editedPost.urlString = Constants.urlStart
                        }
                        urlTrigger.toggle()
                    }
                    .foregroundColor(urlTrigger ? .blue : .red)
                    .padding(8)
                    .background(
                        .ultraThinMaterial,
                        in: .capsule
                    )
                    .padding(8)
                    .zIndex(1)
                    
                    HStack(spacing: 0) {
                        TextField("", text: $editedPost.urlString)
                            .font(fontTextInput)
                            .padding(.leading, 5)
                            .frame(height: 50)
                            .padding(.horizontal, 3)
                            .textInputAutocapitalization(.none)
                            .autocorrectionDisabled(true) // fixing leaking memory
                            .keyboardType(.URL)
                            .focused($focusedField, equals: .urlString)
                            .onSubmit {focusedField = nil }
                            .submitLabel(.next)
                        textEditorXmarkButton(text: editedPost.urlString) {
                            editedPost.urlString = Constants.urlStart
                        }
                    }
                    .opacity(urlTrigger ? 0 : 1)
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
                    Button(editedPost.postDate == nil ? "Set date" : "Reset date") {
                        editedPost.postDate = editedPost.postDate == nil ? Date() : nil
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
                unselectedTextColor: Color.mycolor.mySecondary
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
                unselectedTextColor: Color.mycolor.mySecondary
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
                unselectedTextColor: Color.mycolor.mySecondary
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
                unselectedTextColor: Color.mycolor.mySecondary
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
                    textEditorXmarkButton(text: editedPost.notes) {
                        editedPost.notes = ""
                    }
                    textEditorXmarkButton(
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
            if focusedField != nil && keyboardManager.shouldShowHideButton {
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
                dismissButton: .default(Text("OK")) {
                }
            )
        case .success:
            if editedPost.draft {
                return Alert(
                    title: Text("Draft saved successfully"),
                    message: Text("Tap OK to continue"),
                    dismissButton: .default(Text("OK")) {
                        isPostDraftSaved = true
                        navigateBack()
                    }
                )
            }
            let title = originalPost == nil
                ? "New Post added successfully"
                : "Post saved successfully"
            return Alert(
                title: Text(title),
                message: Text("Tap OK to continue"),
                dismissButton: .default(Text("OK")) {
                    navigateBack()
                }
            )
            
        default:
            return Alert(title: Text("ERROR"))
        }
    }
    
}

#Preview("Edit post"){
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    
    let vm = PostsViewModel(modelContext: context)
    
    NavigationStack {
        AddEditPostSheet(post: PreviewData.samplePost1)
            .environmentObject(vm)
            .environmentObject(AppCoordinator())

    }
}

#Preview("Add post") {
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    
    let vm = PostsViewModel(modelContext: context)
    
    NavigationStack {
        AddEditPostSheet(post: nil)
            .environmentObject(vm)
            .environmentObject(AppCoordinator())
    }
}

