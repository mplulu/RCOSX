from twisted.web.server import Site
from twisted.web.resource import Resource
from twisted.internet import reactor
from PyMouse.pymouse import PyMouse
from twisted.python import log
from sys import stdout

class KeyHandler(Resource):
    def render_GET(self, request):
        return "key %s" % request.args['code'][0];
class MouseHandler(Resource):
	originPosition = (0,0)
	def render_GET(self, request):
		m = PyMouse()
		if request.args.get('start',0) != 0:
			self.originPosition = m.position()
		elif request.args.get('click',0) != 0:
			m.click(m.position()[0],m.position()[1],int(request.args.get('click',0)[0]))
		elif request.args.get('press',0) != 0:
			m.press(m.position()[0],m.position()[1],int(request.args.get('press',0)[0]))
		elif request.args.get('release',0) != 0:
			m.release(m.position()[0],m.position()[1],int(request.args.get('release',0)[0]))
		else:
			x = request.args.get('x',0)[0]
			y = request.args.get('y',0)[0]
			m.move(self.originPosition[0]+float(x), self.originPosition[1]+float(y))

root = Resource()
root.putChild("key", KeyHandler())
root.putChild("mouse", MouseHandler())
factory = Site(root)
reactor.listenTCP(8880, factory)
# log.startLogging(stdout)
reactor.run()