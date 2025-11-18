# View360 Chat SDK

A production-ready Flutter SDK for integrating real-time chat functionality powered by View360Chat.

## Overview

The `package` folder contains all the core SDK components for chat integration. This SDK provides:
- Real-time messaging via WebSocket
- Chat session management
- File attachment support
- Bot integration
- Firebase Cloud Messaging (FCM) support
- Local storage for session data

## Structure

```
package/
├── api_service.dart           # Main API service for HTTP requests
├── socket_manager.dart        # WebSocket connection management (Singleton)
├── functions.dart            # Utility functions
├── local_storage.dart        # Local storage management (SharedPreferences)
├── models/
│   ├── view360chatprefs.dart         # Local storage model
│   ├── chat_register_response.dart   # Chat registration response
│   ├── chat_send_response.dart       # Message send response
│   └── chat_list_response.dart       # Message list response
└── README.md                 # This file
```

## Core Components

### 1. ChatService (api_service.dart)
Main service for all chat API operations.

**Key Methods:**
- `createChatSession()` - Initialize new chat sessions
- `sendChatMessage()` - Send messages with optional file attachments
- `fetchMessages()` - Retrieve chat message history
- `notificationToken()` - Update FCM token for push notifications with callbacks

**Notification Token Usage:**
```dart
await chatService.notificationToken(
  token: 'fcm_token_123',
  userId: 'user_456',
  onSuccess: () {
    // FCM token updated successfully
  },
  onError: (error) {
    // Handle FCM token update error
  },
);
```

**Supported File Types:**
- Images: `.jpg`, `.jpeg`, `.png`, `.gif`
- Documents: `.pdf`, `.xlsx`, `.csv`
- Video: `.mp4`

### 2. SocketManager (socket_manager.dart)
Singleton pattern for WebSocket connection management.

**Features:**
- Automatic connection establishment
- Message event listening
- Queue status notifications
- Agent assignment notifications
- Connection lifecycle management
- Automatic reconnection with exponential backoff
- Error and disconnection callbacks

**Usage:**
```dart
SocketManager().connect(
  baseUrl: 'your_base_url',
  onConnected: () {
    // Handle connection success
  },
  onMessage: ({
    required content,
    required senderType,
    required createdAt,
    filePaths,
    required response,
  }) {
    // Handle incoming message
  },
  onError: (error) {
    // Handle socket errors
  },
  onDisconnected: (reason) {
    // Handle disconnection
  },
);
```

### 3. View360ChatPrefs (local_storage.dart)
Static utility class for managing chat session data using SharedPreferences.

**Manages:**
- Chat IDs
- Customer information (name, email, phone)
- Bot status
- Queue status
- Content IDs

### 4. Utility Functions (functions.dart)
- `getMimeType()` - Determine MIME type from file extension
- `generateUniqueId()` - Generate unique message/session IDs
- `getFCMToken()` - Retrieve and register FCM token with error handling

**FCM Token Usage:**
```dart
await getFCMToken(
  userId: 'user123',
  baseUrl: 'your_base_url',
  appId: 'your_app_id',
  onError: (error) {
    // Handle FCM token error
  },
);
```

## Usage Example

```dart
import 'package:madfu_demo/package/api_service.dart';
import 'package:madfu_demo/package/socket_manager.dart';

// Initialize chat service
final chatService = ChatService(
  baseUrl: 'https://your-api.com',
  appId: 'your-app-id',
);

// Create chat session
final registerResponse = await chatService.createChatSession(
  chatContent: 'Hello, I need help',
  customerName: 'John Doe',
  customerEmail: 'john@example.com',
  customerPhone: '+1234567890',
);

// Setup WebSocket for real-time messages
SocketManager().connect(
  baseUrl: 'https://your-api.com',
  onConnected: () {
    print('Connected to chat');
  },
  onMessage: (
    content: String,
    senderType: String,
    createdAt: String,
    filePaths: List<String>?,
    response: dynamic,
  ) {
    // Handle new message
  },
  onError: (error) {
    print('Socket error: $error');
  },
  onDisconnected: (reason) {
    print('Disconnected: $reason');
    // Auto-reconnection is handled automatically
  },
);

// Send message
final sendResponse = await chatService.sendChatMessage(
  chatContent: 'Thanks for your help',
  filePath: ['path/to/file.pdf'],
);

// Fetch message history
final messageList = await chatService.fetchMessages();
```

## Best Practices for SDK Integration

### 1. **Initialization**
- Initialize `ChatService` once during app startup
- Store reference as singleton or provider
- Configure with proper base URL and app ID

### 2. **Connection Management**
- Call `SocketManager().connect()` after successful chat registration
- Handle connection callbacks properly
- Implement proper disconnect on app close

### 3. **Error Handling**
- All API methods return response objects with error states
- Socket manager provides `onError` and `onDisconnected` callbacks
- FCM operations support error callbacks
- Check `success` property before using data
- Handle timeout and network exceptions properly

### 4. **Session Management**
- Save session data using `View360ChatPrefs` methods
- Clear session on logout with `View360ChatPrefs.clear()`
- Remove customer ID when chat ends

### 5. **File Handling**
- Validate file types before sending
- Check file size limits
- Handle upload errors gracefully
- Provide user feedback during upload

### 6. **Performance**
- Reuse `ChatService` instance for multiple operations
- Batch message fetches to reduce API calls
- Implement proper pagination for large message lists
- Cache message data locally when possible

### 7. **Security**
- Never hardcode API credentials
- Use environment variables or secure configuration
- Validate all user inputs
- Implement proper error messages (don't expose backend details)

## Dependencies

```yaml
dependencies:
  http: ^1.1.0
  http_parser: ^4.0.0
  shared_preferences: ^2.0.0
  socket_io_client: ^2.0.0
  firebase_messaging: ^14.0.0
```

## Response Models

### ChatRegisterResponse
```dart
{
  success: bool,
  message: String?,
  isInQueue: bool,
  isOutOfOfficeTime: bool,
  botResponse: Map<String, dynamic>?,
}
```

### ChatSentResponse
```dart
{
  status: bool,
  message: String?,
  error: String?,
  isOutOfOfficeTime: bool?,
  botResponse: Map<String, dynamic>?,
}
```

### ChatListResponse
```dart
{
  success: bool,
  messages: List<ChatMessage>,
  error: String?,
}
```

### ChatMessage
```dart
{
  id: int,
  content: String,
  senderType: String,
  files: List<String>,
  createdAt: String,
  botresponse: Map<String, dynamic>?,
}
```

## Error Handling

The SDK provides descriptive error messages:

- **Network Errors**: "No Internet connection", "Request timed out"
- **HTTP Errors**: "Failed with status {code}: {response}"
- **Format Errors**: "Invalid response format"
- **File Errors**: "Unsupported file extension: {ext}"

## Production Checklist

- ✅ Remove all debug logging (no print statements in production code)
- ✅ Validate API credentials
- ✅ Test all error scenarios with callbacks
- ✅ Implement proper session timeout
- ✅ Test on slow networks
- ✅ Handle offline scenarios with auto-reconnection
- ✅ Reconnection logic with exponential backoff (up to 5 attempts)
- ✅ Test with large files
- ✅ Verify FCM integration with error handling
- ✅ Test bot responses
- ✅ Validate queue handling
- ✅ Test with real backend
- ✅ Handle socket disconnections gracefully
- ✅ Implement error callbacks for all async operations

## Versioning

This SDK follows semantic versioning. Check `pubspec.yaml` for current version.

## Support

For issues or feature requests, contact the View360 Chat support team.
