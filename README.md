# gcc-ports

This project ports [GCC](https://gcc.gnu.org/), the GNU Compiler Collection, to
all recent Debian and Ubuntu releases. This enables executables that require
newer toolchains to be built on specific systems for distribution purposes.

## Images

The ports are available as Docker images at
[Docker Hub](https://hub.docker.com/r/zhongruoyu/gcc-ports). They are modified
from, and remain highly compatible with, Docker's
[official images](https://github.com/docker-library/gcc) (under
[GPL-3.0 License](https://github.com/docker-library/gcc/blob/master/LICENSE)).
They also ship with the latest release of
[GNU Binutils](https://www.gnu.org/software/binutils/) (currently version
2.39).

The image tags are in the format of `version-codename`, where `version` is the
GCC version, and `codename` is the codename of the Debian/Ubuntu release. For
example, tag `12.2.0-jammy` refers to the image with GCC version 12.2.0 on
Ubuntu 22.04 (Jammy Jellyfish).

The following GCC versions are available:

| GCC version | versions as appeared in tags |
| ----------- | ---------------------------- |
| GCC 12.2.0  | `12`, `12.2`, `12.2.0`       |
| GCC 11.3.0  | `11`, `11.3`, `11.3.0`       |
| GCC 10.4.0  | `10`, `10.4`, `10.4.0`       |
| GCC 9.5.0   | `9`, `9.5`, `9.5.0`          |

The following Debian/Ubuntu releases are available:

| Release                        | codename as appeared in tags |
| ------------------------------ | ---------------------------- |
| Debian 11 (Bullseye)           | `bullseye`                   |
| Debian 10 (Buster)             | `buster`                     |
| Debian 9 (Stretch)             | `stretch`                    |
| Ubuntu 22.04 (Jammy Jellyfish) | `jammy`                      |
| Ubuntu 20.04 (Focal Fossa)     | `focal`                      |
| Ubuntu 18.04 (Bionic Beaver)   | `bionic`                     |
| Ubuntu 16.04 (Xenial Xerus)    | `xenial`                     |

See [here](https://hub.docker.com/r/zhongruoyu/gcc-ports/tags) for a complete
list of tags.

## License

This project is licensed under the [GPL-3.0 License](LICENSE).