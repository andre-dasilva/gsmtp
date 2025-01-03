# smtp

[![Package Version](https://img.shields.io/hexpm/v/smtp)](https://hex.pm/packages/smtp)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/smtp/)

```sh
gleam add smtp
```
```gleam
import smtp

pub fn main() {
  // TODO: An example of the project in use
}
```

Further documentation can be found at <https://hexdocs.pm/smtp>.

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
