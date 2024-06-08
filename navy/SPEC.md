# Specification

## `versions`

**type**: list
**description**: List of Docker Engine API versions targetted by your project. Navy will run with the first available version. Navy will fail if the Docker Engine does not support any targetted version.
**exemple**:
```yaml
```

## `include`

**type**: list
**description**: List of files. Including files in another will merge their contents.
**exemple**:
```yaml
```

## `requests`

**type**: list
**description**: A list of requests. A request has 3 mandatory fields:
- `endpoint`,
- `method`,
- one between these fields:
  - `register`
  - `from`
  - `loop`
**exemple**:
```yaml
```

## `requests[].endpoint`

**type**: string
**description**: The HTTP request endpoint. Possible value are listed [here](https://docs.docker.com/engine/api/latest) depending of the Docker Engine API you are targetting.
**exemple**:
```yaml
```

## `requests[].method`

**type**: string
**description**: The HTTP request method to use (GET, POST, DELETE, ...).

## `requests[].register`

**type**: object
**description**:
**exemple**:
```yaml
```

## `requests[].register.query`

**type**: object
**description**:
**exemple**:
```yaml
```

## `requests[].register.datasource`

**type**: string
**description**:
**exemple**:
```yaml
```

## `requests[].from`

**type**: string
**description**:
**exemple**:
```yaml
```

## `requests[].loop`

**type**: list
**description**:
**exemple**:
```yaml
```

## `requests[].loop[].query`

**type**: dictionnary
**description**:
**exemple**:
```yaml
```

## `requests[].loop[].query.buildargs`

**type**: dictionnary
**description**:
**exemple**:
```yaml
```

## `requests[].loop[].path`

**type**: dictionnary
**description**:
**exemple**:
```yaml
```

## `requests[].loop[].id`

**type**: string
**description**:
**exemple**:
```yaml
```

## `requests[].loop[].virtual`

**type**: boolean
**description**:
**exemple**:
```yaml
```

## `requests[].loop[].context`

**type**: path
**description**:
**exemple**:
```yaml
```

## `requests[].loop[].depends_on`

**type**: list
**description**:
**exemple**:
```yaml
```

## `requests[].loop[].extends`

**type**: list
**description**:
**exemple**:
```yaml
```
