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
1. Minimal process installation: Exodia was conceived to run with a minimal set of dependencies,
2. No controller-nodes architecture,
3. Minimal abstraction to the Docker Engine API to offer a full control,
4. Minimal specification: the Exodia specification contains less than 30 keywords (some of them are literally coming from Compose or Ansible),
5. Docker Engine API version agnostic: It does not mean that your `exodia.toml` file will work on 2 different hosts with two different versions of the Docker Engine API. It means that you can write a `exodia.toml` file whatever the Docker Engine API version you are targetting.

## How to start a Exodia Project ?

First of all, you need to describe your project with a `exodia.toml` file. Here the links you need to fill it:
- [the Exodia specification](https://github.com/tiawl/exodia/blob/trunk/doc/00_index.md)
- [the Docker Engine API documentation](https://docs.docker.com/engine/api/)
- [the gomplate documentation](https://docs.gomplate.ca/) and [the Golang template documentation](https://pkg.go.dev/text/template)

## How to use it ?

In its container with this command:
```
TODO
```

If you want to use it on your laptop, follow steps described in this [Dockerfile](https://github.com/tiawl/exodia/blob/trunk/Dockerfile).

### How to run Exodia with a remote docker socket ?

If you use Exodia in its container, add this option to the `docker run` command:
```
-e DOCKER_HOST=${DOCKER_HOST}
```

If not, export `DOCKER_HOST` in your environment.

### What did you plan for the next releases ? How can I contribute to this project ?

You probably noticed that Exodia does not have a first major release. Why ? Because Exodia is ready to be used but is not mature. To go further, Exodia needs:
- feedbacks for its implemented features,
- to be rewritten with better tools,

Expect big breaking changes in the next releases, among them:
- Programming language shift: currently Exodia is written in Golang. This choice is only motivated by the fact that Golang is stable, compilated, imperative and has a large and complete APIs for Exodia needs. But for many reasons:
    1. garbage collector or unsafe memory management (choose your sick horse),
    2. the need to make Shell scripting around a Golang project,
    3. no Union and Enumeration types without alternatives (or with some awkward workarounds that fails to emulate correctly these features),
    4. functions with multi return values (it is a featurisis when a language already has pointers and structs),
    5. modules privacy managed with letter case (can I suggest a `pub` keyword ?),
    6. minimal error handling: no `try`, `catch` or `errdefer` keywords. Manage them with an `if` statement or ignore them.
    7. no Optional type,
    8. limited `const` keyword: not usable with Arrays, user types or something a little bit more complex than a primitive.
    9. no need of explicit management for returned values (it is easy to skip them because the compiler does not complain)

    when a better alternative will be stable, Exodia will be rewritten with.
- Template Engine shift (it will follow the programming language shift)
- Markup language shift (again: this task will follow the programming language shift)
- Removal of features made with bad design choices

With time, Exodia will be more stable. If you want to contribute and see Exodia growing, use Exodia for your project and open an issue later to see how we could improve it together. Any elaborated feedback will make Exodia better. So do not hesitate to open an issue: this is currently the best way to contribute.
