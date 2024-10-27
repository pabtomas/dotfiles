# Command object

You can start to use a Command object with the `command` keyword.

- **description**: A custom command for specific need or to compensate Mana's lacks.
- **examples**:
```json
rule:
  id: 'up'
  run:
    - command:
        id: commands.install.docker-cli
        argv:
          - 'apk'
          - 'add'
          - '--no-cache'
          - 'docker-cli'
        depends_on:
          - containers.start.my-container
    - command:
        id: commands.attach
        argv:
          - 'docker'
          - 'attach'
          - 'my-container'
        depends_on:
          - commands.install.docker-cli
```

### `Command.id`

- **type**: string
- **required**: true
- **description**: A unique ID attributed to a Command.

### `Command.depends_on`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: Mana uses as many process as possible and runs a task as soon as possible. So this is here that you can schedule the Mana execution. You can let this list empty but that means that you do not mind that the matching task runs first. This attribute takes a list of ID. Mana will run this task after the tasks listed here will end their execution.

### `Command.errexit`

- **type**: boolean
- **required**: false
- **default**: `true`
- **description**: If the command failed, Mana stops its execution in failure.

### `Command.if`

- **type**: boolean
- **required**: false
- **default**: true
- **description**: It the content is true, the matching task will be executed. Otherwise, it will not.

### `Command.argv`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: The list of arguments of your command.
