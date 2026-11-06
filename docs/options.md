## pinenote\.config\.enable

Whether to enable pinenote specific nixos configs\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/default\.nix](https://github.com/WeraPea/pinenote-nixos/blob/main/modules/default.nix)



## pinenote\.netboot\.enable



Whether to enable booting over usb using netboot\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/netboot\.nix](https://github.com/WeraPea/pinenote-nixos/blob/main/modules/netboot.nix)



## pinenote\.netboot\.squashfsPkgs



nixpkgs instance used for building the squashfsStore image,
as opposed to the instance used for the store paths in it\.



*Type:*
Nixpkgs package set



*Default:*

```nix
pkgs
```



*Example:*

```nix
import nixpkgs { system = "x86_64-linux"; }
```

*Declared by:*
 - [modules/netboot\.nix](https://github.com/WeraPea/pinenote-nixos/blob/main/modules/netboot.nix)



## pinenote\.netboot\.storeContents



This option lists additional derivations to be included in the
Nix store in the generated netboot image\.



*Type:*
list of path in the Nix store



*Default:*

```nix
[ ]
```



*Example:*

```nix
[ pkgs.stdenv ]
```

*Declared by:*
 - [modules/netboot\.nix](https://github.com/WeraPea/pinenote-nixos/blob/main/modules/netboot.nix)



## pinenote\.pinenote-service\.enable



Whether to enable pinenote-service\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/default\.nix](https://github.com/WeraPea/pinenote-nixos/blob/main/modules/default.nix)



## pinenote\.pinenote-service\.package



The pinenote-service package to use\.



*Type:*
package



*Default:*

```nix
pkgs.pinenote-service
```

*Declared by:*
 - [modules/default\.nix](https://github.com/WeraPea/pinenote-nixos/blob/main/modules/default.nix)



## pinenote\.sway-dbus-integration\.enable



Whether to enable sway-dbus-integration service\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/default\.nix](https://github.com/WeraPea/pinenote-nixos/blob/main/modules/default.nix)



## pinenote\.usb-boot\.enable



Whether to enable booting from usb (see usb-helper)\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/default\.nix](https://github.com/WeraPea/pinenote-nixos/blob/main/modules/default.nix)


