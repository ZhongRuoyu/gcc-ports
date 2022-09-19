# gcc-backports

This project backports [GCC](https://gcc.gnu.org/), the GNU Compiler
Collection, to older versions of Debian and Ubuntu. This enables executables
that require newer toolchains to be built on older systems for distribution
purposes.

## Images

The backports are available as Docker images at
[Docker Hub](https://hub.docker.com/r/zhongruoyu/gcc-backports).

The image tags are in the format of `version-codename`, where `version` is the
GCC version, and `codename` is the codename of the Debian/Ubuntu distribution.
The GCC version takes one of the following [SemVer](https://semver.org/)
formats: `major`, `major.minor`, `major.minor.patch`; but not all minor versions
are available. Please refer to the complete
[list of tags](https://hub.docker.com/r/zhongruoyu/gcc-backports/tags).

Below lists the Docker images provided by this project, and reasons why certain
versions are not provided.

|        | Debian 10 (Buster)                                            | Debian 9 (Stretch) | Ubuntu 20.04 (Focal)                                                                                           | Ubuntu 18.04 (Bionic)                                                                                          | Ubuntu 16.04 (Xenial)                                                                                          |
| ------ | ------------------------------------------------------------- | ------------------ | -------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| GCC 12 | `12-buster`                                                   | `12-stretch`       | `12-focal`                                                                                                     | `12-bionic`                                                                                                    | `12-xenial`                                                                                                    |
| GCC 11 | `11-buster`                                                   | `11-stretch`       | _Available in [`ppa:ubuntu-toolchain-r/test`](https://launchpad.net/~ubuntu-toolchain-r/+archive/ubuntu/test)_ | _Available in [`ppa:ubuntu-toolchain-r/test`](https://launchpad.net/~ubuntu-toolchain-r/+archive/ubuntu/test)_ | `11-xenial`                                                                                                    |
| GCC 10 | _Available as [official image](https://hub.docker.com/_/gcc)_ | `10-stretch`       | _Available in [official repository](https://packages.ubuntu.com/focal/gcc-10)_                                 | _Available in [`ppa:ubuntu-toolchain-r/test`](https://launchpad.net/~ubuntu-toolchain-r/+archive/ubuntu/test)_ | `10-xenial`                                                                                                    |
| GCC 9  | _Available as [official image](https://hub.docker.com/_/gcc)_ | `9-stretch`        | _Available in [official repository](https://packages.ubuntu.com/focal/gcc-9)_                                  | _Available in [`ppa:ubuntu-toolchain-r/test`](https://launchpad.net/~ubuntu-toolchain-r/+archive/ubuntu/test)_ | _Available in [`ppa:ubuntu-toolchain-r/test`](https://launchpad.net/~ubuntu-toolchain-r/+archive/ubuntu/test)_ |

The images provided by this project are modified from Docker's
[official image](https://github.com/docker-library/gcc) (under
[GPL-3.0 License](https://github.com/docker-library/gcc/blob/master/LICENSE)).
To ensure compatibility, only the minimum, necessary changes are introduced.

The most recent Debian and Ubuntu versions are not, nor do they need to be,
supported by this project.

## License

This project is licensed under the [GPL-3.0 License](LICENSE).
