# Genie

Genie is an experimental platform for educators to publish and maintain lessons using Git hooks. It allows authors
to describe problems using YAML and Markdown, and also tracks each student's performance.

The project was started in Jan 2013 and paused on July 2013.

Components include:
- [genie-game](https://github.com/jimjh/genie-game), the Rails front-end
- [genie-compiler](https://github.com/jimjh/genie-compiler), a Thrift RPC service that clones and compiles lessons
- [genie-parser](https://github.com/jimjh/genie-parser), an extension of Redcarpet that parses lessons
- [genie-tangle](https://github.com/jimjh/genie-tangle), a SSH proxy and VM pool manager

# Deployment
Deployment is done using [Capistrano][capistrano-guide]. A usual deployment workflow should be as follows:

```sh
$> git push origin master
$> cap deploy
```

`cap deploy` will clone the repository to `/u/apps/genie-game/releases/current`, execute `rake db:migrate`, and `rake assets:precompile`. The assets compilation step will take a while, but I am waiting on progress at [Pull Request #21][pull-21].

## DNS Setup
Jim owns the `geniehub.org` domain, registered on Namecheap.com.
`beta.geniehub.org` is a CNAME alias for
`ec2-54-225-113-114.compute-1.amazonaws.com`, which is AWS's elastic IP that
maps to the actual EC2 instance. When switching instances, use AWS's console to
map the elastic IP to the new EC2 instance.

## RDS Instance
Genie uses a MySQL database running on Amazon's RDS. It's configured to allow
access from the `web` EC2 security group. Connections are encrypted with SSL.
The security credentials for accessing the database are kept in Figaro. If the
host is changed, please update `config/shared.rb` and `config/application.yml`.

## EC2 Instance
The current deployment server is `beta.geniehub.org`, running Ubuntu 13.
For the rest of this README, `genie.ec2` refers to the above host. If the host
is changed, please update `config/shared.rb`.

The root user is `ubuntu`. To login as the root user,

```sh
$> ssh -i ~/.ssh/amiller.pem ubuntu@genie.ec2
```

A safer, less powerful sudoer is `codex`. It's setup to allow passwordless login with my private  SSH key at `~/.ssh/id_rsa`.

Capistrano deploys using `passenger`. It's setup to use passwordless login using the deployment key at `~/.ssh/genie-passenger`.

## NGINX
We are using a Rails-Passenger-Nginx setup. Nginx is started using `start-stop-daemon`, which does PID management for us. The main process runs as the `root` user, but worker processes are launched under `www-data`. All of the configuration files are available at `/opt/nginx/conf`.

I updated `/opt/nginx/conf/nginx.conf` and `/opt/nginx/conf/mime.types`.

To check on the status of all monitored services, use

```sh
$> sudo service --status-all
```

To start, stop, restart, or reload nginx, use

```sh
$> sudo service nginx {start|stop|restart}
```

## Passenger
To start, stop, or restart Passenger, execute the following from your local machine:

```sh
$> cap deploy:start
$> cap deploy:stop
$> cap deploy:restart
```

## Redis
Configuration files are at `/etc/redis/redis.conf`. For more information, refer
to [redis documentation](http://redis.io/topics/config).

If the port is changed, please update `config/shared.rb`.

## Lamp
Lamp is also deployed using `cap:deploy` with monitoring by Upstart.

## Installation
These are the steps I took to set up the Ubuntu server.

### 1. UNIX

```sh
remote> sudo useradd -m codex
remote> sudo usermod -G admin codex
remote> sudo usermod -s /bin/bash codex
remote> sudo useradd -m passenger
remote> sudo usermod -s /bin/bash passenger
```

Setup passwordless login using public/private key exchange for passenger.

```sh
local> ssh-keygen -t rsa # output to ~/.ssh/genie-passenger
```

Install software packages as follows:

```sh
$> sudo apt-get install git build-essential
$> sudo apt-get install libssl-dev libxslt-dev libxml2-dev libpq-dev nodejs
```

Upload genie-ec2 deploy keys.

### 2. Ruby + rbenv
Follow instructions on [github](https://github.com/sstephenson/rbenv) to setup
a system-wide install of rbenv to `/usr/local/rbenv`, then follow instructions for
[ruby-build](https://github.com/sstephenson/ruby-build). Set paths and evals in
`/etc/profile.d/rbenv.sh`.

```sh
# /etc/profile.d/rbenv.sh
export RBENV_ROOT=/usr/local/rbenv
export PATH="$RBENV_ROOT/bin:$PATH"
eval "$(rbenv init -)"
```

Install Ruby as follows:

```sh
remote:codex> sudo su
remote:root> . /etc/profile
remote:root> rbenv install 2.0.0-p195
remote:root> chmod -R g+w /usr/local/rbenv
remote:root> chgrp -R admin /usr/local/rbenv
remote:codex> rbenv global 2.0.0-p195
remote:codex> rbenv rehash
```

Install rubygems and bundler.

### 3. Passenger

```sh
remote> sudo gem install passenger
remote> rvmsudo passenger-install-nginx-module
```

Follow given instructions to configure nginx so that it points to `/u/apps/genie-game/current/public`.

### 4. Lamp

Create directory at `/mnt/genie`.

```sh
remote> chown passenger /mnt/genie
remote> chmod o-rx /mnt/genie
local>  cap deploy
```

### 6. Capistrano

Follow the fresh deploy instructions given below.

### 7. Redis

```sh
remote> sudo aptitude install redis-server
```
### 8. MySQL

```sh
remote> sudo aptitude install mysql-client libmysqlclient-dev libmysql-ruby
```

## Misc.

### Fresh Deploy
To do a fresh deploy, edit `config/deploy.rb` to disable `after deploy:update, deploy:migrate`.

1. Setup directories with `cap deploy:setup`. Then login to the remote server and adjust permissions using `chown -R passenger:passenger /u/apps/genie-game`.
2. Setup passwords and API keys by creating the following files:
    - `shared/config/application.yml`
3. Setup codebase with `cap deploy:update`
4. Setup database with `cap deploy:load_schema`
5. Run a simple check with `cap deploy:check`

Finally, reenable `after deploy:update, deploy:migrate` and execute

```sh
$> cap deploy
```

### Process Monitoring
nginx and redis are installed with System V scripts in `/etc/init.d`.
and are monitored with Upstart. Passenger monitors all rails processes.

  [capistrano-guide]: https://github.com/capistrano/capistrano/wiki/2.x-from-the-beginning
  [pull-21]: https://github.com/rails/sprockets-rails/pull/21
