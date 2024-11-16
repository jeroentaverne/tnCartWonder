//
// tnCart_board_rev1_top.sv
//
// BSD 3-Clause License
// 
// Copyright (c) 2024, Shinobu Hashimoto
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
// 
// 3. Neither the name of the copyright holder nor the names of its
//    contributors may be used to endorse or promote products derived from
//    this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

`default_nettype none

module TNCART_BOARD_REV1_TOP (
    input   wire            CLK_27M,

    // JUMPER
    input   wire            JUMPER,

    // SDRAM
    output  wire            O_sdram_clk,
    output  wire            O_sdram_cke,
    output  wire            O_sdram_cs_n,
    output  wire            O_sdram_cas_n,
    output  wire            O_sdram_ras_n,
    output  wire            O_sdram_wen_n,
    inout   wire    [31:0]  IO_sdram_dq,
    output  wire    [10:0]  O_sdram_addr,
    output  wire    [1:0]   O_sdram_ba,
    output  wire    [3:0]   O_sdram_dqm,

    // BUS
    output  wire            CART_BUSDIR_n,
    output  wire            CART_INT_n,
    output  wire            CART_WAIT_n,
    input   wire            CART_SLTSL_n,
    input   wire            CART_RD_n,
    input   wire            CART_WR_n,
    input   wire            CART_CLOCK,
    input   wire    [7:0]   CART_MUX_SIG,
    output  wire    [2:0]   CART_MUX_CS_n,
    inout   wire    [7:0]   CART_DATA_SIG,
    output  wire            CART_DATA_DIR,

    // SOUND
    output  wire            SOUND_INT,
    output  wire            SOUND_EXT,

    // LED
    output  wire            LED,

    // TMDS
    output wire             tmds_clk_p,
    output wire             tmds_clk_n,
    output wire    [2:0]    tmds_data_p,
    output wire    [2:0]    tmds_data_n,

    // SPI FLASH
    output  wire            mspi_cs,
    output  wire            mspi_sclk,
    input   wire            mspi_miso,
    output  wire            mspi_mosi,
    output  wire            mspi_hold,

    // TF
    output  wire            TF_SCLK,    // SCLK
    output  wire            TF_CMD,     // MOSI
    input   wire            TF_DAT0,    // MISO
    inout   wire            TF_DAT1,    // NC
    inout   wire            TF_DAT2,    // NC
    inout   wire            TF_DAT3,    // CS_n

    // UART
    input   wire            UART_RX,
    output  wire            UART_TX
);

    // UMA を有効
    localparam          ENABLE_UMA              = 1;//CONFIG::ENABLE_V9990;

    /***************************************************************
     * CLOCK
     ***************************************************************/
    logic CLK_BASE/* synthesis syn_keep=1 */;
    logic CLK_BASE_READY;
    logic CLK_MEM;
    logic CLK_MEM_P;
    logic CLK_MEM_READY;
    logic CLK_TMDS_S/* synthesis syn_keep=1 */;
    logic CLK_TMDS_P/* synthesis syn_keep=1 */;
    logic CLK_TMDS_READY;
    logic CLK_21M/* synthesis syn_keep=1 */;
    BOARD_REV1_CLOCK u_clk (
        .RESET_n        (1'b1),
        .CLK_IN         (CONFIG_BOARD::SYNC_CPU_CLK ? CART_CLOCK : CLK_27M),
        .CLK_BASE,
        .CLK_BASE_READY,
        .CLK_MEM,
        .CLK_MEM_P,
        .CLK_MEM_READY,
        .CLK_TMDS_S,
        .CLK_TMDS_P,
        .CLK_TMDS_READY,
        .CLK_21M
    );

    /***************************************************************
     * UART
     ***************************************************************/
    if(CONFIG_BOARD::ENABLE_UART_MODULE) begin
        UART_RX_IF RXD();
        UART_RX #(
            .CLKFREQ            (108_000_000)
        ) u_rxd (
            .RESET_n,
            .CLK,
            .RXD                (UART_RX),
            .Uart_rx_interface  (RXD)
        );

        UART_TX_IF TXD();
        UART_TX #(
            .CLKFREQ            (108_000_000)
        ) u_txd (
            .RESET_n,
            .CLK,
            .TXD                (UART_TX),
            .Uart_tx_interface  (TXD)
        );

        assign RXD.READ = 0;
        assign RXD.CLEAR = 0;
        assign TXD.DATA = 0;
        assign TXD.STROBE = 0;
    end
    else begin
        assign UART_TX = 1;
    end

    /***************************************************************
     * MSX バス
     ***************************************************************/
    wire RESET_n;
    wire CLK = CLK_BASE;
    BUS_IF Bus();

    // リセット信号処理
    reg reset_n = 0;
    assign RESET_n = reset_n;
    always_ff @(posedge CLK_BASE or negedge CLK_BASE_READY or negedge sdram_ready) begin
        if(!CLK_BASE_READY) reset_n <= 0;       // PLL 準備中ならリセット
        else if(!sdram_ready) reset_n <= 0;     // SDRAM 準備中ならリセット
        else reset_n <= 1; 
    end

    // バス信号処理
    BOARD_REV1_BUS u_bus (
        .RESET_n,
        .CLK,
        .CLK_21M,
        .CART_BUSDIR_n,
        .CART_INT_n,
        .CART_WAIT_n,
        .CART_SLTSL_n,
        .CART_RD_n,
        .CART_WR_n,
        .CART_CLOCK,
        .CART_MUX_SIG,
        .CART_MUX_CS_n,
        .CART_DATA_SIG,
        .CART_DATA_DIR,
        .Bus
    );

    /***************************************************************
     * SDRAM
     ***************************************************************/
    RAM_IF Ram();
    logic sdram_ready;
    SDRAM #(
        .SDRAM_A_WIDTH      (11),
        .SDRAM_BA_WIDTH     (2),
        .SDRAM_COL_WIDTH    (8),
        .SDRAM_ROW_WIDTH    (11),
        .SDRAM_DQ_WIDTH     (32)
    ) u_sdram (
        .CLK                (CLK_MEM),
        .CLK_PS             (CLK_MEM_P),
        .RESET_n            (CLK_MEM_READY),

        .READY              (sdram_ready),

        .SDRAM_CLK          (O_sdram_clk),
        .SDRAM_CKE          (O_sdram_cke),
        .SDRAM_CS_n         (O_sdram_cs_n),
        .SDRAM_RAS_n        (O_sdram_ras_n),
        .SDRAM_CAS_n        (O_sdram_cas_n),
        .SDRAM_WE_n         (O_sdram_wen_n),
        .SDRAM_A            (O_sdram_addr),
        .SDRAM_BA           (O_sdram_ba),
        .SDRAM_DQM          (O_sdram_dqm),
        .SDRAM_DQ           (IO_sdram_dq),

        .Ram
    );

    /***************************************************************
     * RAM wait 制御
     ***************************************************************/
    wire uma_wait;
    if(CONFIG::CONTROL_BUS_WAIT_RAM == 0) begin
        // WAIT 制御を行わない
        assign uma_wait = 0;
    end
    else if(CONFIG::CONTROL_BUS_WAIT_RAM == 1) begin
        // クロックが速い時だけ WAIT 制御を行う
        CLK_SPEED u_clk_speed (
            .RESET_n,
            .CLK,
            .CLK_3_58M(Bus.CLK),
            .CLK_3_58M_EN(Bus.CLK_EN),
            .FAST(uma_wait)
        );
    end
    else begin
        // WAIT 制御を常に行う
        assign uma_wait = 1;
    end

    /***************************************************************
     * UMA
     ***************************************************************/
    UMA_IF Uma();
    assign Uma.ADDR[0] = 0;                         // Uma[0] の SDRAM 先頭アドレス
    assign Uma.ADDR[1] = CONFIG::RAM_ADDR_VRAM;     // Uma[1] の SDRAM 先頭アドレス

    RAM_IF UmaRam[0:Uma.COUNT-1]();

    if(ENABLE_UMA) begin
        UMA #(
            .COUNT      (Uma.COUNT),
            .SYNC_CLK_EN(CONFIG_BOARD::SYNC_CPU_UMA),
            .DIV        (30)                        // 108MHz/3.58MHz = 30
        ) u_uma (
            .RESET_n,
            .CLK,
            .CLK_EN     (Bus.CLK_EN),
            .WAIT_EN    (uma_wait),
            .Primary    (Ram),
            .Secondary  (UmaRam),
            .Uma
        );
    end
    else begin
        // UMA を使わない時
        BYPASS_RAM u_bypass_uma (
            .Primary    (Ram),
            .Secondary  (UmaRam[0])
        );
        assign UmaRam[1].DOUT = 0;
        assign UmaRam[1].ACK_n = 1;
        assign UmaRam[1].TIMING = 0;
        assign Uma.CLK14M_EN = 0;
        assign Uma.CLK21M_EN = 0;
        assign Uma.CLK25M_EN = 0;
    end

    /***************************************************************
     * TF
     ***************************************************************/
    SPI_IF TF();
    SPI #(
        .CLK_DIV        (CONFIG_BOARD::TF_CLK_DIV)
    ) u_tf_spi (
        .CLK,
        .RESET_n,
        .SCLK           (TF_SCLK),
        .MOSI           (TF_CMD),
        .MISO           (TF_DAT0),
        .CS_n           (TF_DAT3),
        .SPI_Interface  (TF)
    );

    // 未使用ピンの処理
    assign TF_DAT1 = 1'bZ;
    assign TF_DAT2 = 1'bZ;

    /***************************************************************
     * FLASH
     ***************************************************************/
    FLASH_IF Flash();
    FLASH_SPI u_flash (
        .RESET_n,
        .CLK,
        .SPI                (Flash_SPI),
        .Flash              (Flash)
    );

    SPI_IF #(
        .MOSI_BIT_WIDTH(Flash.ADDR_WIDTH+8)
    ) Flash_SPI();
    SPI #(
        .CLK_DIV            (CONFIG_BOARD::FLASH_CLK_DIV)
    ) u_flash_spi (
        .RESET_n,
        .CLK,
        .SCLK               (mspi_sclk),
        .MOSI               (mspi_mosi),
        .MISO               (mspi_miso),
        .CS_n               (mspi_cs),
        .SPI_Interface      (Flash_SPI)
    );

    // 未使用ピンの処理
    assign mspi_hold = 1;

    /***************************************************************
     * LED
     ***************************************************************/
    LED_IF LedNextor();
    LED_IF LedBoot();
    LED #(
        .DELAY          (108_000_000 / 2),
        .BLINK          (108_000_000 / 20)
    ) u_led (
        .CLK,
        .RESET_n,
        .LedPort        (LED),
        .LedNextor,
        .LedBoot
    );

    /***************************************************************
     * DAC clock(108MHz/5 = 21.6MHz)
     ***************************************************************/
    localparam CLK_DAC_DIV = CONFIG_BOARD::DAC_FREQ_DIV;

    logic [$clog2(CLK_DAC_DIV)-1:0] clk_dac_cnt;
    wire CLK_DAC_EN = (clk_dac_cnt == 0);

    always_ff @(posedge CLK or negedge RESET_n) begin
        if(!RESET_n)              clk_dac_cnt <= CLK_DAC_DIV - 1'd1;
        else if(clk_dac_cnt == 0) clk_dac_cnt <= CLK_DAC_DIV - 1'd1;
        else                      clk_dac_cnt <= clk_dac_cnt - 1'd1;
    end

    /***************************************************************
     * cartridge sound out
     ***************************************************************/
    SOUND_IF #(.BIT_WIDTH(CONFIG_BOARD::DAC_BIT_WIDTH)) SoundInternal();
    DAC_1BIT u_dac_int (
        .CLK,
        .CLK_EN         (CLK_DAC_EN),
        .RESET_n,
        .IN             (SoundInternal),
        .OUT            (SOUND_INT)
    );

    /***************************************************************
     * external sound out
     ***************************************************************/
    SOUND_IF #(.BIT_WIDTH(CONFIG_BOARD::DAC_BIT_WIDTH)) SoundExternal[0:0]();
    DAC_1BIT u_dac_ext (
        .CLK,
        .CLK_EN         (CLK_DAC_EN),
        .RESET_n,
        .IN             (SoundExternal[0]),
        .OUT            (SOUND_EXT)
    );

    /***************************************************************
     * VIDEO
     ***************************************************************/
    VIDEO_IF Video();
    VIDEO_IF VideoTmds();
    VIDEO_UPSCAN #(
        .ENABLE_SCANLINE(CONFIG::ENABLE_SCANLINE)
    ) u_upscan (
        .RESET_n,
        .DCLK           (CLK_TMDS_P),
        .IN             (Video),
        .OUT            (VideoTmds)
    );

    BOARD_REV1_TMDS_OUT u_tmds (
        .RESET_n,
        .IN             (VideoTmds),
        .TMDS_READY     (CLK_TMDS_READY),
        .CLK_S          (CLK_TMDS_S),
        .CLK_P          (CLK_TMDS_P),
        .TMDS_CLKP      (tmds_clk_p),
        .TMDS_CLKN      (tmds_clk_n),
        .TMDS_DATAP     (tmds_data_p),
        .TMDS_DATAN     (tmds_data_n)
    );

    /***************************************************************
     * MAIN
     ***************************************************************/
    MAIN u_main (
        .RESET_n,
        .CLK,
        .Bus,
        .Ram            (UmaRam[0]),
        .VideoRam       (UmaRam[1]),
        .UmaClock       (Uma),
        .TF,
        .LedNextor,
        .Flash,
        .LedBoot,
        .Video,
        .SoundInternal,
        .SoundExternal
    );

endmodule


`default_nettype wire
