ARG BASE_IMAGE="buildpack-deps:latest"
FROM "${BASE_IMAGE}"

ARG BINUTILS_VERSION
ENV BINUTILS_VERSION="${BINUTILS_VERSION}"
ARG BINUTILS_SHA256

RUN set -ex; \
  \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    bison \
    texinfo \
  ; \
  rm -r /var/lib/apt/lists/*; \
  \
  curl -fL "https://ftpmirror.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.xz" -o 'binutils.tar.xz'; \
  echo "${BINUTILS_SHA256}  binutils.tar.xz" | sha256sum -c; \
  mkdir -p /usr/src/binutils; \
  tar -xf binutils.tar.xz -C /usr/src/binutils --strip-components=1; \
  rm binutils.tar.xz; \
  \
  dir="$(mktemp -d)"; \
  cd "$dir"; \
  \
  /usr/src/binutils/configure CFLAGS="-Wno-error=discarded-qualifiers"; \
  make -j "$(nproc)"; \
  make install-strip; \
  \
  cd ..; \
  \
  rm -rf "$dir" /usr/src/binutils

# https://gcc.gnu.org/mirrors.html
ENV GPG_KEYS="\
# 1024D/745C015A 1999-11-09 Gerald Pfeifer <gerald@pfeifer.com>
  B215C1633BCA0477615F1B35A5B3A004745C015A \
# 1024D/B75C61B8 2003-04-10 Mark Mitchell <mark@codesourcery.com>
  B3C42148A44E6983B3E4CC0793FA9B1AB75C61B8 \
# 1024D/902C9419 2004-12-06 Gabriel Dos Reis <gdr@acm.org>
  90AA470469D3965A87A5DCB494D03953902C9419 \
# 1024D/F71EDF1C 2000-02-13 Joseph Samuel Myers <jsm@polyomino.org.uk>
  80F98B2E0DAB6C8281BDF541A7C8C3B2F71EDF1C \
# 2048R/FC26A641 2005-09-13 Richard Guenther <richard.guenther@gmail.com>
  7F74F97C103468EE5D750B583AB00996FC26A641 \
# 1024D/C3C45C06 2004-04-21 Jakub Jelinek <jakub@redhat.com>
  33C235A34C46AA3FFB293709A328C3A2C3C45C06 \
# 4096R/09B5FA62 2020-05-28 Jakub Jelinek <jakub@redhat.com>
  D3A93CAD751C2AF4F8C7AD516C35B99309B5FA62"

# https://gcc.gnu.org/mirrors.html
ENV GCC_MIRRORS="\
  https://ftpmirror.gnu.org/gcc \
  https://mirrors.kernel.org/gnu/gcc \
  https://bigsearcher.com/mirrors/gcc/releases \
  http://www.netgull.com/gcc/releases \
  https://ftpmirror.gnu.org/gcc \
# "sourceware.org" is the canonical upstream release host (the host of "gcc.gnu.org")
  https://sourceware.org/pub/gcc/releases \
# only attempt the origin FTP as a mirror of last resort
  ftp://ftp.gnu.org/gnu/gcc"

ARG GCC_VERSION
ENV GCC_VERSION="${GCC_VERSION}"

COPY patches/gcc /usr/src/gcc/patches
RUN set -ex; \
  \
  savedAptMark="$(apt-mark showmanual)"; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    dpkg-dev \
    flex \
    # https://github.com/docker-library/gcc/pull/74#issuecomment-1250904354
    gawk \
    gnupg \
  ; \
  rm -r /var/lib/apt/lists/*; \
  \
  _fetch() { \
    local fetch="$1"; shift; \
    local file="$1"; shift; \
    for mirror in $GCC_MIRRORS; do \
      if curl -fL "$mirror/$fetch" -o "$file"; then \
        return 0; \
      fi; \
    done; \
    echo >&2 "error: failed to download '$fetch' from several mirrors"; \
    return 1; \
  }; \
  \
  _fetch "gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.xz.sig" 'gcc.tar.xz.sig'; \
  _fetch "gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.xz" 'gcc.tar.xz'; \
  export GNUPGHOME="$(mktemp -d)"; \
  for key in $GPG_KEYS; do \
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
  done; \
  gpg --batch --verify gcc.tar.xz.sig gcc.tar.xz; \
  gpgconf --kill all || killall gpg-agent dirmngr || true; \
  rm -rf "$GNUPGHOME"; \
  mkdir -p /usr/src/gcc; \
  tar -xf gcc.tar.xz -C /usr/src/gcc --strip-components=1; \
  rm gcc.tar.xz*; \
  \
  cd /usr/src/gcc; \
  \
# "download_prerequisites" pulls down a bunch of tarballs and extracts them,
# but then leaves the tarballs themselves lying around
  ./contrib/download_prerequisites; \
  { rm *.tar.* || true; }; \
  \
# explicitly update autoconf config.guess and config.sub so they support more arches/libcs
  for f in config.guess config.sub; do \
    wget -O "$f" "https://git.savannah.gnu.org/cgit/config.git/plain/$f?id=7d3d27baf8107b630586c962c057e22149653deb"; \
# find any more (shallow) copies of the file we grabbed and update them too
    find -mindepth 2 -name "$f" -exec cp -v "$f" '{}' ';'; \
  done; \
  \
  GCC_VERSION_MAJOR="$(echo "$GCC_VERSION" | cut -d '.' -f 1)"; \
  GCC_VERSION_MINOR="$(echo "$GCC_VERSION" | cut -d '.' -f 2)"; \
# libgo: handle stat st_atim32 field and SYS_SECCOMP
# https://gcc.gnu.org/git/?p=gcc.git;a=commit;h=762fd5e5547e464e25b4bee435db6df4eda0de90
  if [ "$GCC_VERSION_MAJOR" -lt 11 ]; then \
    patch -p1 < patches/backports/5.5.0/libgo-sys_seccomp.patch; \
  elif [ "$GCC_VERSION_MAJOR" -lt 13 ]; then \
    patch -p1 < patches/backports/11.5.0/libgo-sys_seccomp.patch; \
  fi; \
# libsanitizer: merge from upstream (87e6e490e79384a5)
# https://gcc.gnu.org/git/?p=gcc.git;a=commit;h=d96e14ceb9475f9bccbbc0325d5b11419fad9246
# [sanitizer] Remove crypt and crypt_r interceptors
# https://github.com/llvm/llvm-project/commit/d7bead833631486e337e541e692d9b4a1ca14edd
  if [ "$GCC_VERSION_MAJOR" -ge 10 -a "$GCC_VERSION_MAJOR" -lt 12 ]; then \
    patch -p1 < patches/backports/10.5.0/libsanitizer-remove-crypt-and-crypt_r-interceptors.patch; \
  elif [ "$GCC_VERSION_MAJOR" -eq 12 ]; then \
    patch -p1 < patches/backports/12.5.0/libsanitizer-remove-crypt-and-crypt_r-interceptors.patch; \
  elif [ "$GCC_VERSION_MAJOR" -eq 13 ]; then \
    patch -p1 < patches/backports/13.4.0/libsanitizer-remove-crypt-and-crypt_r-interceptors.patch; \
  fi; \
# libsanitizer: Fix build with glibc 2.42
# https://gcc.gnu.org/git/?p=gcc.git;a=commit;h=1789c57dc97ea2f9819ef89e28bf17208b6208e7
  if [ "$GCC_VERSION_MAJOR" -lt 10 ]; then \
    patch -p1 < patches/backports/5.5.0/libsanitizer-glibc-2.42.patch; \
  elif [ "$GCC_VERSION_MAJOR" -lt 12 ]; then \
    patch -p1 < patches/backports/10.5.0/libsanitizer-glibc-2.42.patch; \
  elif [ "$GCC_VERSION_MAJOR" -eq 15 -a "$GCC_VERSION_MINOR" -lt 2 ] || \
    [ "$GCC_VERSION_MAJOR" -eq 14 -a "$GCC_VERSION_MINOR" -lt 4 ] || \
    [ "$GCC_VERSION_MAJOR" -eq 13 -a "$GCC_VERSION_MINOR" -lt 5 ] || \
    [ "$GCC_VERSION_MAJOR" -eq 12 ]; then \
    curl -fL "https://gcc.gnu.org/git/?p=gcc.git;a=patch;h=1789c57dc97ea2f9819ef89e28bf17208b6208e7" | patch -p1; \
  fi; \
# [sanitizer_common] Remove reference to obsolete termio ioctls (#138822)
# https://gcc.gnu.org/git/?p=gcc.git;a=commit;h=dbe0ba6c90d53229613c7eb3f476580ae1b9aae1
  if [ "$GCC_VERSION_MAJOR" -lt 10 ]; then \
    patch -p1 < patches/backports/5.5.0/libsanitizer-termio-ioctls.patch; \
  elif [ "$GCC_VERSION_MAJOR" -eq 15 -a "$GCC_VERSION_MINOR" -lt 2 ] || \
    [ "$GCC_VERSION_MAJOR" -eq 14 -a "$GCC_VERSION_MINOR" -lt 4 ] || \
    [ "$GCC_VERSION_MAJOR" -eq 13 -a "$GCC_VERSION_MINOR" -lt 5 ] || \
    [ "$GCC_VERSION_MAJOR" -le 12 ]; then \
    curl -fL "https://gcc.gnu.org/git/?p=gcc.git;a=patch;h=dbe0ba6c90d53229613c7eb3f476580ae1b9aae1" | patch -p1; \
  fi; \
# [PATCH] libgomp: Fix GCC build after glibc@cd748a6
# https://gcc.gnu.org/git/?p=gcc.git;a=commit;h=9c9d3aef2f66625d9cb03ef4baee10ed6648e681
  if [ "$GCC_VERSION_MAJOR" -eq 15 -a "$GCC_VERSION_MINOR" -lt 3 ] || \
    [ "$GCC_VERSION_MAJOR" -eq 14 -a "$GCC_VERSION_MINOR" -lt 4 ] || \
    [ "$GCC_VERSION_MAJOR" -eq 13 -a "$GCC_VERSION_MINOR" -lt 5 ] || \
    [ "$GCC_VERSION_MAJOR" -le 12 ]; then \
    curl -fL "https://gcc.gnu.org/git/?p=gcc.git;a=patch;h=9c9d3aef2f66625d9cb03ef4baee10ed6648e681" | patch -p1; \
  fi; \
  \
  dir="$(mktemp -d)"; \
  cd "$dir"; \
  \
  extraConfigureArgs=''; \
  dpkgArch="$(dpkg --print-architecture)"; \
case "$dpkgArch" in \
# with-arch: https://salsa.debian.org/toolchain-team/gcc/-/blob/gcc-11-debian/debian/rules2#L462-502
# with-float: https://salsa.debian.org/toolchain-team/gcc/-/blob/gcc-11-debian/debian/rules.defs#L502-512
# with-mode: https://salsa.debian.org/toolchain-team/gcc/-/blob/gcc-11-debian/debian/rules.defs#L480
  armel) \
    extraConfigureArgs="$extraConfigureArgs --with-arch=armv5te --with-float=soft" \
  ;; \
  armhf) \
    if [ "$GCC_VERSION_MAJOR" -ge 11 ]; then \
      # https://bugs.launchpad.net/ubuntu/+source/gcc-defaults/+bug/1939379/comments/2
      extraConfigureArgs="$extraConfigureArgs --with-arch=armv7-a+fp --with-float=hard --with-mode=thumb"; \
    else \
      extraConfigureArgs="$extraConfigureArgs --with-arch=armv7-a --with-float=hard --with-fpu=vfpv3-d16 --with-mode=thumb"; \
    fi; \
  ;; \
  \
# with-arch-32: https://salsa.debian.org/toolchain-team/gcc/-/blob/gcc-11-debian/debian/rules2#L598
  i386) \
    extraConfigureArgs="$extraConfigureArgs --with-arch-32=i686"; \
    ;; \
  esac; \
  \
  gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
  /usr/src/gcc/configure \
    --build="$gnuArch" \
    --disable-multilib \
    --enable-languages=c,c++,fortran,go \
    $extraConfigureArgs \
  ; \
  make -j "$(nproc)"; \
  make install-strip; \
  \
  cd ..; \
  \
  rm -rf "$dir" /usr/src/gcc; \
  \
  apt-mark auto '.*' > /dev/null; \
  [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

# ensure that alternatives are pointing to the new compiler and that old one is no longer used
RUN set -ex; \
  dpkg-divert --divert /usr/bin/gcc.orig --rename /usr/bin/gcc; \
  dpkg-divert --divert /usr/bin/g++.orig --rename /usr/bin/g++; \
  dpkg-divert --divert /usr/bin/gfortran.orig --rename /usr/bin/gfortran; \
  update-alternatives --install /usr/bin/cc cc /usr/local/bin/gcc 999
