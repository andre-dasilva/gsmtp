# gsmtp

SMTP Client for Gleam

[![Package Version](https://img.shields.io/hexpm/v/gsmtp)](https://hex.pm/packages/gsmtp)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gsmtp/)

Further documentation can be found at <https://hexdocs.pm/gsmtp>.

## Current state

A simple mail to a SMTP server can be sent

Use it like this

```sh
gleam add gsmtp
```

```gleam
import gsmtp/builder
import gsmtp/smtp
import logging

pub fn main() {
  logging.configure()
  logging.set_level(logging.Debug)

  let message =
    builder.new_builder()
    |> builder.from_email("test@example.com")
    |> builder.to_emails(["user@localhost"])
    |> builder.subject("SMTP Mail from gleam")
    |> builder.body("This is a test mail from gleam")
    |> builder.create()

  let assert Ok(Nil) = smtp.send("127.0.0.1", 25, message)
}
```

## TODO

- [ ] TLS
- [ ] Auth
- [ ] Extensions
- [ ] Tests
- [ ] Error handling
- [ ] Docs
- [ ] Cleanup API


## Development

Setup postfix (ubuntu) for a local SMTP server

```sh
sudo apt install postfix
```

Make sure to setup postfix to send mails only locally

For just simple SMTP command tests you can use telnet

```sh
telnet localhost 25
```

and run the following commands

```sh
HELO localhost
MAIL FROM:<sender@example.com>
RCPT TO:<user@localhost>
DATA
Subject: Test Email
From: sender@example.com
To: user@localhost

This is a test email sent manually.

.
QUIT
```

This is basically what the library does. it opens a TCP connection and runs the commands

Run the following command to see the mails:

```sh
tail -f /var/mail/user
```

To test the gleam smtp client run

```sh
gleam test
```

This project is inspired by the go [smtp](https://pkg.go.dev/net/smtp) package

Thats why there is a working smtp client in the `go/` directory.

Run it with

```sh
go run go/main.go
```

