# Mana

a Docker Engine orchestrator

## Features

- Rule oriented
- Minimal abstraction to the Docker Engine API
- Minimal specification: less than 30 keywords
- Docker Engine API version agnostic
- Zero-fuss installation
- Asynchronous execution

## Why Mana ?

For 2 main reasons:

### 1. Because my daily DevOps life with Compose is only anger and tears

Mana was written because I faced a recurrent scenario when dealing with Docker:
- Starting a Compose project to make a simple stack of containers working quickly. I know this project will not stay simple but I do not find a better alternative because it is a local project and most of popular alternatives are overkilled controller-nodes architectured solutions,
- As expected, with time this stack is growing. Compose has some lacks and I add other tools (even tools not designed to work with Docker) to compensate that,
- Quickly I spend more time to maintain things around Compose than spending time on my application,
- I abandoned the project because at this point, it is difficult to maintain and to make evolve.

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
But sometimes, I feel like going for Ansible, Swarm or another solution is overkilled.

Mana, like GNU `make`, has a rule-oriented system. GNU `make` is a popular solution to use with the Docker official client (or even Compose) when building an application. I personnaly think adding GNU `make` over Docker is the starting point of many troubles. GNU `make` was not designed to work with Docker. The first line of the GNU `make` documentation states it better than everything else:
```
GNU Make is a tool which controls the generation of executables and other non-source files of a program from the program's source files.
```

This is where Mana stands out: Mana is designed to work with Docker.

### 2. Because I think Zig could bring a lot new things to the DevOps community

Here the scoop of the day: Mana does not have the ambition to compete with other Open Source containers orchestrators you can already find. But that is not the Mana point. I started this project with Zig because I did not find any DevOps tools written with. And I believe that Zig can. So this project is here to fix this mistake: Zig can also do great things for the DevOps community.

## How to install it ?

If you want to run it on your laptop, install [Zig 0.13.0](https://ziglang.org/download/), and then execute these commands:
```sh
git clone https://github.com/tiawl/mana.git

# ${my_install_path} is usually /usr/local for linux OS but feel free to change it for a more suitable location for your usecase
env -C mana zig build -p "${my_install_path:-/usr/local}"
```

If you prefer to use Mana in its container run this command instead:
```
TODO
```

## How to start a Mana Project ?

First of all, you need to describe your project with a `mana.json` file. Here the links you need to fill it:
- [the Mana specification](https://github.com/tiawl/mana/blob/trunk/doc/00_index.md)
- [the Docker Engine API documentation](https://docs.docker.com/engine/api/)
- [the JQ manual](https://jqlang.github.io/jq/manual/)

## How to run Mana with a remote Docker socket ?

If you use Mana in its container, add this option to the `docker run` command:
```
-e DOCKER_HOST=${DOCKER_HOST}
```

If not, export `DOCKER_HOST` in your environment.

## What did you plan for the next releases ? How can I contribute to this project ?

You probably noticed that Mana does not have a first major release. Why ? Because Mana is young: it is ready to be used but is not mature. To go further, Mana needs feedbacks for its implemented features. So expect breaking changes in the next releases.

With time, Mana will be more stable. If you want to contribute and see Mana growing, you can do 2 things:
1. use Mana for your projects and open an issue later to see how we could improve it together. Any elaborated feedback will make Mana better. So do not hesitate to open an issue: this is currently one of the best way to contribute.
2. use Zig in your projects. Mana is written with Zig and currently, some roadmap goals you can read below are stucked because Zig is not mature enough. So if you want to contribute, use Zig in your projects, whatever you are doing with.

### Long-term Roadmap

- Make it works for Windows OS
- Remove C backend:
    - Replace libcurl with a pure-Zig thread-safe HTTP/HTTPS lib,
    - Implement one of these 2 solutions:
        1. Replace libjq with a pure-Zig JSON processor lib,
        2. Use ZON:
            - Replace JSON format with ZON format,
            - Replace libjq with a ZON processor lib

## License

This repository is dedicated to the public domain. See the LICENSE file for more details.