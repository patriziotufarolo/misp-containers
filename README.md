# MISP Containers 🐋

The easiest way to deploy the last version of **MISP**, leveraging the power of containers!

## What do I provide

This setup is made of 12 services built on 6 images as follows.
For the moment images are not in the [Docker Hub](https://hub.docker.com/) or any public registry so you'll have to build them by yourself.

### MISP
This image embeds the MISP source code and configuration files and serves them through *php-fpm*. This container is built in a multi-stage fashion starting from an *Alpine* container.
The first stage fetches the MISP source code from MISP Project's GitHub repository, the second stage prepares the Python virtualenv with all MISP's dependencies, while the third and last puts things together with PHP installing also PHP dependencies.

The versions of the software installed are:

- Alpine Linux container 3.10
- Python 3.7
- PHP 7.4
- Ssdeep 2.13
- Composer 1.10

Some tuning settings for PHP are applied according to MISP's requirements.

I also patched [CakeResque](https://cakeresque.kamisama.me/) to keep it running in foreground, being compliant with Docker's logging approach.
This allows me to give to each worker process its own container, and make workers scale through the container engine.
Since this breaks the native workers management functionality of MISP, within the docker-compose file I decided to share the PID Namespace between workers and MISP services.
Of course, MISP's worker management is definitively broken within Docker Swarm.

Patch is available [here](https://github.com/patriziotufarolo/misp-containers/blob/master/misp/01-cakeresque.patch)

I added two plugins for CakePHP and MISP that allow me to:

- Edit configuration scripts in a consistent way through CLI and scripts using MISP's own functions;
- Verify the readiness of the database service in order to perform some healthchecks wille raising the containers up.

This image is used by the following services:

- misp 
- worker\_default
- worker\_email
- worker\_prio
- worker\_update
- worker\_cache
- worker\_scheduler

Last but not least, the provided docker-compose specifies also the volumes needed to guarantee persistence.

### MISP modules - *misp-modules*
This image contains all the MISP's enrichment modules and their dependencies.

This image is used by the following services:

- misp-modules

### Database - *misp-db*
This image is a plain mariadb database image that, on first startup, is initialized with MISP's database schema, grabbed from the misp image throygh a multi-stage approach.

The provided docker-compose specifies also the volumes needed to guarantee persistence.

This image is used by the following services:

- database

### Redis - *redis*
Basic Redis image from Docker Hub

This image is used by the following services:

- redis

### Redis-commander - *rediscommander*
[Redis commander](https://github.com/joeferner/redis-commander) is a Redis web management tool written in Node.JS. I embedded it to look into MISP's redis queues. Feel free to remove it if you don't need it. 

This image is used by the following services:

- redis-commander

### Frontend - *misp-fe*
This is basically an Nginx image that serves MISP interacting with php-fpm, and redis-commander under the /redis-commander/ path. 
If you don't need redis-commander feel free to remove its definition and rebuild the container.
This is probably the right place (unless you don't have any alternative architecture) to implement HTTPS.

This image is used by the following services:

- frontend 

## Install
To install MISP using this recipe, by now, you need a machine with **Docker**  and `docker-compose`:

1) Clone the repository

```
$ git clone https://github.com/patriziotufarolo/misp-containers
```

2) Cd into it

```
$ cd misp-containers
```

3) Review / customize the `.env` file

4) GO!

```
# docker-compose up -d
```
### Upgrade procedure for MISP

1) Rebuild the misp and worker images

```
# docker-compose build misp
# docker-compose build worker_default
```

2) Shutdown everything
```
# docker-compose down
```

3) Find the MISP source volume

```
# docker volume ls | grep misp-source
```

4) Remove that volume
```
# docker volume rm <NAME OF THE VOLUME FOUND ABOVE>
```

5) Rebuild the setup
```
# docker-compose up -d
```

Thanks to the volumes you are not going to lose data.

## Documentation

Further documentation and automation scripts will be provided soon.

## Want to contribute?

If you are want to contribute to this project feel free to report issues, fork the code, patch it, send pull requests!

For the moment I used just the master branch, I will start working with gitflow to implement new features.

## License

This project is licensed under [MIT License](https://opensource.org/licenses/MIT)

Copyright (C) 2020 Patrizio Tufarolo

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

MISP is licensed under [GNU Affero General Public License version 3](http://www.gnu.org/licenses/agpl-3.0.html)

Copyright (C) 2012 Christophe Vandeplas
Copyright (C) 2012 Belgian Defence
Copyright (C) 2012 NATO / NCIRC
Copyright (C) 2013-2019 Andras Iklody
Copyright (C) 2015-2019 CIRCL - Computer Incident Response Center Luxembourg
Copyright (C) 2016 Andreas Ziegler
