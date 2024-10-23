# Processor object

You can start to use a Processor object with the `processor` keyword.

- **description**: A Processor object allows you to process JSON data contained in a variable and define new variables with.
- **examples**: Here 2 examples: one with the `Requests.depends_on` attribute and another one with the `Requests.depends_on` and `Request.if` attributes introduced earlier in this documentation.
    1.
    ```json
    rule:
      id: 'prune_networks'
      run:
        - requests:
            endpoint: /networks
            method: GET
            with:
              - body:
                  id: get.networks
                  register: listed_networks
        - processor:
            id: process.remove.networks
            register: networks_to_remove
            input: '{{ listed_networks }}'
            filter: '[{ path: { id: .[].Name } }]'
            depends_on:
              - get.networks
        - requests:
            endpoint: /networks/{id}
            method: DELETE
            with: '{{ networks_to_remove }}'
            depends_on:
              - process.remove.networks
    ```
    The first `requests` task will register the response of `/networks` endpoint request into `listed_networks`. Thank to the `depends_on` attribute, the processor task is the next to be executed. This task will apply the JQ filter to the registered data from the first task and save it into the `networks_to_remove` variable. After that the `networks_to_remove` is used to delete all the listed networks. In the last `requests` task, if the `depends_on` attribute is not used, the task is processed at the same time than the first one but will not delete anything because `networks_to_remove` is not already filled by the second task.
    2.
    ```json
    rule:
      id: 'rm_big_volume'
      run:
        - requests:
            endpoint: /volumes
            method: GET
            with:
              - body:
                  id: get.volumes
                  register: listed_volumes
        - processor:
            id: process.remove.networks
            register: more_than_5_volumes
            input: '{{ listed_networks }}'
            filter: '[.Volumes[].Name] | length > 5'
            depends_on:
              - get.networks
        - requests:
            if: '{{ more_than_5_volumes }}'
            endpoint: /volumes/{id}
            method: DELETE
            with:
              path:
                id: big_volume
            depends_on:
              - process.remove.networks
    ```
    This rule follows the same execution than the previous example but we added a conditionnal: it will remove the volume named `big_volume` if there are more than 5 created volumes.

### `Processor.id`

- **type**: string
- **required**: true
- **description**: A unique ID attributed to a processor task.

### `Processor.register`

- **type**: string 
- **required**: true
- **description**: Contrary to `Body.register`, this attribute is required and must not be empty. The resulting JSON data of the processor task will be stored in the variable with the name you wrote. If the variable is not empty, the content will be erased.

### `Processor.input`

- **type**: dictionnary
- **required**: true
- **description**: The JSON input to process. Must be JSON input.

### `Processor.filter`

- **type**: string
- **required**: true
- **description**: The JQ filter. It takes `Processor.input` as input. See the `jq` manpage for more details and this [link](https://github.com/fiatjaf/awesome-jq) to see the possibilities this functionnal language offers.

### `Processor.if`

- **type**: boolean
- **required**: false
- **description**: It the content is true, the matching task will be executed. Otherwise, it will not.

### `Processor.depends_on`

- **type**: list
- **required**: false
- **default**: `[]`
- **description**: Navy uses as many process as possible and runs a task as soon as possible. So this is here that you can schedule the Navy execution. You can let this list empty but that means that you do not mind that the variables used into the Requests attributes are evaluated first. This attribute takes a list of ID. Navy will the processor task after the other objects listed here will end their execution.
