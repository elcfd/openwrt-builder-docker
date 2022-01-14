FROM        ubuntu:20.04

LABEL       maintainer  "elcfd <elcfd@whitetree.xyz>"

ENV         LANG                en_US.UTF-8
ENV         DEBIAN_FRONTEND     noninteractive
ENV         BROOT               /workdir/openwrt
ENV         PATH                $PATH:$BROOT/staging_dir/host/bin 
ENV         PATH                $PATH:$BROOT/staging_dir/toolchain-mips_34kc_gcc-5.3.0_musl-1.1.16

RUN         apt update && \
            apt install -y \
                git-core \
                subversion \
                mercurial \
                build-essential \
                libssl-dev \
                libncurses5-dev \
                unzip \
                gawk \
                zlib1g-dev \
                wget \
                locales \
                ncurses-dev \
                python3 \
                rsync \
                tree \
                sudo \
                tmux \
                dumb-init \
                vim && \
                apt autoremove -y && \
            /usr/sbin/locale-gen en_US.UTF-8

COPY        scripts/builder-setup.py \
            scripts/builder-launch.sh \
            /usr/bin/

COPY        files/sudoers.usersetup /etc/

RUN         groupadd -g 70 usersetup && \
            useradd -N -m -u 70 -g 70 usersetup && \
            chmod 755 /usr/bin/builder-setup.py \
                      /usr/bin/builder-launch.sh && \
            echo "#include /etc/sudoers.usersetup" >> /etc/sudoers

USER        usersetup

ENTRYPOINT  ["/usr/bin/dumb-init", "--", "builder-setup.py"]
CMD         ["--workdir=/workdir"]
