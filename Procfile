redis:     redis-server /usr/local/etc/redis.conf --port $PORT
web:       bundle exec rails server --port=$PORT
compiler:  bundle exec lamp  server --port=$PORT --log-file=log/compiler.log
faye:      bundle exec thin start -R faye.ru --port=$PORT
