//
// clk_speed.sv
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

module CLK_SPEED #(
    parameter COUNT_TH = ((108_000 / 3_580) / 2 - 2)
) (
    input   wire            RESET_n,
    input   wire            CLK,
    input   wire            CLK_3_58M,
    input   wire            CLK_3_58M_EN,
    output  wire            FAST
);
    assign FAST = flag;

    // CLK の High 期間をチェック
    localparam  TH = (COUNT_TH - 1);
    localparam  BIT_WIDTH = $clog2(TH + 1);

    reg [BIT_WIDTH - 1:0] clk_speed_count;
    
    always_ff @(posedge CLK or negedge RESET_n) begin
        if(!RESET_n) begin
            clk_speed_count <= 0;
        end
        else if(CLK_3_58M_EN) begin
            clk_speed_count <= TH;
        end
        else if(CLK_3_58M) begin
            if(clk_speed_count != 0) clk_speed_count <= clk_speed_count - 1'd1;
        end
    end

    // High 期間の長さでフラグを更新
    reg flag;

    always_ff @(posedge CLK or negedge RESET_n) begin
        if(!RESET_n) begin
            flag <= 0;
        end
        else if(!CLK_3_58M) begin
            flag <= clk_speed_count != 0;
        end
    end

endmodule

`default_nettype wire
