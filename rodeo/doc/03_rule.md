# Rule object

You can start to use a Rule object with the `rule` keyword. You can describe only one (or part of one) rule by file.

- **description**: A rule tells Rodeo how to execute a serie of tasks by invoking a simple command. You can thing a Rodeo rule as a GNU Make rule. 
- **example**:
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

Now each time you are using `rodeo alpine` it will pull the latest alpine image and create a container based on this image.

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
- **description**: This is where you are describing the whole execution of a rule. It contains a list of tasks. A tasks is one of this 3 possibilities:
    - a request,
    - a command,
    - or a rule (virtual or not).
- **examples**:
    - Here a first example with requests and command:
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
    - Here a more complex example with rule:
    *description rules in a first file:*
    ```json
    rules:
      - id: 'up'
        description: 'create a volume, create a container and attach it the created volume'
      - id: 'volume'
        description: 'create a volume'
        virtual: true
    ```
    In this file, `volume` rule is virtual and `up` rule is not. So you can execute `rodeo up` but not `rodeo volume`.
    *a second file for the* `volume` *rule:*
    ```json
    rule:
      id: 'volume'
      run:
        - requests:
            endpoint: /volumes/create
            method: POST
            with:
              - body:
                  id: 'create.my-volume'
                  query:
                    Name: 'my-volume'
    ```
    We defined the `volume` virtual rule as any regular rule.
    *a third file for the* `up` *rule:*
    ```json
    rule:
      id: 'up'
      run:
        - rule:
            id: 'volume'
        - requests:
            endpoint: /containers/create
            method: POST
            with:
              - body:
                  id: 'create.my-container'
                  query:
                    name: 'my-container'
                    HostConfig:
                      Mounts:
                        - Source: 'my-volume'
                          Target: '/tmp/my-volume'
                          Type: volume
                          VolumeOptions: {}
                  depends_on:
                    - 'create.my-volume'
    ```
    Finally Rodeo will run the `volume` rule when the `up` rule is executed. This is why, we needed to make the `create.my-container` task depends on the `create.my-volume` task. Even if those tasks are not coming from the same rule. With this, we ensure that `create.my-containers` will only be executed when `create.my-volume` finished.
