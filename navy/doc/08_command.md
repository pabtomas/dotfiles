# Command object

- **description**: A custom command for specific need or to compensate Navy's lacks.
- **exemples**:
```yaml
rules:
  - id: 'up'
    run:
      - id: commands.install.docker-cli
        argv:
          - 'apk'
          - 'add'
          - '--no-cache'
          - 'docker-cli'
        depends_on:
          - containers.start.my-container
      - id: commands.attach
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
- **description**: Navy uses as many process as possible and runs a Request (or Command) as soon as possible. So this is here that you can schedule the Navy execution. You can let this list empty but that means that you do not mind that the matching Request or Command runs first. This attribute takes a list of ID. Navy will run the Request after the Requests and Commands listed here will end their execution.

### `Command.errexit`

- **type**: boolean
- **required**: false
- **default**: `true`
- **description**: If the Request failed, Navy stops its execution in failure.

### `Command.if`

- **type**: boolean
- **required**: false
- **default**: true
- **description**: The result of this expression must a boolean. It this expression is evaluated as true, the matching Request will be executed. Otherwise, it will not.

### `Command.argv`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: The list of arguments of your command.
