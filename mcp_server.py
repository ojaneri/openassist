#!/usr/bin/env python3
import socket, threading
HOST='0.0.0.0'
PORT=65432

def handle_client(conn):
    with conn:
        conn.sendall(b'Welcome to MCP server!')
        while True:
            data = conn.recv(1024)
            if not data: break
            conn.sendall(data)

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen()
    print(f'Server listening on {HOST}:{PORT}')
    while True:
        conn, addr = s.accept()
        threading.Thread(target=handle_client, args=(conn,)).start()
