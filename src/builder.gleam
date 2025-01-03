import gleam/option.{type Option, None, Some}

pub type MessageBuilder {
  MessageBuilder(
    from: Option(String),
    to: Option(List(String)),
    subject: Option(String),
    body: Option(String),
  )
}

pub type Message {
  Message(from: String, to: List(String), subject: String, body: String)
}

pub fn new_builder() {
  MessageBuilder(from: None, to: None, subject: None, body: None)
}

pub fn from_email(message, from: String) {
  MessageBuilder(..message, from: Some(from))
}

pub fn to_emails(message, to: List(String)) {
  MessageBuilder(..message, to: Some(to))
}

pub fn subject(message, subject: String) {
  MessageBuilder(..message, subject: Some(subject))
}

pub fn body(message, body: String) {
  MessageBuilder(..message, body: Some(body))
}

pub fn create(message_builder: MessageBuilder) {
  Message(
    from: message_builder.from |> option.unwrap(""),
    to: message_builder.to |> option.unwrap([]),
    subject: message_builder.subject |> option.unwrap(""),
    body: message_builder.body |> option.unwrap(""),
  )
}
