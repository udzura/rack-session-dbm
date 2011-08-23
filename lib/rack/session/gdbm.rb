require 'gdbm'
require 'rack/session/abstract_dbm'

module Rack
  module Session
    class GDBM < AbstractDBM
      DEFAULT_OPTIONS =
        Abstract::ID::DEFAULT_OPTIONS.merge :dbm_path => ::File.join((ENV['TMP_PATH'] || ENV['TMP'] || '/tmp'), "sessions.gdbm")
      def dbklass
        ::GDBM
      end

      def default_session_file
        "sessions.gdbm"
      end
    end
  end
end
