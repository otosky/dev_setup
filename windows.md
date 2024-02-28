# Developing on Windows

Do as little as you can on a Windows host.  Use WSL.

## WSL

### Install
Most of these steps are pulled from the [official WSL installation guide](https://learn.microsoft.com/en-us/windows/wsl/install).

from Powershell:
```powershell
wsl --install
```

This will install Ubuntu by default.  If you have a different distro of choice, you can specify it
when installing by using the `-d` flag.

from Powershell:
```powershell
wsl --install -d <Distribution Name>
```

### Setup

You will be prompted to create a username and password.

Following that, you will want to update the system packages for your new WSL install.

```sh
sudo apt update && sudo apt upgrade
```

### FAQ

#### Why aren't domain names resolving in web requests?

The DNS settings on WSL seem to be borked on new installs.

You can run the following set of commands to fix this:

In your WSL terminal:
```sh
echo "Wiping faulty resolv.conf..."
sudo rm /etc/resolv.conf
sudo bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'
sudo bash -c 'echo "[network]" > /etc/wsl.conf'
sudo bash -c 'echo "generateResolvConf = false" >> /etc/wsl.conf'
sudo chattr +i /etc/resolv.conf
```

#### Why is the clock wrong in my WSL session?

If running the `date` command shows the wrong date/time, you'll need to run resync the clock.

```sh
sudo hwclock -s
```

> Per this issue https://github.com/microsoft/WSL/issues/10006, the fix will be available in WSL v2.1.1+.


## Helpful Applications

The following can all be installed through the [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/) package manager.

from Powershell:
```powershell
winget install --id Microsoft.WindowsTerminal
winget install --id Microsoft.PowerToys
winget install --id Docker.DockerDesktop
```

## Resources

- Official Microsoft WSL Setup [Best Practices](https://learn.microsoft.com/en-us/windows/wsl/setup/environment) Guide

