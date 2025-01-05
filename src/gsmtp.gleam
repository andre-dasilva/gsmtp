import builder
import gleam/option.{Some}
import logging
import smtp

pub fn main() {
  logging.configure()
  logging.set_level(logging.Debug)

  let message =
    builder.new_builder()
    |> builder.from_email("send@gleam.com")
    |> builder.to_emails(["receive@gleam.com"])
    |> builder.subject("Test Gleam E-Mail")
    |> builder.body("Mail from Gleam")
    |> builder.create()

  let auth = Some(#("testuser", "start123"))

  let assert Ok(Nil) =
    smtp.send(host: "127.0.0.1", port: 2525, auth: auth, message: message)
}
