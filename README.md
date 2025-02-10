# GCC Ports

This project ports [GCC](https://gcc.gnu.org/), the GNU Compiler Collection, to
all recent Debian and Ubuntu releases. This enables executables that require
newer toolchains to be built on specific systems for distribution purposes.

## Images

The ports are available as Docker images at
[Docker Hub](https://hub.docker.com/r/zhongruoyu/gcc-ports). They are modified
from, and remain highly compatible with, Docker's
[official images](https://github.com/docker-library/gcc) (under
[GPL-3.0 License](https://github.com/docker-library/gcc/blob/master/LICENSE)).
They also come with the latest release of
[GNU Binutils](https://www.gnu.org/software/binutils/) (currently version
2.44).

The image tags are in the format of `version-codename`, where `version` is the
GCC release version, and `codename` is the codename of the Debian/Ubuntu
release. For example, tag `12.2.0-jammy` refers to the image with GCC 12.2.0 on
Ubuntu 22.04 (Jammy Jellyfish).

The following GCC releases are available:

| GCC release | versions as appeared in tags |
| ----------- | ---------------------------- |
| GCC 14.2.0  | `14`, `14.1`, `14.2.0`       |
| GCC 13.3.0  | `13`, `13.2`, `13.3.0`       |
| GCC 12.4.0  | `12`, `12.3`, `12.4.0`       |
| GCC 11.5.0  | `11`, `11.4`, `11.5.0`       |
| GCC 10.5.0  | `10`, `10.5`, `10.5.0`       |
| GCC 9.5.0   | `9`, `9.5`, `9.5.0`          |

The following Debian/Ubuntu releases are available:

| Release                        | codename as appeared in tags |
| ------------------------------ | ---------------------------- |
| Debian 12 (Bookworm)           | `bookworm`                   |
| Debian 11 (Bullseye)           | `bullseye`                   |
| Debian 10 (Buster)             | `buster`                     |
| Ubuntu 24.04 (Noble Numbat)    | `noble`                      |
| Ubuntu 22.04 (Jammy Jellyfish) | `jammy`                      |
| Ubuntu 20.04 (Focal Fossa)     | `focal`                      |
| Ubuntu 18.04 (Bionic Beaver)   | `bionic`                     |
| Ubuntu 16.04 (Xenial Xerus)    | `xenial`                     |

See [here](https://hub.docker.com/r/zhongruoyu/gcc-ports/tags) for a complete
list of tags.

## License

This project is licensed under the [GPL-3.0 License](LICENSE).
