import http.server
import socketserver
import sys
import os

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8080

class MyHandler(http.server.SimpleHTTPRequestHandler):
    extensions_map = {
        '.html': 'text/html; charset=utf-8',
        '.css': 'text/css; charset=utf-8',
        '.js': 'application/javascript; charset=utf-8',
        '.json': 'application/json; charset=utf-8',
        '.png': 'image/png',
        '.jpg': 'image/jpeg',
        '.svg': 'image/svg+xml',
        '.ico': 'image/x-icon',
        '.gpx': 'application/gpx+xml',
        '.kml': 'application/vnd.google-earth.kml+xml',
        '.kmz': 'application/vnd.google-earth.kmz',
        '': 'application/octet-stream',
    }

    def end_headers(self):
        self.send_header('Cache-Control', 'no-cache')
        super().end_headers()

os.chdir(os.path.dirname(os.path.abspath(__file__)))

with socketserver.TCPServer(("", PORT), MyHandler) as httpd:
    print(f"Server running at http://localhost:{PORT}/spot-studio.html")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
