# Navy

A Docker Engine orchestrator embedded in a container

## Why Navy ?

Navy was born because I faced a recurrent scenario when dealing with Docker:
- Starting a Compose project to make a simple stack of containers working quickly,
- With time this stack is growing and it takes more time to make things around Compose to compensate Compose's lacks,
- I switch to another solution (Ansible, Kubernetes, Swarm, ...) because the project is now unmaintenable.

In most cases, this is how things should go: Compose is not the right tool for the project I am working on.
But sometimes, I feel like my project is not complex and going for Ansible, Swarm or another solution is overkilled.

Navy was designed with 4 priorities in mind:
1. Minimal process installation: Navy was conceived to run with a minimal set of dependencies into a minimal container (no extra daemon, no extra library installation, no extra configuration, no controller/nodes architecture)
2. Minimal abstraction to the Docker Engine API to offer a full control.
3. Minimal specification: the Navy specification contains less than 20 keywords (some of them are literally coming from Compose and Ansible)
4. Docker Engine API version agnostic: It does not mean that your `navy.yaml` file will work on 2 different hosts with two different versions of the Docker Engine API. It means that you can write a `navy.yaml` file whatever the Docker Engine API version you are targeting:
  - See here to know how Docker Engine works when a requests is submitted with an other version
  - Here the command line to check your Docker Engine API version:
```
docker version --format '{{ .Server.APIVersion }}'
```

Navy solves all recurrent problems that made my Compose projects messy:
1. Extra usage of templating tools. The Compose envfile is quickly limited:
  - Interpolation forbidden for services,
  - Less useful than most of templating tools
2. No thin control of dependencies between services. The `depends_on` keyword is applied to the all service process (building, creation and starting).
3. No way to specify a service purpose in a Compose file. It leads to a dedicated Compose file to build and tag images used later by the main Compose file services.
4. No `extends` list: https://github.com/docker/compose/issues/3167
5. Dirty hacks to add multifile Anchors & Aliases: https://github.com/docker/compose/issues/5621

## How to use it ?

As stated above, Navy was designed to be used in a container. But that does not mean that you can not use it outside of a container.

### Why should I run Navy into a container ?

To keep it minimal Navy was written in Shell: no compilation process, extra libraries or anything else a real programing language could need. The extra cost of this design decision is an environment sensitivity. Because Navy does not manage harsh environments (because it could lead to unmaintable code), the solution was to write a dedicated image. Here the command line you can use to run Navy in a safe environment:
```
docker run --rm -v .:/workspace:ro -v ~/.cache/navy:/cache:rw tiawl/navy:0.0.0
```

### How to run Navy out of its safe box ?

If you want to install Navy directly I assume that you have at least Busybox utilities on your system.
- Install the dependencies (it should not be difficult if you are using a popular package manager):
  - [yq](https://github.com/mikefarah/yq)
  - [curl](https://github.com/curl/curl)
  - [gomplate](https://github.com/hairyhenderson/gomplate)
  - [dash](https://git.kernel.org/pub/scm/utils/dash/dash.git/)
- Clone this repository
- Add configuration (TODO: more details)
- Install it (TODO: more details)

### How to run Navy with a remote docker socket ?

If you use Navy in its container, add this option to the `docker run` command:
```
-e DOCKER_HOST=${DOCKER_HOST}
```

otherwise export the `DOCKER_HOST` variable in your environment.
