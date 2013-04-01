from twisted.web.server import Site
from twisted.web.resource import Resource
from twisted.internet import reactor
from PyMouse.pymouse import PyMouse
from twisted.python import log
from sys import stdout
import os
from twisted.internet.protocol import Factory, Protocol


class MouseHandler(Protocol):
	def connectionMade(self):
		print self
	def connectionLost(self,reason):
		print 'lost connection'

	originPosition = (0,0)
	def dataReceived(self, data):
		packets = data.split('end')
		for packet in packets:
			a = packet.split('::')
			print a
			m = PyMouse()
			if len(a) > 1:
				command = a[0]
				key = packet[5:]
				if command == "key":
					cmd = """osascript -e 'tell application "System Events" to keystroke "%s"'""" % key
					# minimize active window
					os.system(cmd)
					pass
				else:
					btnNum = int(a[1])
					x = float(a[2])+self.originPosition[0]
					y = float(a[3])+self.originPosition[1]
					if command == "mov":
						m.move(x,y)
						pass
					elif command == "clk":
						pass
					elif command == "prs":
						m.press(x,y,btnNum)
						pass
					elif command == "rls":
						m.release(x,y,btnNum)
						pass
					elif command == "str":
						self.originPosition = m.position()
						pass

class KeyHandler(Protocol):

    def dataReceived(self, data):
        a = data.split(':')
        print a
        if len(a) > 1:
            command = a[0]
            content = a[1]
 
            msg = ""
            if command == "iam":
                self.name = content
                msg = self.name + " has joined"
 
            elif command == "msg":
                msg = self.name + ": " + content
                print msg
 
            for c in self.factory.clients:
                c.message(msg)
 
factory = Factory()
factory.protocol = MouseHandler
factory.clients = []
reactor.listenTCP(8999, factory)
reactor.run()