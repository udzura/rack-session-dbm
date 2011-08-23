require 'sdbm'
require 'rack/session/abstract_dbm'

module Rack
  module Session
    class SDBM < AbstractDBM
      DEFAULT_OPTIONS =
        Abstract::ID::DEFAULT_OPTIONS.merge :dbm_path => ::File.join((ENV['TMP_PATH'] || ENV['TMP'] || '/tmp'), "sessions.sdbm")

      def dbklass
        ::SDBM
      end

      def default_session_file
        "sessions.sdbm"
      end
    end
  end
end
