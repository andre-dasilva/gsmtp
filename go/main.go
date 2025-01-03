package main

import (
	"fmt"
	"net/mail"
	"net/smtp"
	"strings"
)

var host = "127.0.0.1"
var port = "25"
var addr = host + ":" + port

func main() {
	fromName := "Testing"
	fromEmail := "test@example.com"
	toNames := []string{"Ted"}
	toEmails := []string{"andre@localhost"}
	subject := "This is the subject of your email"
	body := "adsfasdf"
	toAddresses := []string{}

	for i := range toEmails {
		to := mail.Address{Name: toNames[i], Address: toEmails[i]}
		toAddresses = append(toAddresses, to.String())
	}

	toHeader := strings.Join(toAddresses, ", ")
	from := mail.Address{Name: fromName, Address: fromEmail}
	fromHeader := from.String()
	subjectHeader := subject
	header := make(map[string]string)
	header["To"] = toHeader
	header["From"] = fromHeader
	header["Subject"] = subjectHeader
	header["Content-Type"] = `text/html; charset="UTF-8"`
	msg := ""

	for k, v := range header {
		msg += fmt.Sprintf("%s: %s\r\n", k, v)
	}

	msg += "\r\n" + body
	bMsg := []byte(msg)
	// Send using local postfix service
	c, err := smtp.Dial(addr)

	if err != nil {
		return
	}

	defer c.Close()
	if err = c.Mail(fromHeader); err != nil {
		return
	}

	for _, addr := range toEmails {
		if err = c.Rcpt(addr); err != nil {
			return
		}
	}

	w, err := c.Data()
	if err != nil {
		return
	}
	_, err = w.Write(bMsg)
	if err != nil {
		return
	}

	err = w.Close()
	if err != nil {
		return
	}

	err = c.Quit()
	// Or alternatively, send with remote service like Amazon SES
	// err = smtp.SendMail(addr, auth, fromEmail, toEmails, bMsg)
	// Handle response from local postfix or remote service
	if err != nil {
		return
	}
}
