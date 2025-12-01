# NixOS Module and Packages for PineNote
This repository provides all that should be needed to get NixOS working on PineNote.
It is largely based on [pinenote-dist](https://git.sr.ht/~hrdl/pinenote-dist/) by hrdl.

## Preparations
Setup the partition that NixOS will be installed on. For my personal configuration I needed about 15GB so I decided to remove the original 10GB os2, and combined it with data partition. For that I backed up my files from data, combined the partitions with `sudo cfdisk /dev/mmcblk0`, extended the ext4 fs with `sudo resize2fs /dev/mmcblk0p9`.

Whats most important is that you label the partition you will be installing to as nixos with `sudo e2label /dev/mmcblk0p9 nixos`.

## Image
To create a disk image on existing NixOS system:

1. (optional) If you don't have the UART dongle then first add your home network to the `./configuration.nix` file with [networking.networkmanager.ensureProfiles.profiles](https://search.nixos.org/options?show=networking.networkmanager.ensureProfiles.profiles)
2. Add `aarch64-linux` to [boot.binfmt.emulatedSystems](https://nixos.org/manual/nixos/unstable/options#opt-boot.binfmt.emulatedSystems). Rebuild your system to apply.
3. Run `nix build .#disk-image-cross`

`disk-image-cross` cross-compiles the kernel, so the compilation doesn't go through qemu.
Full build took on my machine around 40 minutes, most of that being building the kernel.

## Booting
1. On PineNote mount your os2 partition on /mnt/ and ensure it is labeled as nixos (blkid should report the partition with LABEL="nixos", PARTLABEL can be different)
2. On desktop system mount the image from previous section `sudo mount -o loop,offset=1048576 result/nixos.img /mnt/img/`
3. Rsync the files over to PineNote with `sudo rsync -aHAXx --numeric-ids --progress /mnt/img/ root@<pinenote>:/mnt/` (for root access either enable root password login by changing `#PermitRootLogin prohibit-password` to `PermitRootLogin yes` in `/etc/ssh/sshd_config` on PineNote, or by providing your ssh pub key to `/root/.ssh/authorized_keys` on the PineNote)

You should now be able to reboot to NixOS by selecting os2 in uboot menu and access it thought UART or ssh (password for `user` is `password`). Screen will be off as the driver doesn't have the waveform files yet, for that you need to run `sudo setup-waveform.sh` on the PineNote after booting.

Assuming everything went fine, you should be able to switch to your own configuration. If you are using flakes, add this repo to your inputs, include `pinenote-nixos.nixosModules.default` in your modules, and enable it with `pinenote.config.enable = true;`. For a functioning configuration you can checkout my [nixos-config](https://github.com/werapea/nixos-config).

## Tips
Switching system derivations on PineNote can be slow, but you can offload all the work to your desktop machine by using `sudo NIX_SSHOPTS="-i /root/.ssh/remotebuildhost" nixos-rebuild test --flake ~/nixos-config#pinenote --target-host root@<pinenote>` on desktop, provided that you setup the remotebuildhost ssh key and add it to your PineNote's `/root/.ssh/authorized_keys`. Or more simply if you use `nh`: `nh os switch -H pinenote ~/nixos-config --target-host <pinenote id or hostname> -k` and optionally add `-o pinenote-$(date -Is)` to store the result, so it doesn't get garbage collected on the desktop. `nh` way does not require setting up root ssh authorization.
