module shift_reg(
    input                               clk,
    input                               rst_n,
    input                               d,
    output wire [`SHIFT_REG_WIDTH-1:0]  out
);

    reg [`SHIFT_REG_WIDTH-1:0]  out_reg;

    assign out = out_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            out_reg <= {`SHIFT_REG_WIDTH{1'b0}};
        else
            out_reg <= {out_reg[`SHIFT_REG_WIDTH-2:0],d};
    end

endmodule

