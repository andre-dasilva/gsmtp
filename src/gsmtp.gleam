import builder
import logging
import smtp

pub fn main() {
  logging.configure()
  logging.set_level(logging.Debug)

  let message =
    builder.new_builder()
    |> builder.from_email("test@example.com")
    |> builder.to_emails(["andre@localhost"])
    |> builder.subject("SMTP Mail from gleam")
    |> builder.body("This is a test mail from gleam")
    |> builder.create()

  let assert Ok(Nil) = smtp.send("127.0.0.1", 25, message)
}
