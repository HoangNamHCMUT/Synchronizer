//--------------------------------------------------------------------------------------------------
//  Filename    :   synchronizer.v
//  Author      :   Jerry
//  Ver         :   1.0
//  Description :   Synchronizer data based on valid signal
//  Note        :   Please using Concatenation for your Data Ex: {DEV_ADD,REF_ADD,DATA}
//                  SHIFT_REG_WIDTH must be >= 2
//                  Both DATA_SYNC_WIDTH and SHIFT_REG_WIDTH can be configured based on your design
//--------------------------------------------------------------------------------------------------

`include "parameters.vh"

module synchronizer(
    input                               in_clk,
    input                               in_rst_n,
    input                               out_clk,
    input                               out_rst_n,
    input                               in_valid,
    input       [`DATA_SYNC_WIDTH-1:0]  in_data,

    output wire                         out_valid,
    output wire [`DATA_SYNC_WIDTH-1:0]  out_data
);

    reg                                 in_valid_reg;
    reg         [`DATA_SYNC_WIDTH-1:0]  in_data_reg;
    reg                                 out_valid_reg_1D;
    reg                                 out_valid_pulse;
    reg         [`DATA_SYNC_WIDTH-1:0]  out_data_reg;
    reg         [`SHIFT_REG_WIDTH-1:0]  shift_reg_u0_out;

    wire                                in_valid_p;
    wire        [`DATA_SYNC_WIDTH-1:0]  in_data_reg_p;
    wire                                out_valid_p;
    wire        [`DATA_SYNC_WIDTH-1:0]  out_data_reg_p;


    assign in_valid_p       = in_valid ? (~in_valid_reg) : in_valid_reg;
    assign in_data_reg_p    = in_valid ? in_data : in_data_reg;
    assign out_valid_p      = shift_reg_u0_out[`SHIFT_REG_WIDTH-1] ^ out_valid_reg_1D;
    assign out_data_reg_p   = out_valid_p ? in_data_reg : out_data_reg;

    assign out_valid        = out_valid_pulse;
    assign out_data         = out_data_reg;

    //Hold in_valid signal
    always @(posedge in_clk or negedge in_rst_n) begin
        if (!in_rst_n)
            in_valid_reg <= 1'b0;
        else
            in_valid_reg <= in_valid_p;
    end


    // Solve Metastability using Shift Register

    shift_reg shift_reg_u0(
        .clk(out_clk),
        .rst_n(out_rst_n),
        .d(in_valid_reg),
        .out(shift_reg_u0_out));


    // Delay out _valid after sync for pulse gen
    always @(posedge out_clk or negedge out_rst_n) begin
        if (!out_rst_n)
            out_valid_reg_1D <= 1'b0;
        else
            out_valid_reg_1D <= shift_reg_u0_out[`SHIFT_REG_WIDTH-1];
    end

    //out_valid
    always @(posedge out_clk or negedge out_rst_n) begin
        if (!out_rst_n)
            out_valid_pulse <= 1'b0;
        else
            out_valid_pulse <= out_valid_p;
    end


    //Hold in_data
    always @(posedge in_clk or negedge in_rst_n) begin
        if (!in_rst_n)
            in_data_reg <= {`DATA_SYNC_WIDTH{1'b0}};
        else
            in_data_reg <= in_data_reg_p;
    end

    // out_data

    always @(posedge out_clk or negedge out_rst_n) begin
        if (!out_rst_n)
            out_data_reg <= {`DATA_SYNC_WIDTH{1'b0}};
        else
            out_data_reg <= out_data_reg_p;
    end

endmodule


