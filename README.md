# Screens

> A menu bar GUI for opening apps running on the `screen` terminal multiplexer. macOS 13+

To get started, launch the app and open the settings window from the terminal icon in the menu bar if it isn’t already visible.

Currently, you can configure two types of source:

- Local sources run a `screen` binary on your file system (with optional additional options/env variables) and parse its output.
- SSH sources connect over a persistent SSH connection (which will be restarted if it fails), run a `screen` binary, and parse its output.

You can configure as many sources as you want, and you could even change the command to e.g. run `screen` inside a Docker container.

All active screen sessions will appear in the menu bar menu. Selecting one will open the Terminal app (configurable by changing the default app for opening `.command` files) with the selected screen. Note that only one terminal at a time can view a screen, so opening a screen will disable its entry in the menu bar. Use ^A^D to detach a screen and allow it to be selected from the menu again. 

You can customize the following options, in addition to the sources:

- Update frequency (seconds, min 0.5, can use fractions if desired): how often to ping all of the different `screen` instances. A higher value means less CPU and energy usage. This is not an exact measure, the system may choose to slightly adjust the interval to improve system performance.
- Hide empty sources: remove sources with no active screens from the list in the menu bar rather than displaying them with a “No active screens” message
- Launch at login: automatically start the app at login.

## Building Locally

Make sure you have the relevant libraries installed:

```shellsession
$ brew install libssh2 openssl
```

Then build & run! You might encounter an error about a cyclic build dependency. I’m not sure why that happens but you should be able to do a clean and rebuilt to fix it.
