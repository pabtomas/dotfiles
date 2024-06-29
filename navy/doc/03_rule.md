# Rule object

- **description**: A set of interdependant Requests and/or Commands you want to run by invoking a simple command. You can thing a Navy rule as a GNU Make target. 
- **exemple**:
```yaml
rules:
  - id: 'new_alpine'
    description: 'create an '
    run:
      - endpoint: /images/create
        method: POST
        loop:
          - id: 'pull'
            query:
              fromImage: 'docker.io/library/alpine'
              tag: 'latest'
      - endpoint: /containers/create
        method: POST
        loop:
          - id: 'create'
            query:
              Image: 'docker.io/library/alpine:latest'
```

Now each time you are using `navy new_alpine` it will pull the latest alpine image and create a container base on this image.

### `Rule.id`

- **type**: string
- **required**: true
- **description**: The ID attributed to the rule you want to create. When the same ID is used for different Rule objects, that means that you want to play the actions they described when calling the associated rule.

### `Rule.description`

- **type**: string
- **required**: false
- **default**: `""`
- **description**: How the command will be described when Navy is called with its help option.

### `Rule.run`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: A list of Requests and Commands.
- **exemple**:
```yaml
rules:
  - id: 'up'
    run:
      - endpoint: /volumes/create
        method: POST
        loop:
          - query:
              Name: my-volume
          - query:
              Name: my-volume-2
```
