//
//  EditCard.swift
//  SelfLearningENApp2
//
//  Created by Andrey Efimov on 04.04.2025.
//

import SwiftUI
import SwiftData

struct AddEditPostView: View {
    
    // MARK: - Dependencies

    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var keyboardManager = KeyboardManager()
   
    private let hapticManager = HapticService.shared
    
    // MARK: - State
    
    @State private var editedPost: Post
    @State private var isPostDraftSaved = false
    @State private var isShowingExitConfirmation = false
    @State private var urlTrigger = true
    @State private var showAlert = false
    @State private var alertType: AlertType?
    
    @FocusState private var focusedField: PostFields?
    @State private var focusedFieldSaved: PostFields?
    
    // MARK: - Properties
    
    private let originalPost: Post?
    private let copyOfThePost: Post

    // MARK: - Constants
    
    private let sectionBackground = Color.mycolor.mySectionBackground
    private let sectionCornerRadius: CGFloat = 8
    private let fontSubheader: Font = .caption
    private let fontTextInput: Font = .callout
    private let colorSubheader = Color.mycolor.myAccent.opacity(0.5)
    
    private let startingDate: Date = Calendar.current.date(from: DateComponents(year: 2019)) ?? Date.distantPast
    private let endingDate: Date = .now
    
    // MARK: - Computed Properties
    
    private var viewTitle: String {
        originalPost == nil ? "Add" : "Edit"
    }
    
    private var hasNoChanges: Bool {
        editedPost.isEqual(to: copyOfThePost)
    }
    
    private var bindingPostDate: Binding<Date> {
        Binding(
            get: { editedPost.postDate ?? Date() },
            set: { editedPost.postDate = $0 }
        )
    }
    
    // MARK: - Alert Type
    
