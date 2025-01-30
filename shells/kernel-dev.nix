# This file creates a nix-shell for linux kernel development

with import <nixpkgs> {};

let
  kernel-install = pkgs.writeShellScriptBin "kernel-install" ''
    set -e

    IMAGE_NAME="qemu-image.img"
    MOUNT_DIR="mount-point.dir"
    DEBIAN_RELEASE="bookworm"

    # Create disk image
    qemu-img create "$IMAGE_NAME" 10G
    mkfs.ext2 "$IMAGE_NAME"

    # Mount and debootstrap
    mkdir -p "$MOUNT_DIR"
    sudo mount -o loop "$IMAGE_NAME" "$MOUNT_DIR"
    sudo debootstrap --arch amd64 "$DEBIAN_RELEASE" "$MOUNT_DIR"

    # Set root password
    sudo chroot "$MOUNT_DIR" /bin/bash -i
    export PATH=$PATH:/bin
    passwd
    exit

    sudo umount "$MOUNT_DIR"
    echo "Debian image created: $IMAGE_NAME"
  '';

  create-img = pkgs.writeShellScriptBin "create-img" ''
    set -e

    export IMAGE=./img
    mkdir $IMAGE
    cd $IMAGE/
    wget https://raw.githubusercontent.com/google/syzkaller/master/tools/create-image.sh -O create-image.sh
    chmod +x create-image.sh
    ./create-image.sh --distribution bookworm -s 1024 -f minimal
    echo "Debian image created"
  '';

  img-add-tools = pkgs.writeShellScriptBin "img-add-tools" ''
    set -e

    IMAGE_NAME="qemu-image.img"
    MOUNT_DIR="mount-point.dir"

    # Mount and add tools
    sudo mount -o loop "$IMAGE_NAME" "$MOUNT_DIR"
    sudo chroot "$MOUNT_DIR" /bin/bash -c "
      export PATH=\$PATH:/bin
      apt update && apt install -y pciutils tree
    "

    sudo umount "$MOUNT_DIR"
    echo "Tools added to image: $IMAGE_NAME"
  '';

  run-qemu = pkgs.writeShellScriptBin "run-qemu" ''
    set -e

    KERNEL_PATH="arch/x86/boot/bzImage"
    IMAGE_NAME="qemu-image.img"

    if [ ! -f "$KERNEL_PATH" ] || [ ! -f "$IMAGE_NAME" ]; then
      echo "Error: Kernel or disk image missing."
      exit 1
    fi

    qemu-system-x86_64 -s -S \
      -kernel "$KERNEL_PATH" \
      -hda "$IMAGE_NAME" \
      -append "root=/dev/sda console=ttyS0 nokaslr" \
      -enable-kvm \
      -nographic
  '';

  run-gdb = pkgs.writeShellScriptBin "run-gdb" ''
    set -e

    KERNEL_PATH="./vmlinux"

    if [ ! -f "$KERNEL_PATH" ]; then
      echo "Error: Kernel vmlinux not found."
      exit 1
    fi

    echo "add-auto-load-safe-path `pwd`/scripts/gdb/vmlinux-gdb.py" >> ~/.gdbinit
    gdb -ex "target remote :1234" "$KERNEL_PATH"
  '';
in {
    testEnv = stdenv.mkDerivation {
        name = "linux-kernel-dev-env";
        buildInputs = [
            stdenv
            git
            gnumake
            ncurses
            bc
            binutils
            flex
            bison
            elfutils
            openssl
            openssh
            util-linux
            #linux-headers
            qemu_full
            debootstrap
            gcc
            gdb
            getopt
            clang_16
            clang-tools_16
            lld_16
            llvmPackages_16.libllvm
            cppcheck
            cscope
            #emacs-auto-complete-exuberant-ctags
            curl
            fakeroot
            flawfinder
            gnuplot
            hwloc
            indent
            numad
            man-db
            #net-tools
            numactl
            openjdk
            #perf-tools-unstable
            psmisc
            python3
            perl
            pahole
            pkg-config
            rt-tests
            #r-procmaps
            smem
            sparse
            stress
            sysfsutils
            tldr
            trace-cmd
            tree
            tuna
            virt-what
            zlib
            kernel-install
            create-img
            img-add-tools
            run-qemu
            run-gdb
        ];

        shellHook = ''
            echo "Starting Linux Kernel 6.1.25 development environment..."
            cd /home/landon/kernel-dev/linux-6.1.25 
            export KSRC=/home/landon/kernel-dev/linux-6.1.25
            export INSTALL_MOD_PATH=/home/landon/kernel-dev/linux-6.1.25/modules
        '';

    };
}