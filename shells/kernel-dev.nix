# This file creates a nix-shell for linux kernel development

with import <nixpkgs> {};
{
    testEnv = stdenv.mkDerivation {
        name = "linux-kernel-dev-env";
        buildInputs = [
            stdenv
            git
            gnumake
            ncurses
            bc
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
        ];

        shellHook = ''
            echo "Starting Linux Kernel 6.1.25 development environment..."
            cd /home/landon/kernel-dev/linux-6.1.25 
        '';

    };
}