    enum AlertType {
        case success
        case error(title: String, message: String, field: PostFields?)
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
            let template = Post(origin: .local, draft: true)
            _editedPost = State(initialValue: template.copy())
            copyOfThePost = template.copy()
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
                    notesSection
                }
                .foregroundStyle(Color.mycolor.myAccent)
                .padding(.horizontal, 8)
            }
            .navigationTitle(viewTitle)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .background(Color.mycolor.myBackground)
            .toolbar { toolbar }
            .overlay { hideKeybordButton }
            .overlay { exitConfirmationOverlay }
            .opacity(isShowingExitConfirmation ? 0.5 : 1.0)
            .alert(isPresented: $showAlert) { alert }
            .onAppear { focusedField = .postTitle }
        }
    }
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            CircleStrokeButtonView(iconName: "checkmark", isShownCircle: false) {
                handleSave()
            }
            .disabled(isShowingExitConfirmation)
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            CircleStrokeButtonView(
                iconName: "xmark",
                imageColorPrimary: Color.mycolor.myRed,
                isShownCircle: false
            ) {
                handleCancel()
            }
            .disabled(isShowingExitConfirmation)
        }
    }

    // MARK: - Actions
    
    private func handleSave() {
        if hasNoChanges {
            // If it is draft - save it as not draft -> .draft = false
            if editedPost.draft == true {
                editedPost.draft = false
                checkAndSave()
            } else {
                // If it is not draft - just exit
                navigateBack()
            }
        } else {
            // Drop draft -> .draft = false and Check&Save the post
            editedPost.draft = false
            checkAndSave()
        }
    }
    
    // MARK: - Actions

    private func handleCancel() {
        if hasNoChanges {
            navigateBack()
        } else {
            withAnimation(.easeInOut) {
                isShowingExitConfirmation = true
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
        
    private func checkAndSave() {
        guard validatePost() else { return }
        
        if let originalPost {
            originalPost.update(with: editedPost)
            vm.updatePost()
        } else {
            vm.addPost(editedPost)
        }
        
        alertType = .success
        showAlert = true
    }
    
    
    private func validatePost() -> Bool {
        if editedPost.title.count < 3 {
            showError(
                title: "The Title must contain at least 3 characters.",
                message: "Please correct the Title.",
                field: .postTitle
            )
            return false
        }
        
        if editedPost.author.count < 2 {
            showError(
                title: "The Author must contain at least 2 characters.",
                message: "Please correct the Author.",
                field: .author
            )
            return false
        }
        
        if vm.checkNewPostForUniqueTitle(editedPost.title, editingPostId: originalPost?.id) {
            showError(
                title: "The Title must be unique.",
                message: "Please correct the Title.",
                field: .postTitle
            )
            return false
        }
        
        return true
    }

    
    private func showError(title: String, message: String, field: PostFields?) {
        alertType = .error(title: title, message: message, field: field)
        showAlert = true
    }

    // MARK: - Alert

    private var alert: Alert {
        switch alertType {
        case .error(let title, let message, let field):
            if editedPost.draft { editedPost.draft = false }
            return Alert(
                title: Text(title),
                message: Text(message),
                dismissButton: .default(Text("OK")) {
                    focusedField = field
                }
            )
            
        case .success:
            let title = editedPost.draft
            ? "Draft saved successfully"
            : (originalPost == nil ? "New Post added successfully" : "Post saved successfully")
            
            return Alert(
                title: Text(title),
                message: Text("Tap OK to continue"),
                dismissButton: .default(Text("OK")) {
                    if editedPost.draft { isPostDraftSaved = true }
                    navigateBack()
                }
            )
        case .none:
            return Alert(title: Text("ERROR"))
        }
    }
    
    // MARK: - Exit Confirmation
    
    @ViewBuilder
    private var exitConfirmationOverlay: some View {
        if isShowingExitConfirmation {
            exitConfirmation
                .transition(.move(edge: .bottom))
        }
    }

    private var exitConfirmation: some View {
        ZStack {
            Color.mycolor.myAccent.opacity(0.001)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    isShowingExitConfirmation = false
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
                        isShowingExitConfirmation = false
                        checkAndSave()
                        hapticManager.impact(style: .light)
                    }
                
                ClearCupsuleButton(
                    primaryTitle: "Cancel",
                    primaryTitleColor: Color.mycolor.myAccent) {
                        focusedField = focusedFieldSaved
                        isShowingExitConfirmation = false
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
    
    // MARK: - Keyboard Button
    
    @ViewBuilder
    private var hideKeybordButton: some View {
        if focusedField != nil && keyboardManager.shouldShowHideButton {
            VStack {
                Spacer()
                HStack {
                    CircleStrokeButtonView(
                        iconName: "keyboard.chevron.compact.down",
                        iconFont: .title2,
                        imageColorPrimary: Color.mycolor.myBlue,
                        widthIn: 55,
                        heightIn: 55
                    ) {
                        focusedField = nil
                    }
                    .padding(.bottom, 16)
                }
            }
        }
        
    }

    // MARK: - Sections
    
    private var titleSection: some View {
        FormSection(title: "Title") {
            HStack(spacing: 0) {
                TextField("", text: $editedPost.title)
                    .font(fontTextInput)
                    .padding(.leading, 5)
                    .frame(height: 50)
                    .focused($focusedField, equals: .postTitle)
                    .onSubmit {focusedField = .intro }
                    .submitLabel(.next)
                
                clearButton(for: editedPost.title) {
                    editedPost.title = ""
                }
            }
        }
    }
    
    private var introSection: some View {
        FormSection(title: "Intro") {
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
                    clearButton(for: editedPost.intro) {
                        editedPost.intro = ""
                    }
                    
                    nextFieldButton(visible: !editedPost.intro.isEmpty) {
                        focusedField = .author
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
        }
    }
    
    private var authorSection: some View {
        FormSection(title: "Author") {
            HStack(spacing: 0) {
                TextField("", text: $editedPost.author)
                    .font(fontTextInput)
                    .padding(.leading, 5)
                    .frame(height: 50)
                    .autocorrectionDisabled(true) // fixing leaking memory
                    .focused($focusedField, equals: .author)
                    .onSubmit {focusedField = .urlString }
                    .submitLabel(.next)
                
                clearButton(for: editedPost.author) {
                    editedPost.author = ""
                }
            }
        }
    }

    private var urlSection: some View {
        FormSection(title: "URL") {
          
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
                        
                        clearButton(for: editedPost.urlString) {
                            editedPost.urlString = Constants.urlStart
                        }
                    }
                    .opacity(urlTrigger ? 0 : 1)
                }
            }
           
        }
    }

    private var postDateSection: some View {
        FormSection(title: "Post Date") {
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

                if editedPost.postDate != nil {
                    DatePicker(
                        "",
                        selection: bindingPostDate,
                        in: startingDate...endingDate,
                        displayedComponents: .date
                    )
                    .tint(Color.mycolor.myBlue)
                    .padding(.trailing, 8)
                    .datePickerStyle(.compact)
                }
            }
        }
    }

    private var typeSection: some View {
        FormSection(title: "Post Type") {
            UnderlineSermentedPickerNotOptional(
                selection: $editedPost.postType,
                allItems: PostType.allCases,
                titleForCase: { $0.displayName },
                selectedTextColor: Color.mycolor.myBlue,
                unselectedTextColor: Color.mycolor.mySecondary
            )
            .padding(.horizontal, 8)
            .frame(height: 50)
        }
    }

    private var platformSection: some View {
        FormSection(title: "Platform") {
            UnderlineSermentedPickerNotOptional(
                selection: $editedPost.postPlatform,
                allItems: Platform.allCases,
                titleForCase: { $0.displayName },
                selectedTextColor: Color.mycolor.myBlue,
                unselectedTextColor: Color.mycolor.mySecondary
            )
            .padding(.horizontal, 8)
            .frame(height: 50)
        }
    }
    
    private var studyLevelSection: some View {
        FormSection(title: "Study Level") {
            UnderlineSermentedPickerNotOptional(
                selection: $editedPost.studyLevel,
                allItems: StudyLevel.allCases,
                titleForCase: { $0.displayName },
                selectedTextColor: Color.mycolor.myBlue,
                unselectedTextColor: Color.mycolor.mySecondary
            )
            .padding(.horizontal, 8)
            .frame(height: 50)
        }
    }
    

    private var notesSection: some View {
        FormSection(title: "Notes") {
            HStack(spacing: 0) {
                TextEditor(text: $editedPost.notes)
                    .font(fontTextInput)
                    .frame(minHeight: 200)
                    .scrollContentBackground(.hidden)
                    .focused($focusedField, equals: .additionalInfo)
                    .submitLabel(.return)
                
                VStack {
                    clearButton(for: editedPost.notes) {
                        editedPost.notes = ""
                    }
                    
                    nextFieldButton(visible: !editedPost.notes.isEmpty) {
                        focusedField = nil
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private func clearButton(for text: String, action: @escaping () -> Void) -> some View {
        if !text.isEmpty {
            Button(action: action) {
                Image(systemName: "xmark")
                    .foregroundStyle(Color.mycolor.myRed)
            }
            .frame(width: 50, height: 50)
            .background(.black.opacity(0.001))
        }
    }
    
    @ViewBuilder
    private func nextFieldButton(visible: Bool, action: @escaping () -> Void) -> some View {
        if visible {
            Button(action: action) {
                Image(systemName: "arrow.turn.right.down")
                    .foregroundStyle(Color.mycolor.myBlue)
            }
            .frame(width: 50, height: 50)
            .background(.black.opacity(0.001))
        }
    }

}


// MARK: - Form Section Component

struct FormSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    private let sectionBackground = Color.mycolor.mySectionBackground
    private let sectionCornerRadius: CGFloat = 8
    private let fontSubheader: Font = .caption
    private let colorSubheader = Color.mycolor.myAccent.opacity(0.5)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .textCase(.uppercase)
                .sectionSubheaderFormater(
                    fontSubheader: fontSubheader,
                    colorSubheader: colorSubheader
                )
            
            content
                .background(
                    sectionBackground,
                    in: RoundedRectangle(cornerRadius: sectionCornerRadius)
                )
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
        AddEditPostView(post: PreviewData.samplePost1)
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
        AddEditPostView(post: nil)
            .environmentObject(vm)
            .environmentObject(AppCoordinator())
    }
}

