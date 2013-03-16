# Deployment

Deployment is done using [Capistrano][capistrano-guide]. A usual deployment workflow should be as follows:

```sh
$> git push origin master
$> cap deploy
```

`cap deploy` will clone the repository to `/u/apps/genie-game/releases/current`, execute `rake db:migrate`, and `rake assets:precompile`. The assets compilation step will take a while, but I am waiting on progress at [Pull Request #21][pull-21].

## EC2 Instance
The current deployment server is `beta.geniehub.org`, running Ubuntu 12.04.1.
For the rest of this README, `genie.ec2` refers to the above host. If the host
is changed, please update `config/shared.rb`.

The root user is `ubuntu`. To login as the root user,

```sh
$> ssh -i ~/.ssh/square.pem ubuntu@genie.ec2
```

A safer, less powerful sudoer is `codex`. It's setup to allow passwordless login with my private  SSH key at `~/.ssh/id_rsa`.

Capistrano deploys using `passenger`. It's setup to use passwordless login using the deployment key at `~/.ssh/genie_deploy`.

## NGINX
We are using a Rails-Passenger-Nginx setup. Nginx is started using `start-stop-daemon`, which does PID management for us. The main process runs as the `root` user, but worker processes are launched under `www-data`. All of the configuration files are available at `/opt/nginx/conf`.

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

## RVM
The server currently has a system-wide install of rvm using ruby 1.9.3.

## Postgresql
I did a standard install using `aptitude`, then configured `/etc/postgresql/9.1/main/pg_hba.conf` and changed the following line:

	local	all		all		peer

to

	local	all		all 	md5

The root user is `postgres`. I don't remember the password, but you can login using

```sh
$> sudo -u postgres psql
```

from an appropriate sudoer. The confidential authentication details should be
stored in `config/environments/locals.d` and left out of git.

## Redis
Configuration files are at `/etc/redis/redis.conf`. For more information, refer
to [redis documentation](http://redis.io/topics/config).

If the port is changed, please update `config/shared.rb`.

## Installation
These are the steps I took to set up the Ubuntu server.

### 1. UNIX

```sh
remote> sudo useradd -m passenger
remote> sudo usermod -s /bin/bash passenger
remote> sudo passwd passenger
```

Finally, setup passwordless login using public/private key exchange.

```sh
local> ssh-keygen -t rsa # output to ~/.ssh/genie_deploy
```

### 2. Ruby + RVM
Follow instructions on [rvm.io](http://rvm.io/) to setup a system-wide install and add `www-data` and `passenger` to the `rvm` group. Logout, then login again.

Execute `sudo aptitude install` on the list of libraries required by rvm.

Install Ruby as follows:

```sh
remote> sudo rvm install ruby-1.9.3-head
remote> sudo rvm use --default 1.9.3
remote> sudo aptitude install rubygems
remote> sudo gem install bundler
```

### 3. Passenger

```sh
remote> sudo gem install passenger
remote> rvmsudo passenger-install-nginx-module
```

Follow given instructions to configure nginx so that it points to `/u/apps/genie-game/current/public`.

### 4. Lamp

Setup `/usr/local/etc/genie/worker.yml` and create directory at `/mnt/genie`.

```sh
remote> chown passenger /mnt/genie
remote> chmod o-rx /mnt/genie
```

### 5. Postgres

Follow instructions from Ubuntu. Create `passenger` user and `genie` database.

### 6. Capistrano

Follow the fresh deploy instructions given below.

### 7. Redis

```sh
remote> sudo aptitude install redis-server
```

## Misc.

### Fresh Deploy
To do a fresh deploy, edit `config/deploy.rb` to disable `after deploy:update, deploy:migrate`.

1. Setup directories with `cap deploy:setup`. Then login to the remote server and adjust permissions using `chown -R passenger:passenger /u/apps/genie-game`.
2. Setup passwords and API keys by creating the following files:
	- `shared/config/locals.d`
		- `shared/config/locals.d/path.rb`
		- `shared/config/locals.d/api_keys.rb`
	- `shared/config/database.d`
		- `shared/config/database.d/production.yml`
3. Setup codebase with `cap deploy:update`
4. Setup database with `cap deploy:load_schema`
5. Run a simple check with `cap deploy:check`

Finally, reenable `after deploy:update, deploy:migrate` and execute

```sh
$> cap deploy
```

### Process Monitoring
nginx, postgresql, and redis are installed with System V scripts in `/etc/init.d`.
and are monitored with Upstart. Passenger monitors all rails processes.

I think Passenger is started by nginx, but I am not sure.

### Capistrano templates
Should probably use some of these for locals.d, database.d, and pg_hba.conf.

### Security
Need to restrict permissions on database.d and locals.d. Need to restrict permissions on /u/apps/genie-game. Need to restrict privileges for `passenger`. Can we do without passwords for Postgres and use ident or peer? Remove UNIX password for `passenger`? Permissions for `/mnt/genie/*`?

  [capistrano-guide]: https://github.com/capistrano/capistrano/wiki/2.x-from-the-beginning
  [pull-21]: https://github.com/rails/sprockets-rails/pull/21
