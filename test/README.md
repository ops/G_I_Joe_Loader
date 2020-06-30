# G.I. Joe Loader test program

## Compile

Makefile is provided for Linux. Add correct `target` parameter
depending on your platform.

```
        make target=vic20 image
        make target=c64 image
        make target=c16 image
        make target=c128 image
```

This will produce ready to run disk image (`gij-loader.d64`)
for your platform.
