# Exodia

A Docker Engine orchestrator embedded in a container

## Why Exodia ?

Exodia was born because I faced a recurrent scenario when dealing with Docker:
- Starting a Compose project to make a simple stack of containers working quickly,
- With time this stack is growing and it takes more time to make things around Compose to compensate Compose's lacks,
- I switch to another solution (Ansible, Kubernetes, Swarm, ...) because the project is now unmaintainable.

Here a non exhaustive list of problems that made my Compose projects messy:
1. Extra usage of templating tools. The Compose envfile is quickly limited:
  - Interpolation forbidden for services,
  - Less useful than most of templating tools
2. No thin control of dependencies between services. The `depends_on` keyword is applied to the all service process (building, creation and starting).
3. No way to specify a service purpose in a Compose file. It leads to a dedicated Compose file to build and tag images used later by the main Compose file services.
4. No `extends` list: https://github.com/docker/compose/issues/3167
5. Dirty hacks to add multifile Anchors & Aliases: https://github.com/docker/compose/issues/5621
6. No scoped variables

In most cases, this is how things should go: Compose is not the right tool for the project I am working on.
But sometimes, I feel like my project is not complex and going for Ansible, Swarm or another solution is overkilled.

Another popular solution is to use GNU `make` with the Docker client. Even if this option solves some issues I described, I think this is the starting point for many other troubles. Because this introduction is long enough I am not going to list problems I encountered with GNU `make` during my Docker projects. Conclude with the first line of the GNU `make` documentation is the most relevant thing to do:
```
GNU Make is a tool which controls the generation of executables and other non-source files of a program from the program's source files.
```
With other words: GNU `make` was not degined to be used with Docker.

Exodia was designed with 5 priorities in mind to solve all problems I had with Compose without going for an heavy solution:
1. Minimal process installation: Exodia was conceived to run with a minimal set of dependencies into a minimal container (no extra daemon, no extra library installation, no extra configuration),
2. No controller-nodes architecture,
3. Minimal abstraction to the Docker Engine API to offer a full control,
4. Minimal specification: the Exodia specification contains less than 30 keywords (some of them are literally coming from Compose or Ansible),
5. Docker Engine API version agnostic: It does not mean that your `exodia.yaml` file will work on 2 different hosts with two different versions of the Docker Engine API. It means that you can write a `exodia.yaml` file whatever the Docker Engine API version you are targetting.

## How to start a Exodia Project ?

First of all, you need to describe your project with a `exodia.yaml` file. Here the links you need to fill it:
- [the Exodia specification](https://github.com/tiawl/exodia/blob/trunk/doc/00_index.md)
- [the Docker Engine API documentation](https://docs.docker.com/engine/api/)
- [the gomplate documentation](https://docs.gomplate.ca/) and [the Golang template documentation](https://pkg.go.dev/text/template)

## How to use it ?

As stated above, Exodia was designed to be used in a container.

### Why run Exodia into a container ?

1. Exodia was written in Shell to keep it minimal: no compilation process, extra libraries or anything else a real programing language could need. The extra cost of this design decision is an environment sensitivity. Because Exodia does not manage harsh environments (because it could lead to unmaintable code), the solution was to write a dedicated image.
2. Exodia needs access to your Docker socket to communicate with the Docker Engine. However the Docker socket can only be root accessed. So running Exodia on your laptop means running it as root. **And running scripts written by others as root on your system if the most unsafe thing you can do**. Again: the solution is to isolate the Exodia process on its container.
3. You can use the Exodia dedicated image as a stage for your own images. It could be very useful if you want to extend Exodia features for your own needs or/and to share it with others.

### How to run Exodia ?

Here the command line you can use to run Exodia in a safe environment:
```
docker run --rm -t -v .:/workspace:ro -v ~/.cache/exodia:/var/cache/exodia:rw tiawl/exodia:0.1.0
```

### Can I run Exodia out of its dedicated box ?

Even if it is not recommended, yes you can. If you are convinced that you need Exodia ouf of its container follow steps described in its [Dockerfile](https://github.com/tiawl/exodia/blob/trunk/Dockerfile).

### How to run Exodia with a remote docker socket ?

If you use Exodia in its container, add this option to the `docker run` command:
```
-e DOCKER_HOST=${DOCKER_HOST}
```

If not, export `DOCKER_HOST` in your environment.

### What did you plan for the next releases ? How can I contribute to this project ?

You probably noticed that Exodia does not have a first major release. Why ? Because Exodia is ready to be used but is not mature. To go further, Exodia needs feedbacks for its implemented features. Expect breaking changes in the next releases. With time, Exodia will be more stable. If you want to contribute and see Exodia growing, use Exodia for your project and open an issue later to see how we could improve it together. Any elaborated feedback will make Exodia better. So do not hesitate to open an issue: this is currently the best way to contribute.