# Rule object

You can start to use a Rule object with the `rule` keyword.

- **description**: A set of interdependant Requests and/or Commands you want to run by invoking a simple command. You can thing a Navy rule as a GNU Make target. 
- **exemple**:
```json
rules:
  - id: 'alpine'
    description: 'pull the official Alpine image and create an Alpine container'

rule:
  id: 'alpine'
  run:
    - requests:
        endpoint: /images/create
        method: POST
        with:
          - body:
              id: 'pull'
              query:
                fromImage: 'docker.io/library/alpine'
                tag: 'latest'
    - requests:
        endpoint: /containers/create
        method: POST
        with:
          - body:
              id: 'create'
              query:
                Image: 'docker.io/library/alpine:latest'
```

Now each time you are using `navy alpine` it will pull the latest alpine image and create a container based on this image.

**important note**: `rules` and `rule` are linked but different:
- `rules` allows you to describe with text the set of rules you want to use in your project. `rules` is a List.
- `rule` allows you to describe the execution of a rule in this project. `rule` is an Object.

### `Rule.id`

- **type**: string
- **required**: true
- **description**: The ID attributed to the rule you want to create. When the same ID is used for different Rule objects, that means that you want to play the whole set of actions described when calling the associated rule.

### `Rule.run`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: A list of Requests and Commands.
- **exemple**:
```json
rule:
  id: 'up'
  run:
    - requests:
        endpoint: /volumes/create
        method: POST
        with:
          - body:
              id: create.my-volume
              query:
                Name: my-volume
          - body:
              id: create.my-volume-2
              query:
                Name: my-volume-2
```
