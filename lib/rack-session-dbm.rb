module Rack
  module Session
    autoload :GDBM, 'rack/session/gdbm'
    autoload :SDBM, 'rack/session/sdbm'
  end
end
