require 'rack/session/abstract/id'

module Rack
  module Session
    class AbstractDBM < Abstract::ID
      attr_reader :mutex, :pool

      def initialize(app, path=nil, options={})
        super(app, options)

        @mutex = Mutex.new
        db_path = path || (ENV['RACK_ROOT'] ? ::File.join(ENV['RACK_ROOT'], 'tmp', default_session_file) : @default_options[:dbm_path])
        opts = @default_options

        @pool = dbklass.new(db_path)
      end

      def generate_sid
        loop do
          sid = super
          break sid unless @pool[sid]
        end
      end

      def get_session(env, sid)
        with_lock(env, [nil, {}]) do
          unless sid and session = Marshal.load(@pool[sid] || "\x04\b0")
            sid, session = generate_sid, {}
            begin
              @pool[sid] = Marshal.dump(session)
            rescue
              raise "Session collision on '#{sid.inspect}'"
            end
          end
          [sid, session]
        end
      end

      def set_session(env, session_id, new_session, options)
        with_lock(env, false) do
          @pool[session_id] = Marshal.dump(new_session)
          session_id
        end
      end

      def destroy_session(env, session_id, options)
        with_lock(env) do
          @pool.delete(session_id)
          generate_sid unless options[:drop]
        end
      end

      def with_lock(env, default=nil)
        @mutex.lock if env['rack.multithread']
        yield
      rescue StandardError
        if $VERBOSE
          warn "#{self} is unable to write to dbm."
          warn $!.inspect
        end
        default
      ensure
        @mutex.unlock if @mutex.locked?
      end
    end
  end
end
