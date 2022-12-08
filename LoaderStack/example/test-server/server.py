#!/usr/bin/env python
"""
Very simple HTTP server in python.
https://gist.github.com/bradmontgomery/2219997
Usage::
    ./dummy-web-server.py [<port>]

Send a GET request::
    curl http://localhost

Send a HEAD request::
    curl -I http://localhost

Send a POST request::
    curl -d "foo=bar&bin=baz" http://localhost

"""
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
import SocketServer
import time
import os.path

class S(BaseHTTPRequestHandler):
    def _set_headers(self,code):
        self.send_response(code)
        #self.send_header("Access-Control-Allow-Origin","*")
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        print( "Headers" )

    def do_GET(self):
        print(self.client_address , self.command, self.path)
        if os.path.isfile(os.path.abspath('./'+self.path)):
          self._set_headers(200)
          time.sleep(1) # imitate network delay
          f = open( './'+self.path , 'r')
          self.wfile.write( f.read() )
        else:
          self.send_response(404)
          #self._set_headers(404)
          #self.wfile.write("<html><body>"+os.path.abspath('./wsdl/'+self.path)+"</body></html>")

    def do_HEAD(self):
        print 'Head'
        self._set_headers(200)

    def do_POST(self):
        payload = self.rfile.read(int(self.headers['Content-Length']))
        payload = self.command+' path: '+self.path+' payload: '+payload
        print(payload )
        self._set_headers(200)
        #time.sleep(5/1000.0)
        #time.sleep(1)
        #self.send_response(200)
        self.wfile.write(payload)

def run(server_class=HTTPServer, handler_class=S, port=8000):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print 'Starting httpd...',server_address
    httpd.serve_forever()

if __name__ == "__main__":
    from sys import argv

    if len(argv) == 2:
        run(port=int(argv[1]))
    else:
        run()
