# tnCartWonder

This is a fork of the [tnCart](https://github.com/buppu3/tnCart) project by [Shinobu Hashimoto](https://github.com/buppu3) to make the RTL compatible with the [WonderTANG](https://github.com/lfantoniosi/WonderTANG) by [Luis Felipe Antoniosi](https://github.com/lfantoniosi).

See the [original README](https://github.com/buppu3/tnCart/blob/main/README.md) for more information.


# What is different between tnCart and tnCartWonder

There are really not many differences between tnCart and tnCartWonder. tnCartWonder inherits basically all from tnCart except some minor adaptions needed for compatibility with the WonderTANG! boards.

For WonderTANG! V1.01c, these are the differences:
- Adjust a constant to account for the difference between the MSEL0 and MSEL1 lines of the tnCart rev1 board vs the WonderTANG! V1.01c board
- Invert the INT_n signal (in the WonderTANG! V1.01c the INT_n signal logic is direct, in tnCart rev1 board the INT_n signal logic is inverted)

For WonderTANG! V1.02d, these are the differences:
- Adjust a constant to account for the difference between the MSEL0 and MSEL1 lines of the tnCart rev1 board vs the WonderTANG! V1.01c board

For WonderTANG! V2.0b, these are the differences:
- Adjust a constant to account for the difference between the MSEL0 and MSEL1 lines of the tnCart rev1 board vs the WonderTANG! V1.01c board
- Adjust the pin mapping of the tnCart rev1 board (which uses the mapping of the WonderTANG V1.01c and V1.02d board) to that of the WonderTANG! V2.0b board
- Add code to "send" the external sound samples (which in the tnCart are processed by a synthesized 1-bit DAC) to a synthesized I2S transmitter that sends audio samples to the [MAX98357A](https://www.analog.com/media/en/technical-documentation/data-sheets/max98357a-max98357b.pdf) of the [Tang Nano 20k](https://wiki.sipeed.com/hardware/en/tang/tang-nano-20k/nano-20k.html) (whose output the WonderTANG! V2.0b board sends to both the jack audio and the SOUNDIN pin of the MSX cartridge).

That's it.


# Build and Flashing instructions

## WonderTANG 1.01c

### How to build the bitstream on Linux

- Copy the `rtl/impl/wondertang_board_rev101c_process_config.json` to `rtl/impl/project_process_config.json`.

  `$ cp rtl/impl/wondertang_board_rev101c_process_config.json rtl/impl/project_process_config.json`

- Launch GoWin IDE (GOWIN FPGA Designer Version 1.9.9 Beta-4 Education build68283)

  `$ gw_ide`

- Load the `rtl/wondertang_board_rev101c.gprj` (File | Open ...)

- Edit the `rtl/src/config.v` file and make sure the BOARD parameter points to the WonderTANG! V1.01c board:

  `localparam BOARD                    = BOARD_WONDERTANG_REV101C;`

  Enable and/or disable the tnCart features that you want to build.

- Go to the Process window, right click on "Synthesize" and select "Clean&Rerun All"

### How to flash the bitstream and required additional ROMs on Linux

You will need to use openFPGALoader >= v0.10.0.

- First, flash the bitstream `wondertang_board_rev101c.fs` into the Tang Nano 20k used in your WonderTANG board

  `$ openFPGALoader -f -b tangnano20k --external-flash rtl/impl/pnr/wondertang_board_rev101c.fs`

- Second, flash the [Nextor ROM](https://github.com/Konamiman/Nextor/releases/download/v2.1.2/Nextor-2.1.2.MegaFlashSDSCC.1-slot.ROM)

  `$ openFPGALoader -f -b tangnano20k --external-flash -o 1048576 Nextor-2.1.2.MegaFlashSDSCC.1-slot.ROM`

- Finally, flash the [FM ROM](https://github.com/buppu3/tnCart/blob/main/roms/fmbios/bin/fmbios.rom)

  `$ openFPGALoader -f -b tangnano20k --external-flash -o 1179648 fmbios.rom`

## WonderTANG 1.02d

### How to build the bitstream on Linux

- Copy the `rtl/impl/wondertang_board_rev102d_process_config.json` to `rtl/impl/project_process_config.json`.

  `$ cp rtl/impl/wondertang_board_rev102d_process_config.json rtl/impl/project_process_config.json`

- Launch GoWin IDE (GOWIN FPGA Designer Version 1.9.9 Beta-4 Education build68283)

  `$ gw_ide`

- Load the `rtl/wondertang_board_rev102d.gprj` (File | Open ...)

- Edit the `rtl/src/config.v` file and make sure the BOARD parameter points to the WonderTANG! V1.02d board:

  `localparam BOARD                    = BOARD_WONDERTANG_REV102D;`

  Enable and/or disable the tnCart features that you want to build.

- Go to the Process window, right click on "Synthesize" and select "Clean&Rerun All"

### How to flash the bitstream and required additional ROMs on Linux

You will need to use openFPGALoader >= v0.10.0.

- First, flash the bitstream `wondertang_board_rev102d.fs` into the Tang Nano 20k used in your WonderTANG board

  `$ openFPGALoader -f -b tangnano20k --external-flash rtl/impl/pnr/wondertang_board_rev102d.fs`

- Second, flash the [Nextor ROM](https://github.com/Konamiman/Nextor/releases/download/v2.1.2/Nextor-2.1.2.MegaFlashSDSCC.1-slot.ROM)

  `$ openFPGALoader -f -b tangnano20k --external-flash -o 1048576 Nextor-2.1.2.MegaFlashSDSCC.1-slot.ROM`

- Finally, flash the [FM ROM](https://github.com/buppu3/tnCart/blob/main/roms/fmbios/bin/fmbios.rom)

  `$ openFPGALoader -f -b tangnano20k --external-flash -o 1179648 fmbios.rom`

## WonderTANG 2.0b

### How to build the bitstream on Linux

- Copy the `rtl/impl/wondertang_board_rev200b_process_config.json` to `rtl/impl/project_process_config.json`.

  `$ cp rtl/impl/wondertang_board_rev200b_process_config.json rtl/impl/project_process_config.json`

- Launch GoWin IDE (GOWIN FPGA Designer Version 1.9.9 Beta-4 Education build68283)

  `$ gw_ide`

- Load the `rtl/wondertang_board_rev200b.gprj` (File | Open ...)

- Edit the `rtl/src/config.v` file and make sure the BOARD parameter points to the WonderTANG! V2.0b board:

  `localparam BOARD                    = BOARD_WONDERTANG_REV200B;`

  Enable and/or disable the tnCart features that you want to build.

- Go to the Process window, right click on "Synthesize" and select "Clean&Rerun All"

### How to flash the bitstream and required additional ROMs on Linux

You will need to use openFPGALoader >= v0.10.0.

- First, flash the bitstream `wondertang_board_rev200b.fs` into the Tang Nano 20k used in your WonderTANG board

 `$ openFPGALoader -f -b tangnano20k --external-flash rtl/impl/pnr/wondertang_board_rev200b.fs`

- Second, flash the [Nextor ROM](https://github.com/Konamiman/Nextor/releases/download/v2.1.2/Nextor-2.1.2.MegaFlashSDSCC.1-slot.ROM)

 `$ openFPGALoader -f -b tangnano20k --external-flash -o 1048576 Nextor-2.1.2.MegaFlashSDSCC.1-slot.ROM`

- Finally, flash the [FM ROM](https://github.com/buppu3/tnCart/blob/main/roms/fmbios/bin/fmbios.rom)

 `$ openFPGALoader -f -b tangnano20k --external-flash -o 1179648 fmbios.rom`


# Other Useful Information

## How to load a Konami SCC ROM with tncrom

You can use the [TNCROM.COM](https://github.com/buppu3/tnCart/blob/main/tools/tncrom/bin/TNCROM.COM) tool to load ROMs into the WonderTANG MegaFlashROM when flashed with the tnCart RTL.

`A:> TNCROM.COM /T KONAMI /R YOUR.ROM`

With the above invocation the ROM gets loaded, and the `/R` parameter causes an immediate system reset to launch the ROM.

The `/R` parameter is useful to force a reset on those MSX machines lacking a reset button.
If your MSX has a reset button, you may omit the `/R` parameter and use the reset button when you want to launch the loaded ROM.

## How to activate the SCC with tncrom

You can use the [TNCROM.COM](https://github.com/buppu3/tnCart/blob/main/tools/tncrom/bin/TNCROM.COM) tool to activate the SCC before launching software that uses it.

`A:> TNCROM.COM /T KONAMI_SCC_I /N`

With the above invocation the SCC_I is activated and control is returned to DOS.


# Known Issues

- [tnCart #14](https://github.com/buppu3/tnCart/issues/14)

- ~~The WS2812 RGB LED of the Tang Nano 20K seems to cause interferences on the WonderTANG! when lit, which may cause the MSX computer to hang or reboot.~~

  The RGB LED cannot be completely disabled reliably because the DIN signal of the led is mapped to IO_LOC 79 on the Tang Nano 20K which is used on the WonderTANG! by CART_DATA_SIG[3],
  so depending on the sequence of data present in the data bus the led may change state.

  ~~Two workarounds have~~ ~~A workaround been added to try to mitigate the problem:~~
  - switch on the RGB LED to red color on poweron ~~(to reduce the noise when it goes from off to on, which affects specially the MSX boot sequence)~~
  - ~~sample CART_DATA_SIG[3] an extra cycle to compensate for noise~~

- ~~SofaRun does not properly detect the SCC~~ [Fixed](https://github.com/buppu3/tnCart/issues/11).

- ~~MGSP does not properly detect the SCC~~ [Fixed](https://github.com/buppu3/tnCart/issues/11).

- ~~Some games like F1SPIRIT experience problems (sprites get mad) when loaded with TNCROM, but work fine when loaded with SofaRun~~ [Fixed](https://github.com/buppu3/tnCart/issues/12).
