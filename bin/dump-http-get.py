#!/usr/bin/env python3

import os
import socketserver
import time
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler


class GetHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(HTTPStatus.OK)
        self.send_header("Content-Type", "text/plain")
        self.end_headers()
        self.wfile.write(bytes("GET " + self.path, "UTF-8"))
        print(self.headers, end="")
        if sleep := os.getenv("SLEEP"):
            time.sleep(int(sleep) / 1000)


httpd = socketserver.TCPServer(("", 0), GetHandler)
print("======== Running on http://{}:{} ========".format(*httpd.server_address))
print("(Press CTRL+C to quit)")
try:
    httpd.serve_forever()
except KeyboardInterrupt:
    pass
