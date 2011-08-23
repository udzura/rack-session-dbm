require 'rubygems'
require 'bundler'
Bundler.require

ROOT = File.expand_path('../', __FILE__)

use Rack::Session::SDBM, "#{ROOT}/sessions.sdbm"
use Rack::Flash

get '/' do
  session[:accessed] ||= 0
  session[:accessed] += 1
  @dump = session.inspect
  haml :index
end

post '/keys' do
  session[params[:key]] = params[:value]
  flash[:notice] = "set session[#{params[:key].inspect}] = #{params[:value].inspect}"
  redirect "/"
end

delete '/keys' do
  session.delete params[:key]
  flash[:notice] = "deleet session[#{params[:key].inspect}]"
  redirect "/"
end

helpers do
  def h(str)
   CGI.escapeHTML(str)
  end
end

__END__
@@ layout
!!! 5
%html
  %head
    %title sample
  %body
    = yield

@@index
#main
  - if flash[:notice]
    %p#flash=h flash[:notice]
  %h1 rack-session-sdbm sample
  %h2 session dump is below
  %pre=h @dump
  %h2 set session value
  %form{:method => "post", :action => "/keys"}
    %input{:name => "key", :type => "text", :size => 15}
    %input{:name => "value", :type => "text", :size => 45}
    %input{:type => "submit"}
  %h2 delete session value
  %form{:method => "post", :action => "/keys"}
    %input{:name => "_method", :type => "hidden", :value => "delete"}
    %input{:name => "key", :type => "text", :size => 15}
    %input{:type => "submit"}
