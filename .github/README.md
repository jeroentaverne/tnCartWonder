# tnCartWonder

This is a fork of the [tnCart](https://github.com/buppu3/tnCart) project by [Shinobu Hashimoto](https://github.com/buppu3) to make the RTL compatible with the [WonderTANG](https://github.com/lfantoniosi/WonderTANG) by [Luis Felipe Antoniosi](https://github.com/lfantoniosi).

See the [original README](https://github.com/buppu3/tnCart/blob/main/README.md) for more information.

# WonderTANG 1.02d

## How to build the bitstream on Linux

- Copy the `rtl/impl/wondertang_board_rev102d_process_config.json` to `rtl/impl/project_process_config.json`.

  `$ cp rtl/impl/wondertang_board_rev102d_process_config.json rtl/impl/project_process_config.json`

- Launch GoWin IDE (GOWIN FPGA Designer Version 1.9.9 Beta-4 Education build68283)

  `$ gw_ide`

- Load the `rtl/wondertang_board_rev102d.gprj` (File | Open ...)

- Edit the `rtl/src/config.v` file and make sure the BOARD parameter points to the WonderTANG! V1.02d board:

  `localparam BOARD                    = BOARD_WONDERTANG_REV102D;`

  Enable and/or disable the tnCart features that you want to build.

- Go to the Process window, right click on "Synthesize" and select "Clean&Rerun All"

## How to flash the bitstream and required additional ROMs on Linux

You will need to use openFPGALoader >= v0.10.0.

- First, flash the bitstream `wondertang_board_rev102d.fs` into the Tang Nano 20k used in your WonderTANG board

  `$ openFPGALoader -f -b tangnano20k --external-flash rtl/impl/pnr/wondertang_board_rev102d.fs`

- Second, flash the [Nextor ROM](https://github.com/Konamiman/Nextor/releases/download/v2.1.2/Nextor-2.1.2.MegaFlashSDSCC.1-slot.ROM)

  `$ openFPGALoader -f -b tangnano20k --external-flash -o 1048576 Nextor-2.1.2.MegaFlashSDSCC.1-slot.ROM`

- Finally, flash the [FM ROM](https://github.com/buppu3/tnCart/blob/main/roms/fmbios/bin/fmbios.rom)

  `$ openFPGALoader -f -b tangnano20k --external-flash -o 1179648 fmbios.rom`

# WonderTANG 2.0b

## How to build the bitstream on Linux

- Copy the `rtl/impl/wondertang_board_rev200b_process_config.json` to `rtl/impl/project_process_config.json`.

  `$ cp rtl/impl/wondertang_board_rev200b_process_config.json rtl/impl/project_process_config.json`

- Launch GoWin IDE (GOWIN FPGA Designer Version 1.9.9 Beta-4 Education build68283)

  `$ gw_ide`

- Load the `rtl/wondertang_board_rev200b.gprj` (File | Open ...)

- Edit the `rtl/src/config.v` file and make sure the BOARD parameter points to the WonderTANG! V2.0b board:

  `localparam BOARD                    = BOARD_WONDERTANG_REV200B;`

  Enable and/or disable the tnCart features that you want to build.

- Go to the Process window, right click on "Synthesize" and select "Clean&Rerun All"

## How to flash the bitstream and required additional ROMs on Linux

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
