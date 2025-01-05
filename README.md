# gsmtp

SMTP Client for Gleam

[![Package Version](https://img.shields.io/hexpm/v/gsmtp)](https://hex.pm/packages/gsmtp)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gsmtp/)

Further documentation can be found at <https://hexdocs.pm/gsmtp>.

## RFC

* SMTP: https://datatracker.ietf.org/doc/html/rfc5321
* OLD SMTP: https://datatracker.ietf.org/doc/html/rfc821
* Auth: https://datatracker.ietf.org/doc/html/rfc4616

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
    |> builder.from_email("send@gleam.com")
    |> builder.to_emails(["receive@gleam.com"])
    |> builder.subject("Test Gleam E-Mail")
    |> builder.body("Mail from Gleam")
    |> builder.create()

  let auth = Some(#("testuser", "start123"))

  let assert Ok(Nil) =
    smtp.send(host: "127.0.0.1", port: 2525, auth: auth, message: message)
}
```

## TODO

- [X] Plain Auth
- [X] Extensions
- [ ] TLS (might be a bigger thing...)
- [ ] Tests
- [ ] Error handling
- [ ] Better docs
- [ ] Cleanup API


## Development

Use [smtp4dev](https://github.com/rnwood/smtp4dev) as a dev SMTP server

```
docker compose up
```

Make sure to setup postfix to send mails only locally

For just simple SMTP command tests you can use telnet

```sh
telnet localhost 2525
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

