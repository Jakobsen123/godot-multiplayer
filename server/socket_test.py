#!/usr/bin/env python3
"""Send test packets to a UDP server.

Usage:
    python3 test_udp.py                 # send a few default messages
    python3 test_udp.py "hi" "there"    # send your own messages
    python3 test_udp.py -i              # interactive: each line is a packet
"""

import socket
import sys
import time

HOST = "172.20.128.28"  # IPv4 on purpose: server binds AF_INET
PORT = 8000


def send(sock, msg):
    sock.sendto(msg.encode(), (HOST, PORT))
    print(f"Sent {len(msg)} bytes: {msg!r}")


def main():
    args = sys.argv[1:]
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
        if args == ["-i"]:
            print(f"Interactive mode -> {HOST}:{PORT} (Ctrl+C to quit)")
            try:
                for line in sys.stdin:
                    send(sock, line.rstrip("\n"))
            except KeyboardInterrupt:
                print()
            return

        messages = args or ["hello", "second packet", "x" * 1000]
        for msg in messages:
            send(sock, msg)
            time.sleep(0.1)


if __name__ == "__main__":
    main()
