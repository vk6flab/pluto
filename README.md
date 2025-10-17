# Build a Docker container for PlutoSDR
This project provides a Dockerfile that builds (and runs) the binaries used for the various tools that connect to the ADALM PlutoSDR. Much of this code is gathered from various sources and some library dependencies are duplicated as a result.

## Sources
The links shown here were used to determine the compile stages required for the three repositories. Other sources were used to determine weird workarounds such as the reorganisation of the `/lib` directory in Debian Bookworm.

### Analog Devices
* [Software-Defined Radio Workshops](https://wiki.analog.com/sdrseminars)
* [Build instructions for libiio](https://github.com/analogdevicesinc/libiio/blob/main/README_BUILD.md)
* [libad9361-iio: Building & Installing](https://github.com/analogdevicesinc/libad9361-iio/blob/main/README.md#building--installing)
* [IIO Oscilloscope: Installation - Linux](https://wiki.analog.com/resources/tools-software/linux-software/iio_oscilloscope#linuxos_x)
* [Instructions on installing the latest firmware](https://wiki.analog.com/university/tools/pluto/users/firmware#latest_release)
* [ssh configuration file](https://github.com/analogdevicesinc/plutosdr_scripts/blob/master/ssh_config)

### Debian
* [The Debian /usr Merge](https://wiki.debian.org/UsrMerge)
* [A "merged-/usr" is now required](https://www.debian.org/releases/bookworm/amd64/release-notes/ch-information.en.html#a-merged-usr-is-now-required)


# Usage
You can build this tool using:
* `docker build -t pluto:latest`

You can run it using:
* `docker run -it --rm pluto:latest [command]`

Where `[command]` can be any of the following (technically anything inside the container that's available on the default `$PATH`):
* `osc` - the IIO visualization and control tool
* `iio_attr` -  display information about local or remote IIO devices. By providing an optional value, iio_attr will attempt to write the new value to the attribute.
* `iio_genxml` - generate an XML representation of a Libiio context.
* `iio_info` - display information about local or remote IIO devices
* `iio_readdev` - read buffers from connected IIO devices, and send resutls to standard out.
* `iio_reg` - debug local IIO devices. It should not be used by normal users, and is normally used by driver developers during development, or by end users debugging a driver, or sending in a feature request. It provides a mechanism to read or write SPI or I2C registers for IIO devices. This can be useful when troubleshooting IIO devices, and understanding how the Linux IIO subsystem is managing the device.
* `iio_stresstest` - stress-testing program that can be used to find bugs in Libiio or in the Libiio daemon (IIOD).
* `iio_writedev` - write buffers from connected IIO devices.
* `iiod` - Linux Industrial I/O Subsystem daemon.
* `ssh` - OpenSSH SSH client (remote login program).
* `unzip` - list, test and extract compressed files in a ZIP archive.

If you do not supply a command, you'll be dropped into a `bash` shell where you'll have access to all the installed commands mentioned above.


# Tutorials
* [Intro To libIIO and IIOScope](https://github.com/sdrforengineers/LabGuides/blob/master/grcon2019/Intro-To-libIIO-and-IIOScope.pdf)
* [Intro To GNURadio IIO and PlutoSDR](https://github.com/sdrforengineers/LabGuides/blob/master/grcon2019/Intro-To-GNURadio-IIO-and-PlutoSDR.pdf)
* [PySDR: A Guide to SDR and DSP using Python](https://pysdr.org)

# To-Do
* Describe how to launch this and what it needs to work.
* Build and install manpages.
* Describe firmware files in `/home/docker`.
* Describe how to use `iiod`.
* Describe how to add software.
* Confirm that `python` works, so you can use the examples in [PySDR: A Guide to SDR and DSP using Python](https://pysdr.org).
* Describe the `ssh` settings
* Likely plenty more.


# References
* [European GNU Radio Days 2019 tutorials: PlutoSDR, Travis Collins (ADI)](https://www.youtube.com/watch?v=9rqR_uWuhsY) (YouTube)
* [European GNU Radio Days 2019 Workshops: PlutoSDR, Travis Collins (ADI)](https://wiki.analog.com/grdayseu2019) (wiki)
* [Enable Dual Receive and Dual Transmit for the new revision of Pluto](https://www.youtube.com/watch?v=ph0Kv4SgSuI)
* [Software-Defined Radio Workshops](https://wiki.analog.com/sdrseminars)
* [Labs for SDR for Engineers textbook](https://github.com/sdrforengineers/LabGuides)
* [Hacking the ADALM-PLUTO](https://wiki.analog.com/university/tools/pluto/hackers)
* [ADALM-PLUTO Overview](https://wiki.analog.com/university/tools/pluto)
* [One Liner to Download the Latest Release from Github Repo](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8)
* [Customizing the Pluto configuration](https://wiki.analog.com/university/tools/pluto/users/customizing)
