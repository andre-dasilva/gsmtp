import builder
import gleam/bit_array
import gleam/int
import gleam/result
import gleam/string
import logging
import mug

pub type Error {
  TcpError(mug.Error)
  MissingServerCodeError
  InvalidServerCodeError(code: String, expected: Int)
}

fn check_server_code(expected_code: Int, response: BitArray) {
  let assert Ok(response_str) = bit_array.to_string(response)

  use #(server_code, _) <- result.try(
    string.split_once(response_str, " ")
    |> result.map_error(fn(_) { MissingServerCodeError }),
  )

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
  logging.log(logging.Debug, "CLIENT: " <> message <> "\n")

  use _ <- result.try(tcp_send(socket, message <> "\n"))

  use packet <- result.try(tcp_receive(socket, 500))

  use _ <- result.try(check_server_code(expected_code, packet))

  Ok(packet)
}

fn tcp_send(socket, message) {
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

fn tcp_connect(host, port, timeout) {
  mug.new(host, port: port)
  |> mug.timeout(milliseconds: timeout)
  |> mug.connect()
  |> result.map_error(TcpError)
}

fn log_sending_info(host, port, message: builder.Message) {
  logging.log(logging.Info, "SENDING MAIL")
  logging.log(logging.Info, "HOST: " <> host <> ":" <> port |> int.to_string)
  logging.log(logging.Info, "FROM: " <> message.from)
  logging.log(logging.Info, "TO: " <> string.join(message.to, ", "))
  logging.log(logging.Info, "SUBJECT: " <> message.subject)
  logging.log(logging.Info, "BODY: " <> message.body)
}

fn setup_data(message: builder.Message) {
  ""
  |> string.append("Subject: " <> message.subject <> "\r\n")
  |> string.append("From: <" <> message.subject <> ">\r\n")
  |> string.append("To: <" <> string.join(message.to, ",") <> ">\r\n")
  |> string.append("\r\n")
  |> string.append(message.body)
  |> string.append("\r\n.\r\n")
}

pub fn send(host: String, port: Int, message: builder.Message) {
  log_sending_info(host, port, message)

  let timeout = 500

  use socket <- result.try(tcp_connect(host, port, timeout))

  use _ <- result.try(tcp_receive(socket, timeout))

  use _ <- result.try(cmd(socket, 250, "HELO localhost"))
  use _ <- result.try(cmd(socket, 250, "MAIL FROM:<" <> message.from <> ">"))
  use _ <- result.try(cmd(
    socket,
    250,
    "RCPT TO:<" <> string.join(message.to, ",") <> ">",
  ))
  use _ <- result.try(cmd(socket, 354, "DATA"))
  use _ <- result.try(cmd(socket, 250, setup_data(message)))
  use _ <- result.try(cmd(socket, 221, "QUIT"))

  Ok(Nil)
}
