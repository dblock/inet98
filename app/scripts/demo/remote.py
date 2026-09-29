#!/usr/bin/env python3
"""Scripted remote-control session for the demo recording.

Clears the terminal, waits for $DEMO_DIR/go, then connects to the launcher's
admin port and types each command one character at a time so the server's
echo looks like typing. Touches $DEMO_DIR/saver just before sending SAVER.
"""
import os
import socket
import sys
import threading
import time

DEMO_DIR = os.environ.get('DEMO_DIR', '/tmp/inet98demo')
PORT = int(os.environ.get('INET98_PORT', '10895'))

STEPS = [
    (1.5, 'letmein'),
    (2.0, 'db4ever'),
    (2.0, 'HELP'),
    (4.0, "MSG Welcome to INET 98, Palexpo, Geneva!"),
    (5.0, 'HIDE'),
    (3.5, 'SHOW'),
    (3.0, 'STAT'),
    (4.0, 'SAVER'),
    (6.0, 'QUIT'),
]

sys.stdout.write('\033[H\033[2J\033[3J')
sys.stdout.flush()
while not os.path.exists(os.path.join(DEMO_DIR, 'go')):
    time.sleep(0.1)

s = socket.create_connection(('127.0.0.1', PORT))


def reader():
    while True:
        data = s.recv(4096)
        if not data:
            break
        sys.stdout.write(data.decode('latin-1').replace('\r', ''))
        sys.stdout.flush()


threading.Thread(target=reader, daemon=True).start()
print('$ telnet inet-pc-042 895', flush=True)
time.sleep(1)
for delay, line in STEPS:
    time.sleep(delay)
    if line == 'SAVER':
        open(os.path.join(DEMO_DIR, 'saver'), 'w').close()
    for ch in line:
        s.send(ch.encode())
        time.sleep(0.08)
    s.send(b'\r\n')
# Keep the window contents on screen until record.sh closes it.
time.sleep(60)
