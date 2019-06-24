import os, sys, argparse
from signal import SIGTERM, SIGKILL

from Auto_Repo import *

class Daemon:
	def __init__(self, pidfile):
		self.pidfile = pidfile
		self.process = Auto_Repo()
	def run(self):
	    	exit_code = self.process.main()
		exit(exit_code)
	def daemonize(self):
    		# double fork, first fork
		try:
			pid = os.fork()
    			if pid > 0:
        			# parent procrss
        			# just exit
        			exit(0)
		except OSError, e:
			print 'fork #1 failed: %d (%s)' % (e.error, e.stderr)
			sys.exit(1)
        	# decouple from parent envronment
        	os.chdir('/')
        	os.setsid()
        	os.umask(0)
        	# second fork
		try:
        		pid = os.fork()
        		if pid > 0:
            			# just exit
            			exit(0)
        	except OSError, e:
			print 'fork #2 failed: %d (%s)' % (e.error, e.stderr)
			sys.exit(1)
            	sys.stdout.flush()
            	sys.stderr.flush()

            	with open(self.pidfile, "w") as pid_file:
                	pid_file.write(str(os.getpid()))

            	self.run()

	def delpid(self):
		os.remove(self.pidfile)
	
	def start(self):
		try:
			pf = file(self.pidfile, 'r')
			pid = int(pf.read().strip())
			pf.close()
		except IOError:
			pid = None

		if pid:
			message = "pidfile %s aleady exists. Daemon aleady running?\n" % pid
			print message

			sys.exit(1)
		self.daemonize()
	def stop(self):
                """
                Stop the daemon
                """
                # Get the pid from the pidfile
                try:
                        pf = file(self.pidfile,'r')
                        pid = int(pf.read().strip())
			
                        pf.close()
                except IOError:
                        pid = None
			
                if not pid:
                        message = "pidfile %s does not exist. Daemon not running?\n" % pid
			print message
                        return 

                # Try killing the daemon process       
                try:
			print(pid)
			os.kill(pid, 9)
			self.delpid()
                except OSError, err:
                        err = str(err)
                        if err.find("No such process") > 0:
                                if os.path.exists(self.pidfile):
                                        os.remove(self.pidfile)
                        else:
                                print str(err)
                                sys.exit(1)

        def restart(self):
                """
                Restart the daemon
                """
                self.stop()
                self.start()

