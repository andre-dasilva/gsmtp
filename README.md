# gsmtp

SMTP Client for gleam

[![Package Version](https://img.shields.io/hexpm/v/smtp)](https://hex.pm/packages/gsmtp)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gsmtp/)

```sh
gleam add gsmtp
```

Further documentation can be found at <https://hexdocs.pm/gsmtp>.

## Development

Setup postfix (ubuntu)

```sh
sudo apt install postfix
```

Make sure to send mails local only

For a working smtp client see the go/ directory.

And to test it run

```sh
go run go/main.go
```

To test the gleam project run

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
