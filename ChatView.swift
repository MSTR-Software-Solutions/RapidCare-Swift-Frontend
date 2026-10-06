import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var draft: String = ""

    let userId: Int  // pass in the logged-in user's ID

    var body: some View {
        VStack(spacing: 0) {
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            messageBubble(message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let lastId = viewModel.messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            HStack {
                TextField("Type a message...", text: $draft)
                    .textFieldStyle(.roundedBorder)
                    .disabled(viewModel.isSending)

                Button {
                    let text = draft
                    draft = ""
                    Task { await viewModel.sendMessage(text) }
                } label: {
                    if viewModel.isSending {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                    }
                }
                .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isSending)
            }
            .padding()
        }
        .navigationTitle(viewModel.session?.title ?? "RapidCare Assistant")
        
        }
    }

    @ViewBuilder
    private func messageBubble(_ message: ChatMessage) -> some View {
        HStack {
            if message.messageSender == .user {
                Spacer(minLength: 40)
            }

            Text(message.content)
                .padding(10)
                .background(message.messageSender == .bot ? Color(.systemGray5) : Color.blue)
                .foregroundColor(message.messageSender == .bot ? .primary : .white)
                .cornerRadius(12)

            if message.messageSender == .bot {
                Spacer(minLength: 40)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.messageSender == .bot ? .leading : .trailing)
    }

