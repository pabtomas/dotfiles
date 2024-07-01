# Debugging

Exodia is young and currently debugging is not as developed as it could be for other tools. Here some keys to help you.

## Known common mistakes

TODO

## Log levels

Exodia has 8 log levels:
1. FATAL: Exodia can not go further because of its environment,
2. ERROR: Exodia can not go further because something is wrong in its input (from files or given options),
3. WARN: Exodia detects an error but can ignore it and continue its execution,
4. INFO: Exodia reports a user success during its execution,
5. NOTE: Exodia reports an internal success during its execution,
6. DEBUG: Exodia reports details about a request to the Docker Engine or a user command,
7. TRACE: Exodia traces its execution,
8. VERB: Exodia reports as much details as possible about its execution.

Here some important facts about log levels:
- In the above list, levels are listed in ascending order.
- By default, Exodia logs INFO, WARN, ERROR and FATAL messages. But you can change this behavior with the `-v` and `-q` options.
- More the log level is reduced (with `-q`), more the log level is higher in the above list: `-q` hides INFO messages and under, `-qq` hides WARN messages and under.
- ERROR and FATAL messages can not be hidden when reducing log levels.
- More the log level is increased (with `-v`), more the log level is lower in the above list: `-v` shows NOTE messages and above, `-vv` shows DEBUG messages and above, ...
- NOTE and DEBUG message are conceived to debug your Exodia projects.
- TRACE and VERB message are conceived for development purposes so please **use `-vvv` and `-vvvv` options with caution**. Maybe you can find some useful debugging information with, but this not the purpose of these options. When used, expect a lot of internal content (maybe cryptic or not useful for your current debugging session) and several minutes of latency (especially for the last level).
