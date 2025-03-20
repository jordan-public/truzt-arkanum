# Token Registry Workaround

This is directly copied from the Aleo Standard Programs repo [here](https://github.com/demox-labs/aleo-standard-programs/blob/main/token_registry/src/main.leo), but the names of some functions are shortened to 31 characters or less, as the original program would not compile using the latest Leo compiler version 2.4.1 at the time of writing this. When this issue is resolved, this can be ignored and the original Token Registry program can be deployed to the Amareleo development node, or even better, if it's pre-installed, nothing would need to be done.

The error reported by the Leo version 2.4.1 was:
```
Error [EPAR0370044]: Identifier finalize_update_token_management is too long (32 bytes; maximum is 31)
...
```

This is not part of the project, but something I have discovered recently and reported.
