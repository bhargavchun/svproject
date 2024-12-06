module apb_m_top (
    input logic pclk,
    input logic presetn,
    input logic [apb_pkg::SLV_ADDR_WIDTH-1:0] slv_addr_in,
    input logic [apb_pkg::ADDR_WIDTH-1:0] addrin,
    input logic [apb_pkg::DATA_WIDTH-1:0] datain,
    input logic wr,
    input logic newd,
     input var apb_pkg::apb_slave_if_t slave_if,  // Declaring slave_if as input correctly
     output var apb_pkg::apb_master_if_t master_out,
    output logic [apb_pkg::DATA_WIDTH-1:0] dataout
);
    import apb_pkg::*;

    apb_master_state_t state, nstate;

    // Reset decoder
    always_ff @(posedge pclk or negedge presetn) begin
        if (!presetn)
            state <= IDLE;
        else
            state <= nstate;
    end

    // State machine logic
    always_comb begin
        case (state)
            IDLE: nstate = newd ? SETUP : IDLE;
            SETUP: nstate = ENABLE;
            ENABLE: nstate = (newd && slave_if.pready) ? SETUP : ENABLE;
            default: nstate = IDLE;
        endcase
    end

    // Address decoding
    always_ff @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            master_out.psel1 <= 1'b0;
            master_out.psel2 <= 1'b0;
        end else if (nstate == IDLE) begin
            master_out.psel1 <= 1'b0;
            master_out.psel2 <= 1'b0;
        end else if (nstate == SETUP || nstate == ENABLE) begin
            master_out.psel1 <= (slv_addr_in == 2'b01);
            master_out.psel2 <= (slv_addr_in == 2'b10);
        end else begin
            master_out.psel1 <= 1'b0;
            master_out.psel2 <= 1'b0;
        end
    end

    // Output assignments
    always_ff @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            master_out.penable <= 1'b0;
            master_out.addr <= '0;
            master_out.wdata <= '0;
            master_out.pwrite <= 1'b0;
        end else if (nstate == SETUP) begin
            master_out.addr <= addrin;
            master_out.pwrite <= wr;
            if (wr)
                master_out.wdata <= datain;
        end else if (nstate == ENABLE) begin
            master_out.penable <= 1'b1;
        end
    end

    assign dataout = (master_out.penable && !wr) ? slave_if.rdata : 8'h00;
endmodule
