import builder
import gleam/bit_array
import gleam/int
import gleam/list
import gleam/option.{type Option, Some}
import gleam/result
import gleam/string
import logging
import mug

pub type Error {
  TcpError(mug.Error)
  InvalidServerCodeError(code: String, expected: Int)
}

fn tcp_connect(host, port, timeout) {
  mug.new(host, port: port)
  |> mug.timeout(milliseconds: timeout)
  |> mug.connect()
  |> result.map_error(TcpError)
}

fn tcp_send(socket, message) {
  logging.log(logging.Debug, "CLIENT: " <> message)

  mug.send(socket, <<message:utf8>>)
  |> result.map_error(TcpError)
}

fn tcp_receive(socket, timeout) {
  use packet <- result.try(
    mug.receive(socket, timeout_milliseconds: timeout)
    |> result.map_error(TcpError),
  )

  let assert Ok(packet_str) = bit_array.to_string(packet)
  logging.log(logging.Debug, "SERVER: " <> packet_str)

  Ok(packet)
}

fn check_server_code(expected_code: Int, response: BitArray) {
  let assert Ok(response_str) = bit_array.to_string(response)

  let server_code = string.slice(from: response_str, at_index: 0, length: 3)

  use parsed_code <- result.try(
    int.parse(server_code)
    |> result.map_error(fn(_) {
      InvalidServerCodeError(server_code, expected_code)
    }),
  )

  case parsed_code == expected_code {
    True -> Ok(Nil)
    False -> Error(InvalidServerCodeError(server_code, expected_code))
  }
}

fn cmd(socket, expected_code, message) -> Result(BitArray, Error) {
  use _ <- result.try(tcp_send(socket, message <> "\r\n"))

  use packet <- result.try(tcp_receive(socket, 500))

  use _ <- result.try(check_server_code(expected_code, packet))

  Ok(packet)
}

fn opening_message(socket, timeout) {
  use packet <- result.try(tcp_receive(socket, timeout))
  check_server_code(220, packet)
}

fn find_extension(response) {
  let try_split_once = fn(extension, delimiter) {
    string.split_once(extension, delimiter)
    |> result.map(fn(extension) { extension.1 })
  }

  let assert Ok(response_str) = bit_array.to_string(response)

  let extensions =
    string.split(response_str, "\n")
    |> list.drop(1)
    |> list.map(fn(extension) {
      try_split_once(extension, "-")
      |> result.or(try_split_once(extension, " "))
    })
    |> list.filter_map(fn(x) { x })

  Ok(extensions)
}

fn has_extension(extensions, search) {
  list.find(extensions, fn(extension) { string.starts_with(extension, search) })
  |> result.is_ok
}

fn ehlo(socket, host) {
  case cmd(socket, 250, "EHLO " <> host) {
    Ok(response) -> {
      find_extension(response)
    }
    Error(_) -> {
      helo(socket, host)
      |> result.map(fn(_) { [] })
    }
  }
}

fn helo(socket, host) {
  cmd(socket, 250, "HELO " <> host)
}

fn auth_plain(socket, extensions, auth: Option(#(String, String))) {
  let has_auth_extension = has_extension(extensions, "AUTH")

  case has_auth_extension, auth {
    True, Some(#(user, password)) -> {
      let user_and_password = "\u{0000}" <> user <> "\u{0000}" <> password
      let base64_encoded =
        bit_array.base64_encode(<<user_and_password:utf8>>, True)

      cmd(socket, 235, "AUTH PLAIN " <> base64_encoded)
    }
    _, _ -> Ok(<<>>)
  }
}

fn mail_from(socket, from) {
  cmd(socket, 250, "MAIL FROM:<" <> from <> ">")
}

fn rcpt_to(socket, to) {
  cmd(socket, 250, "RCPT TO:<" <> string.join(to, ",") <> ">")
}

fn data(socket) {
  cmd(socket, 354, "DATA")
}

fn data_body(socket, message: builder.Message) {
  let body =
    ""
    |> string.append("Subject: " <> message.subject <> "\r\n")
    |> string.append("From: " <> message.from <> "\r\n")
    |> string.append("To: " <> string.join(message.to, ",") <> "\r\n")
    |> string.append("\r\n")
    |> string.append(message.body)
    |> string.append("\r\n.")

  cmd(socket, 250, body)
}

fn quit(socket) {
  cmd(socket, 221, "QUIT")
}

fn log_message(host, port, message: builder.Message) {
  logging.log(logging.Debug, "SENDING MAIL")
  logging.log(logging.Debug, "HOST: " <> host <> ":" <> port |> int.to_string)
  logging.log(logging.Debug, "FROM: " <> message.from)
  logging.log(logging.Debug, "TO: " <> string.join(message.to, ", "))
  logging.log(logging.Debug, "SUBJECT: " <> message.subject)
  logging.log(logging.Debug, "BODY: " <> message.body)
}

pub fn send(
  host host: String,
  port port: Int,
  auth auth: Option(#(String, String)),
  message message: builder.Message,
) {
  log_message(host, port, message)

  let timeout = 500

  use socket <- result.try(tcp_connect(host, port, timeout))

  use _ <- result.try(opening_message(socket, timeout))

  use extensions <- result.try(ehlo(socket, "localhost"))

  use _ <- result.try(auth_plain(socket, extensions, auth))

  use _ <- result.try(mail_from(socket, message.from))
  use _ <- result.try(rcpt_to(socket, message.to))
  use _ <- result.try(data(socket))
  use _ <- result.try(data_body(socket, message))
  use _ <- result.try(quit(socket))

  Ok(Nil)
}
