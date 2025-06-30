abstract class ChatStates {}

class ChatInitialState extends ChatStates{}

class ChatLoadingProvidersState extends ChatStates{}

class ChatSuccessProvidersState extends ChatStates{}

class ChatErrorProvidersState extends ChatStates{}


class ChatSendMessageLoading extends ChatStates{}

class ChatSendMessageSuccess extends ChatStates{}

class ChatSendMessagError extends ChatStates{}


class ChatGetAllMessagesLoading extends ChatStates{}
class ChatGetAllMessagesSuccess extends ChatStates{}
class ChatGetAllMessagesError extends ChatStates{}


