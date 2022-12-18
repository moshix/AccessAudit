package main

import (
	"bufio"
	"fmt"
	"net"
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
	}

	// Close the connection when the loop is done
	conn.Close()
}

