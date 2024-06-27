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
- **description**: See `Body.id`.

### `Command.depends_on`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: See `Body.depends_on`.

### `Command.errexit`

- **type**: boolean
- **required**: false
- **default**: `true`
- **description**: See `Body.errexit`.

### `Command.if`

- **type**: boolean
- **required**: false
- **default**: true
- **description**: See `Request.if`.

### `Command.argv`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: The list of arguments of your command.
