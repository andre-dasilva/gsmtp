import gleam/io
import gleam/string

pub fn main() {
  let host = "127.0.0.1"
  let port = "25"
  let addr = host <> ":" <> port

  let from = "test@example.com"
  let to = ["andre@localhost"]
  let subject = "SMTP Mail from gleam"
  let body = "This is a test mail from gleam"

  io.println("Sending mail from")
  io.println("HOST: " <> addr)
  io.println("FROM: " <> from)
  io.println("TO: " <> string.join(to, ", "))
  io.println("SUBJECT: " <> subject)
  io.println("BODY: " <> body)
}
