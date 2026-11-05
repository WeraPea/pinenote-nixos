{
  lib,
  writeShellScriptBin,
  android-tools,
  coreutils,
  gnugrep,
  gnused,
  nbdkit,
}:
writeShellScriptBin "usb-helper" ''
  set -euo pipefail
  export PATH="${
    lib.makeBinPath [
      android-tools
      coreutils
      gnugrep
      gnused
      nbdkit
    ]
  }:$PATH"
  # based on https://github.com/PorQ-Pine/netboot-host
  # NOTE: initrd and dtb memory locations happen to work now, but could stop if kernel or initrd sizes change enough

  config=""
  toplevel=""
  nixos_img=""
  squashfs_img=""
  netboot=""

  function print_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Stage a NixOS kernel, initrd and dtb onto a PineNote over fastboot and"
    echo "print the U-Boot commands needed to boot it from a usb stick or netboot."
    echo ""
    echo "Options:"
    echo "  -c, --config <name>       NixOS configuration to build the toplevel from"
    echo "                            (default: pinenote-usb-cross)"
    echo "  -t, --toplevel <path>     Use an existing system toplevel containing kernel, initrd"
    echo "                            and dtbs instead of building one from --config"
    echo "  -i, --image <path>        NixOS disk image to read the extlinux APPEND line from"
    echo "                            instead of constructing it from toplevel"
    echo "  -n, --netboot             Start serving squashfs store after booting from U-Boot"
    echo "                            sets config to default 'pinenote-netboot-cross'"
    echo "  -s, --squashfs-img <path> Use an existing squashfs image for netboot instead"
    echo "                            of building it from config"
    echo "  -h, --help                Show this help message"
  }

  while [[ $# -gt 0 ]]; do
    case "$1" in
    -c|--config)
      config="$2"
      shift 2
      ;;
    -t|--toplevel)
      toplevel="$2"
      shift 2
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    -i|--image)
      nixos_img="$2"
      shift 2
      ;;
    -n|--netboot)
      netboot=1
      shift 1
      ;;
    -s|--squashfs-img)
      squashfs_img="$2"
      shift 2
      ;;
    *)
      echo "invalid argument,"
      print_help
      exit 1
      ;;
    esac
  done

  if [[ -z "$config" ]]; then
    if [[ -z "$netboot" ]]; then
      config="pinenote-usb-cross"
    else
      config="pinenote-netboot-cross"
    fi
  fi

  if [[ -z "$toplevel" ]]; then
    toplevel=$(nix build .#nixosConfigurations.''${config}.config.system.build.toplevel --no-link --print-out-paths)
  fi
  kernel=$(readlink -f "$toplevel"/kernel)
  initrd=$(readlink -f "$toplevel"/initrd)
  dtb=$(readlink -f "$toplevel"/dtbs/rockchip/pn.dtb)

  kernel_size=$(stat -c%s "$kernel")
  initrd_size=$(stat -c%s "$initrd")
  dtb_size=$(stat -c%s "$dtb")

  align=$((1024 * 1024))
  initrd_offset=$(((kernel_size + align - 1) / align * align))
  dtb_offset=$(((initrd_offset + initrd_size + align - 1) / align * align))

  test -f boot.bin && rm boot.bin
  dd if="$kernel" of=boot.bin bs=1M
  dd if="$initrd" of=boot.bin bs=1M seek=$((initrd_offset / align)) conv=notrunc
  dd if="$dtb" of=boot.bin bs=1M seek=$((dtb_offset / align)) conv=notrunc

  echo ""
  echo "Plug in serial dongle, and access U-Boot console"
  echo "Paste into U-Boot: (picocom /dev/ttyUSB0 -b 1500000 -l)"
  echo "fastboot usb 0"
  echo "Plug in the normal USB cable for fastboot"
  fastboot stage boot.bin
  echo "Plug in serial dongle"
  echo "In U-Boot: Ctrl-C"

  if [[ -n "$nixos_img" ]]; then
    tmp=$(mktemp -d)
    sudo mount "$nixos_img" -o loop,ro,offset=1048576 "$tmp"
    append=$(grep -e APPEND "$tmp"/boot/extlinux/extlinux.conf | head -n1 | sed 's/.*APPEND //' || true)
    sudo umount "$tmp"
    rmdir "$tmp"
    [[ -z "$append" ]] && echo "failed to find append from image's extlinux.conf" && exit 1
  else
    append="init=$toplevel/init $(cat "$toplevel"/kernel-params)"
  fi
  echo "Paste into U-Boot:"
  echo "setenv bootargs \"''${append}\""

  hex() { printf '0x%x' "$1"; }
  base_r=0x00c00800 # fastboot stage address
  kernel_r=$base_r
  initrd_r=$(hex $((base_r + initrd_offset)))
  dtb_r=$(hex $((base_r + dtb_offset)))
  dtb_resize=0x1000
  initrd_copy_r=$(hex $((dtb_r + dtb_size + dtb_resize)))
  echo "Paste into U-Boot:"
  echo "cp.b ''${initrd_r} ''${initrd_copy_r} $(hex "$initrd_size"); fdt addr ''${dtb_r}; fdt resize ''${dtb_resize}; fdt chosen ''${initrd_copy_r} $(hex $((initrd_copy_r + initrd_size))); booti ''${kernel_r} ''${initrd_copy_r}:$(hex "$initrd_size") ''${dtb_r}"
  if [[ -z "$netboot" ]]; then
    echo "Plug in usb stick with nixos image flashed onto it into the PineNote"
  else
    echo "Preparing nbdkit"
    if [[ -z "$squashfs_img" ]]; then
      squashfs_img=$(nix build .#nixosConfigurations.''${config}.config.system.build.squashfsStore --no-link --print-out-paths)
    fi
    nbdkit -r file "$squashfs_img" -p 10809 -f &
    nbdkit_pid=$!
    trap 'kill -9 "$nbdkit_pid" 2>/dev/null' EXIT
    echo "nbdkit ready, plug in the normal USB cable, Ctrl-C to stop nbdkit"
    wait
  fi
''
