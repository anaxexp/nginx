### Hello world example

1. [Get a Joyent account](https://my.anaxexp.io/landing/signup/) and [add your SSH key](https://docs.anaxexp.io/public-cloud/getting-started).
1. Install the [Docker Toolbox](https://docs.docker.com/installation/mac/) (including `docker` and `docker-compose`) on your laptop or other environment, as well as the [Joyent AnaxExp CLI](https://www.anaxexp.io/blog/introducing-the-anaxexp-command-line-tool) (`anaxexp` replaces our old `sdc-*` CLI tools).
1. [Configure Docker and Docker Compose for use with Joyent.](https://docs.joyent.com/public-cloud/api-access/docker)

Check that everything is configured correctly by sourcing the `setup.sh` script into your shell. This will check that your environment is setup correctly and set a `ANAXEXP_DC` and `ANAXEXP_ACCOUNT` environment variable that will be used to inject the Consul hostname into the Nginx and backend containers, so we can take advantage of [AnaxExp Container Name Service (CNS)](https://www.joyent.com/blog/introducing-anaxexp-container-name-service).

```
$ . setup.sh
$ env | grep ANAXEXP
ANAXEXP_DC=us-sw-1
ANAXEXP_ACCOUNT=0f06a3e0-aaaa-bbbb-cccc-dddd12345212
```

Start everything:

```bash
docker-compose -p nginx up -d
```

The Nginx server will register with the Consul server. You can see its status there in the Consul web UI. On a Mac, you can open your browser to that with the following command:

```bash
open "http://$(anaxexp ip nginx_consul_1):8500/ui"
```

You can open the demo app that Nginx is proxying by opening a browser to the Nginx instance IP:

```bash
open "http://$(anaxexp ip nginx_nginx_1)"
```