import http.server
import socketserver
import os
import sys
import signal

class CustomHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=os.getcwd(), **kwargs)

def signal_handler(sig, frame):
    print("Shutting down server...")
    sys.exit(0)

if len(sys.argv) < 2:
    print("Usage: python3 script.py <directory_to_serve>")
    sys.exit(1)

DIRECTORY = sys.argv[1]

if not os.path.isdir(DIRECTORY):
    print(f"Error: '{DIRECTORY}' is not a valid directory.")
    sys.exit(1)

PORT = 8000

# Set up signal handler for SIGINT (Ctrl+C)
signal.signal(signal.SIGINT, signal_handler)

# Create and start the server
with socketserver.TCPServer(("", PORT), CustomHandler) as httpd:
    print("Serving at port", PORT)
    os.chdir(DIRECTORY)
    httpd.serve_forever()

