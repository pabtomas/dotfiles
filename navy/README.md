# Navy

A Docker Engine orchestrator embedded in a container

## Why Navy ?

Navy was born because I faced a recurrent scenario when dealing with Docker:
- Starting a Compose project to make a simple stack of containers working quickly,
- With time this stack is becoming more complex and I take more time to make things around my project to compensate Compose's lacks,
- I switch to another solution (Ansible, Kubernetes, Swarm, ...) because my project is now unmaintenable.

In most cases, this is how things should go: Compose is not the right tool for the project I am working on.
But sometimes, I feel like my project is not complex and going for Ansible, Swarm or another solution is overkilled.

Navy was written with 4 priorities in mind:
- Minimal process installation: Navy was conceived to run with a minimal set of dependencies into a minimal container (no extra daemon, no extra library installation, no extra configuration, no controller/nodes architecture)
- Minimal abstraction to the Docker Engine API to offer a full control and solve all recurrent problems I had with Compose:
  - Templating: all my compose.yaml files are templated because interpolation is forbidden for services. It means an extra dependency for a templating tool.
  - No dependencies control: depends_on is applyed to all the service process (build/creation/running).
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

## Specification

Keywords:
- versions
- include
- requests
- requests[].endpoint
- requests[].method
- requests[].register
- requests[].from
- requests[].from.registered
- requests[].from.template
- requests[].loop
- requests[].loop[].query
- requests[].loop[].path
- requests[].loop[].id
- requests[].loop[].virtual
- requests[].loop[].context
- requests[].loop[].depends_on
- requests[].loop[].extends
