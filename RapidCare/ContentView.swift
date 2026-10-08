import SwiftUI

#Preview {
    ContentView()
}

struct ContentView: View {
    @State private var selectedTab: Int = 0
    @State private var isShowingHistoryDrawer: Bool = false
    
    // Search by Case Name state
    @State private var caseSearchText: String = ""
    @State private var searchedCases: [EmergencyCase] = []
    @State private var isSearchingCase: Bool = false
    @State private var hasSearched: Bool = false
    @State private var selectedCaseDetail: EmergencyCase? = nil

    // Dedicated state for AI Assistant
    @StateObject private var chatViewModel = ChatViewModel()
    @State private var chatInput: String = ""
    
    @EnvironmentObject private var authManager: AuthManager


    var body: some View {
            if authManager.currentUser == nil {
                AuthView()
            } else {
                TabView(selection: $selectedTab) {
                    // 0: Home
                    landingPageView
                        .tabItem { Label("Home", systemImage: "house.fill") }
                        .tag(0)

                    // 1: Emergency Cases
                    EmergencyCaseView()
                        .tabItem { Label("Emergency", systemImage: "light.beacon.max.fill") }
                        .tag(1)

                    // 2: AI Assistant
                    assistantChatView
                        .tabItem { Label("Assistant", systemImage: "bubble.left.and.bubble.right.fill") }
                        .tag(2)

                    // 3: Profile Tab
                    ProfileView()
                        .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                        .tag(3)
                }
                .tint(RapidCareColor.cerulean)
                .sheet(item: $selectedCaseDetail) { item in
                    CaseDetailSheet(emergencyCase: item)
                }
            }
        }

    // MARK: - 1. Landing / Home Tab

    private var landingPageView: some View {
        NavigationStack {
            ZStack {
                RapidCareColor.porcelain
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // 1. Search Bar at Top of Home
                        caseSearchBarSection

                        // 2. Search Results (if user submitted a search)
                        if hasSearched {
                            caseSearchResultsSection
                        }

                        // Critical Action Banner
                        dispatchHeroCard

                        // Quick Hotline Call Buttons
                        hotlineSection

                        // Feature Navigation Cards
                        quickAccessSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                }
            }
            .navigationTitle("RapidCare")
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Case Name Search Bar

    private var caseSearchBarSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(RapidCareColor.onyx.opacity(0.45))

                TextField("Search case by name...", text: $caseSearchText)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.search)
                    .onSubmit {
                        performCaseSearch()
                    }

