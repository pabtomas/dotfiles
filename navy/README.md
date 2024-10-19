# Navy

A Docker Engine orchestrator

## Features

- Minimal abstraction to the Docker Engine API
- Minimal specification: less than 30 keywords
- Docker Engine API version agnostic **
- No controller-nodes architecture
- Zero-fuss installation
- Asynchronous execution

** It does not mean that your `navy.json` file will work on 2 different hosts with two different versions of the Docker Engine API. It means that you can write a `navy.json` file whatever the Docker Engine API version you are targetting.

## Why Navy ?

Navy was written because I faced a recurrent scenario when dealing with Docker:
- Starting a Compose project to make a simple stack of containers working quickly,
- With time this stack is growing and I spend more time to maintain things around Compose to compensate its lacks,
- I switch to another solution (Ansible, Kubernetes, Swarm, ...) because the project is now unmaintainable.

Here a non exhaustive list of problems that made my Compose projects messy:
1. Extra usage of templating tools. The Compose envfile is quickly limited:
  - Unusable interpolation for services definition name,
  - Less useful than most of templating tools
2. No thin control of dependencies between services. The `depends_on` keyword is applied to the all service process (building, creation and starting).
3. No way to specify a service purpose in a Compose file. It leads to a dedicated Compose file to build and tag images used later by the main Compose file services.
4. No `extends` list: https://github.com/docker/compose/issues/3167
5. Dirty hacks to add multifile YAML Anchors & Aliases: https://github.com/docker/compose/issues/5621
6. No scoped variables

In most cases, this is how things should go: Compose is not the right tool for the project I am working on.
But sometimes, I feel like my project is not complex and going for Ansible, Swarm or another solution is overkilled.

Another popular solution is to use GNU `make` with the Docker client (or even Compose). Even if this option solves some issues I described, I think this is the starting point for many other troubles. Because this introduction is long enough I am not going to talk about all the fun I had with GNU `make` during my Docker projects. GNU `make` was not designed to work with Docker. The first line of the GNU `make` documentation states it better than everything else:
```
GNU Make is a tool which controls the generation of executables and other non-source files of a program from the program's source files.
```

## How to install it ?

If you want to run it on your laptop, install [Zig 0.13.0](https://ziglang.org/download/), and then execute these commands:
```sh
git clone https://github.com/tiawl/navy.git

# ${my_install_path} is usually /usr/local for linux OS but feel free to change it for a more suitable location for your usecase
env -C navy zig build -p "${my_install_path:-/usr/local}"
```

If you prefer to use Navy in its container run this command instead:
```
TODO
```

## How to start a Navy Project ?

First of all, you need to describe your project with a `navy.json` file. Here the links you need to fill it:
- [the Navy specification](https://github.com/tiawl/navy/blob/trunk/doc/00_index.md)
- [the Docker Engine API documentation](https://docs.docker.com/engine/api/)
- [the JSON specification]()
- [the Mustache specification]()
- [the JQ specification]()()

### How to run Navy with a remote Docker socket ?

If you use Navy in its container, add this option to the `docker run` command:
```
-e DOCKER_HOST=${DOCKER_HOST}
```

If not, export `DOCKER_HOST` in your environment.

### What did you plan for the next releases ? How can I contribute to this project ?

You probably noticed that Navy does not have a first major release. Why ? Because Navy is young: it is ready to be used but is not mature. To go further, Navy needs feedbacks for its implemented features. So expect breaking changes in the next releases.

With time, Navy will be more stable. If you want to contribute and see Navy growing, use Navy for your project and open an issue later to see how we could improve it together. Any elaborated feedback will make Navy better. So do not hesitate to open an issue: this is currently the best way to contribute.
