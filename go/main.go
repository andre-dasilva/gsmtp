package main

import (
	"fmt"
	"net/smtp"
	"strings"
)

var host = "127.0.0.1"
var port = "2525"
var addr = host + ":" + port

func main() {
	fromEmail := "send@go.com"
	toEmails := []string{"receive@go.com"}
	subject := "Test Go E-Mail"
	body := "Mail from Go"

	toHeader := strings.Join(toEmails, ", ")
	subjectHeader := subject
	header := make(map[string]string)
	header["To"] = toHeader
	header["From"] = fromEmail
	header["Subject"] = subjectHeader
	msg := ""

	for k, v := range header {
		msg += fmt.Sprintf("%s: %s\r\n", k, v)
	}

	msg += "\r\n" + body

	bMsg := []byte(msg)

	auth := smtp.PlainAuth("", "testuser", "start123", host)

	err := smtp.SendMail(addr, auth, fromEmail, toEmails, bMsg)

	fmt.Printf("%v", err)
}
