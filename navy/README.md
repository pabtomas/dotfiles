# Navy

A Docker Engine orchestrator embedded in a container

## Why Navy ?

Navy was born because I faced a recurrent scenario when dealing with Docker:
- Starting a Compose project to make a simple stack of containers working quickly,
- With time this stack is growing and it takes more time to make things around Compose to compensate Compose's lacks,
- I switch to another solution (Ansible, Kubernetes, Swarm, ...) because the project is now unmaintainable.

Here a non exhaustif list of problems that made my Compose projects messy:
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

Navy was designed with 5 priorities in mind to solve all problems I had with Compose without going for an heavy solution:
1. Minimal process installation: Navy was conceived to run with a minimal set of dependencies into a minimal container (no extra daemon, no extra library installation, no extra configuration),
2. No controller-nodes architecture,
3. Minimal abstraction to the Docker Engine API to offer a full control,
4. Minimal specification: the Navy specification contains less than 30 keywords (some of them are literally coming from Compose or Ansible),
5. Docker Engine API version agnostic: It does not mean that your `navy.yaml` file will work on 2 different hosts with two different versions of the Docker Engine API. It means that you can write a `navy.yaml` file whatever the Docker Engine API version you are targetting.

## How to start a Navy Project ?

TODO

## How to use it ?

As stated above, Navy was designed to be used in a container. But that does not mean that you can not use it outside of a container.

### Why should you run Navy into a container ?

1. Navy was written in Shell to keep it minimal: no compilation process, extra libraries or anything else a real programing language could need. The extra cost of this design decision is an environment sensitivity. Because Navy does not manage harsh environments (because it could lead to unmaintable code), the solution was to write a dedicated image.
2. Navy needs access to your Docker socket to communicate with the Docker Engine. However the Docker socket can only be root accessed. So running Navy on your computer means running it as root. **And running scripts written by others as root on your system if the most unsafe thing you can do**. Again: the solution is to isolate the Navy process on its container.
3. You can use the Navy dedicated image as a stage for your own images. It could be very useful if you want to extend Navy features for your own needs or/and to share it with others.

### How to run Navy in its dedicated box ?

Here the command line you can use to run Navy in a safe environment:
```
docker run --rm -t -v .:/workspace:ro -v ~/.cache/navy:/var/cache/navy:rw tiawl/navy:0.1.0
```

### How to run Navy out of its safe box ?

If you want to install Navy directly I assume that you have at least Busybox utilities (and git) on your system.
- Install the dependencies (it should not be difficult if you are using a popular package manager):
  - [dash](https://git.kernel.org/pub/scm/utils/dash/dash.git/)
  - [coreutils](https://www.gnu.org/software/coreutils/)
  - [curl](https://github.com/curl/curl)
  - [GNU sed]()
  - [GNU bc]()
  - `ts` from [moreutils]()
  - [yq](https://github.com/mikefarah/yq)
  - [gomplate](https://github.com/hairyhenderson/gomplate)
  - [lolcat](https://github.com/jaseg/lolcat)
- Clone this repository
- Add configuration (TODO: more details)
- Install it (TODO: more details)

### How to run Navy with a remote docker socket ?

If you use Navy in its container, add this option to the `docker run` command:
```
-e DOCKER_HOST=${DOCKER_HOST}
```

otherwise export the `DOCKER_HOST` variable in your environment.

### What did you plan for the next releases ? How can I contribute to this project ?

You probably noticed that Navy does not have a first major release. Why ? Because Navy is ready to be used but is not mature. To go further, Navy needs feedbacks for its implemented features. Expect breaking changes in the next releases. With time, Navy will be more stable. If you want to contribute and see Navy growing, use Navy for your project and open an issue later to see how we could improve it together. Any elaborated feedback will make Navy better. So do not hesitate to open an issue: this is the best way to contribute.
