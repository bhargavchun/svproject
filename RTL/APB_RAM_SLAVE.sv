module apb_s_top (
    input logic pclk,
    input logic presetn,
    input logic [apb_pkg::ADDR_WIDTH-1:0] paddr,
    input logic psel,
    input logic penable,
    input logic [apb_pkg::DATA_WIDTH-1:0] pwdata,
    input logic pwrite,
    output logic [apb_pkg::DATA_WIDTH-1:0] prdata,
    output logic pready,
    output logic pslverr
);
    import apb_pkg::*;

    localparam apb_slave_state_t IDLE = SLAVE_IDLE;
    localparam apb_slave_state_t WRITE = SLAVE_WRITE;
    localparam apb_slave_state_t READ = SLAVE_READ;

    logic [DATA_WIDTH-1:0] mem[16];
    apb_slave_state_t state, nstate;

    // Error signals
    logic addr_err, addv_err, data_err;

    // Reset decoder
    always_ff @(posedge pclk or negedge presetn) begin
        if (!presetn)
            state <= IDLE;
        else
            state <= nstate;
    end

    // Next state and output decoder
    always_comb begin
        prdata = '0;
        pready = 1'b0;

        case (state)
            IDLE: begin
                if (psel && pwrite)
                    nstate = WRITE;
                else if (psel && !pwrite)
                    nstate = READ;
                else
                    nstate = IDLE;
            end
            WRITE: begin
                if (psel && penable) begin
                    if (!addr_err && !addv_err && !data_err) begin
                        pready = 1'b1;
                        mem[paddr] = pwdata;
                    end
                    nstate = IDLE;
                end
            end
            READ: begin
                if (psel && penable) begin
                    if (!addr_err && !addv_err && !data_err) begin
                        pready = 1'b1;
                        prdata = mem[paddr];
                    end
                    nstate = IDLE;
                end
            end
            default: nstate = IDLE;
        endcase
    end

   /* // Error handling
    assign addr_err = (paddr <= 16);
    assign addv_err = (paddr <= 0);  // Replace with address validation logic
    assign data_err = (pwdata == '0); // Replace with data validation logic

    assign pslverr = (psel && penable) ? (addr_err || addv_err || data_err) : 1'b0; */

// Checking valid values of address
  logic av_t;
  always_comb begin
    av_t = (paddr >= 0) ? 1'b0 : 1'b1;
  end

  // Checking valid values of data
  logic dv_t;
  always_comb begin
    dv_t = (pwdata >= 0) ? 1'b0 : 1'b1;
  end

  assign addr_err = ((nstate == WRITE|| nstate == READ) && (paddr > 4'hF)) ? 1'b1 : 1'b0;
  assign addv_err = (nstate == WRITE || nstate == READ) ? av_t : 1'b0;
  assign data_err = (nstate == WRITE || nstate == READ) ? dv_t : 1'b0;

  assign pslverr = (psel == 1'b1 && penable == 1'b1) ? (addv_err || addr_err || data_err) : 1'b0;


endmodule
