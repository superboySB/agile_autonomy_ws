Note for runing codes in x86_64 machines

# Requirements
Ubuntu 20.04 + RTX 3090

## Enabling Jetson Containers on an x86 workstation (Optional)
One of the very cool features that are now enabled is the ability to build Arm CUDA binaries on your x86 machine without needing a cross compiler. You can very easily run AArch64 containers on your x86 workstation by using qemu’s virtualization features. This section will go over the steps to enable that. The next section will go over the workflow that allows you to build on x86 and then run on Jetson. Installing the following packages should allow you to enable support for AArch64 containers on x86:
```sh
$ sudo apt-get install qemu binfmt-support qemu-user-static

# Check if the entries look good.
$ sudo cat /proc/sys/fs/binfmt_misc/status
enabled

# See if /usr/bin/qemu-aarch64-static exists as one of the interpreters.
$ cat /proc/sys/fs/binfmt_misc/qemu-aarch64
enabled
interpreter /usr/bin/qemu-aarch64-static
flags: OCF
offset 0
magic 7f454c460201010000000000000000000200b700
mask ffffffffffffff00fffffffffffffffffeffffff
```
Make sure the F flag is present, if not head to the troubleshooting section, as this will result in a failure to start the Jetson container. You’ll usually find errors in the form: exec user process caused "exec format error"