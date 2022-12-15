server = AppServer.new

spawn { server.listen }

Spec.after_suite { server.close }
