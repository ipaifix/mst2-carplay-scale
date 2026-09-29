# MST2 CarPlay Display Scale

**English** | [Français](README.fr.md)

An experimental, standalone, and reversible patch that adjusts the display parameters reported by a TechniSat/Preh MIB2 Standard unit to Apple CarPlay.

> **Current status: validated in a vehicle running MST2_EU_VW_ZR_P0468T.** The 100/110/115/120/125% modes, touch input, and one-shot Trial Boot have been tested. Permanent loading is implemented and host-tested, but has not yet been validated in the vehicle. Other firmware trains are not currently supported.

## Compatibility

- unit: TechniSat/Preh MIB2 Standard (MST2);
- validated firmware: `MST2_EU_VW_ZR_P0468T`;
- observed logical resolution: 800 × 480;
- observed stock physical dimensions: 174 × 104 mm;
- console-free installation: MIB STD2 Toolbox and Green Engineering Menu.

**Do not install the P0468 JAR on another firmware version.** The shadowed Java class must exactly match the firmware ABI. An incompatible class may prevent the HMI from starting.

## Safety design

- does not modify `MIBHMI.jxe`, the skin, or the framebuffer;
- keeps xPaiiN's `mst2-carplay-vc` patch independent and untouched;
- installation enables only a one-shot **Trial Boot**;
- permanent loading requires a separate explicit action;
- an SD card containing `carplayscale-disable` prevents loading before Java starts;
- uninstallation removes only the managed `mst2-carplay-scale` block and JAR;
- every `runHMI.sh` change is prepared, validated, and replaced atomically.

## Repository layout

```text
analysis/                    phase A safety analysis
method2-console/             console installation infrastructure
tests/                       fixtures and host-side tests
method1-GEM/                 MIB STD2 Toolbox package and menu
src/                         P0468 shadow, logging, and physical scaling
scripts/                     reproducible Java JAR build
build/                       untracked build outputs
```

## Validation status

- [x] A — upstream analysis and xPaiiN class inventory
- [x] B — Trial/Permanent/Disable/Emergency/Uninstall scripts and shell tests
- [x] C — neutral 100% behavior validated in the vehicle
- [x] D — `ServiceConfiguration` logging validated in the vehicle
- [x] E — 100/110/115/120/125% physical scaling and touch input validated in the vehicle
- [x] F — Green Engineering Menu validated in the vehicle; permanent mode host-tested

## Quick Toolbox installation

This repository contains no Volkswagen firmware and no JAR extracted from a vehicle. First build the patch JAR with P0468 dependencies obtained from your own unit:

```sh
JAVA_HOME=/path/to/jdk8 \
MIBHMI_JAR=/path/to/MIBHMI-P0468.jar \
MIBSTD2_BASE_JAR=/path/to/tsd-mibstd2-hmi-v2-P0468.jar \
sh scripts/build-neutral-jar.sh
```

The SD-card payload is generated in `method1-GEM/custom`, and an archive is written to `build/mst2-carplay-scale-toolbox-p0468.zip`. Then follow the [Toolbox procedure](method1-GEM/README.md), always starting with a one-shot trial at 100%.

## Local tests

```sh
sh tests/run-shell-tests.sh
```

These tests do not use the vehicle. They simulate `/tsd`, both SD-card mount points, several `runHMI.sh` variants, Trial Boot behavior, and validation failures.

The Java test requires JDK 8 and the two analysis JARs produced locally from the P0468 dump:

```sh
JAVA_HOME=/path/to/jdk8 \
MIBHMI_JAR=/path/to/MIBHMI-P0468.jar \
MIBSTD2_BASE_JAR=/path/to/tsd-mibstd2-hmi-v2-P0468.jar \
sh tests/run-java-tests.sh
```

It verifies that the public API matches the stock class, all three constructors are preserved, stock dimensions remain unchanged, the bytecode targets J2SE 1.4, and the JAR contains only the expected classes.

## Recovery / boot loops

### Level 1 — Trial Boot

The `/tsd/var/carplayscale/trial` marker is removed **before** the JAR is added to the boot class path. After a trial, the following reboot no longer loads the patch.

### Level 2 — emergency SD card

Create an empty file named:

```text
carplayscale-disable
```

Place it at the root of an SD card, insert the card, and reboot. The shell block checks `/media/mp00*` before Java starts and skips the JAR even when permanent mode is enabled.

### Level 3 — Telnet

```sh
rm -f /tsd/var/carplayscale/enabled /tsd/var/carplayscale/trial
```

This does not modify `mst2-carplay-vc.jar` or any of its state files.

### Level 4 — manual repair

The dedicated backup is:

```text
/tsd/hmi/runHMI.sh.carplayscale.bak
```

It captures the live `runHMI.sh` at the time of the first installation and therefore preserves previously installed patches. Normal uninstallation always prefers removing only the managed `mst2-carplay-scale` block from the current file.

## Important

Every new unit must start at 100% using Trial Boot only. Do not enable permanent loading or select a higher scale until the HMI reboot, CarPlay, touch input, and stock log values have all been confirmed. For console-free installation, see [method1-GEM/README.md](method1-GEM/README.md).

This project is not affiliated with Volkswagen or Apple. Modifying an embedded head unit is entirely at the user's own risk.

## References and acknowledgements

- [xPaiiN/mst2-carplay-vc](https://github.com/xPaiiN/mst2-carplay-vc) — the project that inspired the independent Toolbox integration and provided the coexistence target used throughout development. `mst2-carplay-scale` does not modify or bundle the xPaiiN patch.
- [olli991/mib-std2-pq-zr-toolbox](https://github.com/olli991/mib-std2-pq-zr-toolbox) — MIB STD2 Toolbox and Green Engineering Menu integration model.
- [Eclipse OpenJ9 boot class path documentation](https://eclipse.dev/openj9/docs/xbootclasspath/) — reference for the Java class-prepending mechanism.

## License

Project-owned code is released under the MIT License. See [LICENSE](LICENSE).
