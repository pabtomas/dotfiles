# Navy

A Docker Engine orchestrator embedded in a container

## Why Navy ?

Navy was born because I faced a recurrent scenario when dealing with Docker:
- Starting a Compose project to make a simple stack of containers working quickly,
- With time this stack is becoming more complex and I take more time to make things around my project to compensate Compose's lacks,
- I switch to another solution (Ansible, Kubernetes, Swarm, ...) because my project is now unmaintenable.

In most cases, this is how things should go: Compose is not the right tool for the project I am working on.
But sometimes, I feel like my project is not complex and going for Ansible, Swarm or another solution is overkilled.

Navy was designed with 4 priorities in mind:
- Minimal process installation: Navy was conceived to run with a minimal set of dependencies into a minimal container (no extra daemon, no extra library installation, no extra configuration, no controller/nodes architecture)
- Minimal abstraction to the Docker Engine API to offer a full control and solve all recurrent problems I had with Compose:
  - Templating: all my compose.yaml files are templated because interpolation is forbidden for services. It means an extra dependency for a templating tool.
  - No separation between service control: depends_on is applyed to all the service process (build/creation/running).
  - No way to specify a service purpose in a compose.yaml file. I am using some services only for building and tagging images and I do not want to create or run these services. But I can only specify this with the Compose CLI.
  - No extends list: https://github.com/docker/compose/issues/3167
  - Anchors & Aliases with multifiles: https://github.com/docker/compose/issues/5621
- Minimal specification: the Navy specification contains less than 20 keywords (some of them are literally coming from Compose and Ansible)
- Docker Engine API version agnostic: It does not mean that your `navy.yaml` file will work on 2 different hosts with two different versions of the Docker Engine API. It means that you can write a `navy.yaml` file whatever the Docker Engine API version you are targeting:
  - See here to know how Docker Engine works when a requests is submitted with an other version
  - Here the command line to check your Docker Engine API version:
```
docker version --format '{{ .Server.APIVersion }}'
```

## How to use it ?

As stated above, Navy was designed to be used in a container. That does not mean that you can not use it outside of a container.

### Why should I run Navy into a container ?

To keep it minimal Navy was written in Shell: no compilation process, extra libraries or anything else a real programing language could need. The extra cost of this design decision is an environment sensitivity. Because I do not manage harsh environments in Navy (because it could lead to unmaintable code), I solve this issue writing a dedicated image. This is how you can use it to run Navy in a safe environment:
```
docker run --rm -v .:/workspace:ro -v ~/.cache/navy:/cache:rw tiawl/navy:0.0.0
```

### How to run Navy outside its container ?

- Install the dependencies (it should not be difficult if you are using a popular package manager):
  - [yq](https://github.com/mikefarah/yq)
  - [jq](https://github.com/jqlang/jq)
  - [curl](https://github.com/curl/curl)
  - GNU envsubst
  - [busybox](https://www.busybox.net/)
  - [dash](https://git.kernel.org/pub/scm/utils/dash/dash.git/)
- Clone this repository
- Run the navy executable

### How to run Navy with a remote docker socket ?

If you use Navy in its container, add this option to the `docker run` command:
```
-e DOCKER_HOST=${DOCKER_HOST}
```

otherwise export the DOCKER_HOST variable in your environment.
