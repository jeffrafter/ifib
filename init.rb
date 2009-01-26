require 'rubygems'
require 'sinatra'
require 'memcache'

CACHE = MemCache.new 'localhost:11211', :namespace => 'fib'
CACHE.set(0, 0)
CACHE.set(1, 1)
CACHE.set('max', 1)

get '/' do
  haml :index
end

get %r{/api/v1/fibonacci/([\d]+)} do
  n = params[:captures].first.to_i
  fib(n).to_s
end 

def fib(n)
  CACHE.get(n) || begin
    return n if (0..1).include? n
    return generate(n)
  end
end

def generate(offset)
  CACHE.get(offset) || begin
    max = CACHE.get('max')
    a, b = CACHE.get(max - 1), CACHE.get(max)
    c = nil
    max.upto(offset) do |key|
      c = a + b
      a = b
      b = c
      CACHE.set(key, b)
    end
    CACHE.set('max', offset)
    return b
  end
end

__END__

@@ layout
%html
  %head
    %title iFib
  %body
    = yield

@@ index

%h1 iFib
%p
  iFib provides a RESTful API for calculating the fibonacci sequencing

%h2 Usage

%p
  The base URI is http://ifib/api/v1

%h3 fibonacci

%blockquote
  http://ifib/api/v1/fibonacci/:number:

%p
  Returns the fibonacci number of :number:

%p Example:
%blockquote
  %pre $ curl http://localhost:4567/api/v1/fibonacci/119

