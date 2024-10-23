# The traditional hello-world

### The code

```json
TODO
```

### What does it mean ?

Navy instructions are expressed in JSON format. I know better human readable and writable formats exist, so why ? There are multiple reasons for this:
* Popular Markup Languages are not well suited for this project:
    * YAML is too complex, 
    * TOML is not easily readable for complex projects and the goal of Navy is to support complex projects that Compose can not,
* ZON was too young when the Navy development process started:
    * No support for parsing in the Zig standard library
    * No available processor 
* JSON is already supported by the Zig standard library
* JSON can be processed with the libjq C API
* JSON is already used by the Docker Engine when responding to a request

TODO

### Going further

Check this project if you want to see a more advanced usage: [tiawl/MyWhaleFleet](https://github.com/tiawl/MyWhaleFleet)
