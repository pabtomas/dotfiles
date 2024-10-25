# The traditional hello-world

### Preambule

Before going into the hello-world code, here some useful details to help you reading the next examples:
* Rodeo instructions are expressed in JSON format. I know better human readable and writable formats exist, so why ? There are multiple reasons for this:
    * Popular Markup Languages are not well suited for this project:
        * YAML is too complex,
        * XML is too verbose,
        * TOML is not easily readable for complex projects and the goal of Rodeo is to support complex projects that Compose can not,
    * ZON was too young when the Rodeo development process started:
        * No support for parsing in the Zig standard library
        * No available processor
    * JSON is already supported by the Zig standard library
    * JSON can be processed with the libjq C API
    * JSON is already used by the Docker Engine when responding to a request
* Rodeo uses an inventory where you can define variables you can use after in your Rodeo rules.
* Whenever a string starts with `{{` and ends with `}}`, the content is evaluated as a jqlang program where:
    * the input is the inventory you defined
    * the output will replace your jqlang program.

### The code

```json
TODO
```

### What does it mean ?

Here what Rodeo will do when executed with this example:
TODO

### Going further

Check this project if you want to see a more advanced usage: [tiawl/MyWhaleFleet](https://github.com/tiawl/MyWhaleFleet)
