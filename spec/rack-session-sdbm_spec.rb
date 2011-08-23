require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Rack::Session::SDBM do
  before do
    @session_key = Rack::Session::SDBM::DEFAULT_OPTIONS[:key]
    @path = '/tmp/test-session.sdbm'
    @dbm  = SDBM.new(@path)

    @increment_mockapp = lambda do |env|
      env['rack.session']['counter'] ||= 0
      env['rack.session']['counter'] += 1
      Rack::Response.new(env['rack.session'].inspect).finish
    end
  end

  it "creates a new cookie" do
    pool = Rack::Session::SDBM.new(@increment_mockapp, @path)
    res = Rack::MockRequest.new(pool).get('/')
    res['Set-Cookie'].should match(/#{@session_key}=/)
    res.body.should == '{"counter"=>1}'
  end

  it 'determines session from a cookie' do
    pool = Rack::Session::SDBM.new(@increment_mockapp, @path)
    req = Rack::MockRequest.new(pool)
    res = req.get('/')
    cookie = res['Set-Cookie']
    req.get('/', 'HTTP_COOKIE' => cookie).
      body.should == '{"counter"=>2}'
    req.get('/', 'HTTP_COOKIE' => cookie).
      body.should == '{"counter"=>3}'
  end

=begin
  it "" do
  end
=end
end
