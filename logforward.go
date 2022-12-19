package main

import (
	"bufio"
	"context"
	"fmt"
	"net"
	"regexp"
	"strconv"
	"strings"
	"time"

	"github.com/codenotary/immudb/pkg/client"
	"github.com/codenotary/immudb/pkg/client/clienttest"
	"github.com/codenotary/immudb/pkg/immuos"
)

// Copyright 2021 by moshix
// AccessAudit log lines forwarder to immudb
// Receives log lines from rsyslog and then stores them
//  in the 'Audit' database inside immudb which runs in a container

func main() {
	// Listen for incoming connections on port 514
	ln, err := net.Listen("tcp", ":3434")
	if err != nil {
		// Handle error
		return
	}
	defer ln.Close()

	// Accept incoming connections and handle them in a separate goroutine
	for {
		conn, err := ln.Accept()
		if err != nil {
			// Handle error
			continue
		}
		go handleConnection(conn)
	}
}

func handleConnection(conn net.Conn) {
	// Use bufio to read data from the connection as a stream of lines
	scanner := bufio.NewScanner(conn)
	for scanner.Scan() {
		// Process the line of data
		line := scanner.Text()
		fmt.Println(line)
		parseRsyslogLine(line) // now we parse it
	}

	// Close the connection when the loop is done
	conn.Close()
}

type RsyslogLine struct {
	Timestamp time.Time
	Hostname  string
	Appname   string
	Pid       int
	Message   string
}

func parseRsyslogLine(line string) (*RsyslogLine, error) {
	// Use a regular expression to extract the fields from the header
	re := regexp.MustCompile(`<(\d+)>([^ ]+) ([^ ]+) ([^\[]+)\[(\d+)\]: (.*)`)
	match := re.FindStringSubmatch(line)
	if match == nil {
		return nil, fmt.Errorf("invalid rsyslog line: %s", line)
	}

	// Parse the timestamp
	timestamp, err := time.Parse("Jan _2 15:04:05", match[2])
	if err != nil {
		return nil, fmt.Errorf("invalid timestamp: %s", match[2])
	}

	// Parse the PID
	pid, err := strconv.Atoi(match[5])
	if err != nil {
		return nil, fmt.Errorf("invalid PID: %s", match[5])
	}

	// Extract the hostname, appname, and message
	hostname := match[3]
	appname := strings.TrimSuffix(match[4], ":")
	message := match[6]

	// Return the parsed fields as a RsyslogLine struct
	return &RsyslogLine{
		Timestamp: timestamp,
		Hostname:  hostname,
		Appname:   appname,
		Pid:       pid,
		Message:   message,
	}, nil
}
func immudbwrite() {
	// Create a new immudb client
	immuClient, err := client.NewImmuClient(client.DefaultOptions())
	if err != nil {
		// Handle error
		return
	}
	defer immuClient.Close()

	// Connect to the immudb server
	err = immuClient.Connect(context.Background())
	if err != nil {
		// Handle error
		return

		// Set the key and value to be written to immudb
		key := []byte("key")
		value := []byte("value")

		// Write the key-value pair to immudb
		err = immuClient.Set(context.Background(), key, value)
		if err != nil {
			// Handle error
			return
		}
		fmt.Println("Key-value pair written to immudb")
	}
}

// RSYSLOG lines are like this:
// <PRIORITY>TIMESTAMP HOSTNAME APP-NAME
// <6>Oct 22 10:11:12 hostname appname[1234]:
//   The PRIORITY field is a numerical value representing the severity of the message.
//   The TIMESTAMP is the date and time the message was logged, in a standardized format.
//   The HOSTNAME is the hostname of the machine where the message was generated.
//   The APP-NAME is the name of the application that generated the message.