                if isSearchingCase {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if !caseSearchText.isEmpty {
                    Button {
                        caseSearchText = ""
                        hasSearched = false
                        searchedCases = []
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(RapidCareColor.onyx.opacity(0.35))
                    }
                }

                Button("Search") {
                    performCaseSearch()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(RapidCareColor.cerulean)
                .disabled(caseSearchText.trimmingCharacters(in: .whitespaces).isEmpty || isSearchingCase)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
            )
        }
    }

    // MARK: - Search Results Section

    private var caseSearchResultsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("SEARCH RESULTS (\(searchedCases.count))")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(RapidCareColor.onyx.opacity(0.6))
                Spacer()
                Button("Dismiss") {
                    withAnimation {
                        hasSearched = false
                        searchedCases = []
                    }
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(RapidCareColor.brickEmber)
            }

            if searchedCases.isEmpty {
                HStack {
                    Image(systemName: "doc.text.magnifyingglass")
                        .foregroundStyle(RapidCareColor.onyx.opacity(0.4))
                    Text("No cases found matching \"\(caseSearchText)\"")
                        .font(.subheadline)
                        .foregroundStyle(RapidCareColor.onyx.opacity(0.6))
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                ForEach(searchedCases) { item in
                    Button {
                        selectedCaseDetail = item
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "folder.fill")
                                .font(.title3)
                                .foregroundStyle(RapidCareColor.cerulean)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.displayTitle)
                                    .font(.headline)
                                    .foregroundStyle(RapidCareColor.onyx)
                                Text(item.displayEmergencyType)
                                    .font(.caption)
                                    .foregroundStyle(RapidCareColor.onyx.opacity(0.6))
                            }
                            Spacer()
                            Text(item.displayStatus)
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(RapidCareColor.cerulean.opacity(0.12))
                                .foregroundStyle(RapidCareColor.cerulean)
                                .clipShape(Capsule())

                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(RapidCareColor.onyx.opacity(0.35))
                        }
                        .padding(14)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.pressable)
                }
            }
        }
    }

    private func performCaseSearch() {
        let query = caseSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }

        isSearchingCase = true
        hasSearched = true

        Task {
            do {
                let results = try await EmergencyCaseAPIService.shared.getCasesByCaseName(query)
                print("[Search] Found \(results.count) results")
                await MainActor.run {
                    self.searchedCases = results
                    self.isSearchingCase = false
                }
            } catch {
                print("[Search Error]:", error) // <-- Inspect this in Xcode Console
                await MainActor.run {
                    self.searchedCases = []
                    self.isSearchingCase = false
                }
            }
        }
    }
    // MARK: - Banner & Hotlines

    private var dispatchHeroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "light.beacon.max.fill")
                    .font(.title)
                    .foregroundStyle(.white)
                Spacer()
                Text("24/7 DISPATCH")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Capsule())
            }

            Text("Medical Emergency?")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)

            Text("Instantly notify nearby ambulance fleets and alert designated hospital response teams.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))

            Button {
                selectedTab = 1
            } label: {
                HStack {
                    Image(systemName: "cross.fill")
                    Text("Request Dispatch Now")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(.white)
                .foregroundStyle(RapidCareColor.brickEmber)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: Color.black.opacity(0.15), radius: 6, y: 3)
            }
            .buttonStyle(.pressable)
            .padding(.top, 4)
        }
        .padding(20)
        .background(RapidCareColor.brickEmber)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: RapidCareColor.brickEmber.opacity(0.35), radius: 10, y: 5)
    }

    private var hotlineSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("NATIONAL EMERGENCY HOTLINES")
                .font(.caption.weight(.bold))
                .foregroundStyle(RapidCareColor.onyx.opacity(0.6))

            HStack(spacing: 12) {
                hotlineButton(title: "Ambulance", number: "10177", icon: "cross.circle.fill")
                hotlineButton(title: "Emergency", number: "112", icon: "phone.badge.waveform.fill")
            }
        }
    }

    private func hotlineButton(title: String, number: String, icon: String) -> some View {
        Button {
            if let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(RapidCareColor.cerulean)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(RapidCareColor.onyx.opacity(0.7))
                    Text(number)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(RapidCareColor.onyx)
                }
                Spacer()
            }
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(RapidCareColor.cerulean.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.pressable)
    }

    private var quickAccessSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SERVICES & FIRST AID")
                .font(.caption.weight(.bold))
                .foregroundStyle(RapidCareColor.onyx.opacity(0.6))

            Button {
                selectedTab = 2
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "apple.meditate")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(RapidCareColor.darkCyan)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("AI First-Aid Guidance")
                            .font(.headline)
                            .foregroundStyle(RapidCareColor.onyx)
                        Text("Choking, CPR instructions, bleeding control, and burns.")
                            .font(.caption)
                            .foregroundStyle(RapidCareColor.onyx.opacity(0.6))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(RapidCareColor.onyx.opacity(0.4))
                }
                .padding(14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(RapidCareColor.cerulean.opacity(0.15), lineWidth: 1)
                )
            }
            .buttonStyle(.pressable)

            Button {
                selectedTab = 1
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "list.clipboard.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(RapidCareColor.brickEmber)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Emergency Cases & History")
                            .font(.headline)
                            .foregroundStyle(RapidCareColor.onyx)
                        Text("Track active dispatches and view past hospital alerts.")
                            .font(.caption)
                            .foregroundStyle(RapidCareColor.onyx.opacity(0.6))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(RapidCareColor.onyx.opacity(0.4))
                }
                .padding(14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(RapidCareColor.cerulean.opacity(0.15), lineWidth: 1)
                )
            }
            .buttonStyle(.pressable)
        }
    }

    // MARK: - 2. Emergency Cases Tab

    private var emergencyDispatchTab: some View {
        EmergencyCaseView()
    }

    // MARK: - 3. AI Assistant Tab

    private var assistantChatView: some View {
        NavigationStack {
            ZStack(alignment: .leading) {
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        sessionContent(maxBubbleWidth: geometry.size.width * 0.75)

                        GlassInputBar(
                            text: $chatInput,
                            isSending: chatViewModel.isSending,
                            isSessionActive: true,
                            onSend: sendCurrentInput
                        )
                        .padding(.horizontal, 12)
                        .padding(.bottom, 8)
                    }
                }
                .background(chatBackground)

                if isShowingHistoryDrawer {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                isShowingHistoryDrawer = false
                            }
                        }
                        .transition(.opacity)

                    ChatHistoryDrawer(
                        viewModel: chatViewModel,
                        isOpen: $isShowingHistoryDrawer
                    )
                    .transition(.move(edge: .leading))
                    .zIndex(2)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: isShowingHistoryDrawer)
            .toolbar { chatToolbarContent }
            .toolbarBackground(.visible, for: .navigationBar)
            .alert("Error", isPresented: errorBinding) {
                Button("OK", role: .cancel) { chatViewModel.errorMessage = nil }
            } message: {
                Text(chatViewModel.errorMessage ?? "")
            }
        }
    }

    private var chatBackground: some View {
        GeometryReader { geometry in
            ZStack {
                RapidCareColor.porcelain
                Image("RapidCareMascot")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.95)
                    .opacity(0.08)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.55)
                    .accessibilityHidden(true)
            }
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func sessionContent(maxBubbleWidth: CGFloat) -> some View {
        if chatViewModel.messages.isEmpty {
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 46))
                    .foregroundStyle(RapidCareColor.cerulean)

                Text("How can RapidCare help?")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(RapidCareColor.onyx)

                Text("Ask about first aid steps, triage advice, or CPR guidance.")
                    .font(.subheadline)
                    .foregroundStyle(RapidCareColor.onyx.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                HStack(spacing: 8) {
                    Button("First Aid for Burns") {
                        chatInput = "How do I treat a second-degree burn?"
                    }
                    .buttonStyle(.bordered)

                    Button("CPR Instructions") {
                        chatInput = "Guide me through hands-only CPR."
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.top, 8)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(chatViewModel.messages) { message in
                            MessageBubbleView(message: message, maxBubbleWidth: maxBubbleWidth)
                                .id(message.id)
                        }
                        if chatViewModel.isSending {
                            TypingIndicatorView()
                                .id("typingIndicator")
                        }
                    }
                    .padding(.vertical, 16)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: chatViewModel.messages.count) { _, _ in
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: chatViewModel.isSending) { _, isSending in
                    if isSending {
                        scrollToBottom(proxy: proxy, targetId: "typingIndicator")
                    }
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var chatToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            Button {
                selectedTab = 0
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                    Text("Home")
                }
            }
            .buttonStyle(.pressable)
            .foregroundStyle(RapidCareColor.cerulean)

            Button {
                Task {
                    await chatViewModel.fetchPastSessions()
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isShowingHistoryDrawer.toggle()
                    }
                }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.body.weight(.medium))
            }
            .buttonStyle(.pressable)
            .foregroundStyle(RapidCareColor.onyx)
        }

        ToolbarItem(placement: .principal) {
            Text(chatViewModel.session?.title ?? "RapidCare Assistant")
                .font(.headline.weight(.semibold))
                .foregroundStyle(RapidCareColor.onyx)
                .lineLimit(1)
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                withAnimation {
                    chatViewModel.newChat()
                }
            } label: {
                Image(systemName: "square.and.pencil")
            }
            .buttonStyle(.pressable)
            .foregroundStyle(RapidCareColor.cerulean)
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy, targetId: AnyHashable? = nil) {
        let id = targetId ?? chatViewModel.messages.last?.id
        guard let id else { return }
        withAnimation(.easeOut(duration: 0.25)) {
            proxy.scrollTo(id, anchor: .bottom)
        }
    }

    private func sendCurrentInput() {
        let text = chatInput
        chatInput = ""
        Task { await chatViewModel.sendMessage(text) }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { chatViewModel.errorMessage != nil },
            set: { if !$0 { chatViewModel.errorMessage = nil } }
        )
    }
}

