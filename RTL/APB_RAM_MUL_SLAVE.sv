module mul_slave (
    input logic pclk,
    input logic presetn,
    input logic [apb_pkg::SLV_ADDR_WIDTH-1:0] slv_addr_in,
    input logic [apb_pkg::ADDR_WIDTH-1:0] addrin,
    input logic [apb_pkg::DATA_WIDTH-1:0] datain,
    input logic wr,
    input logic newd,
    output logic slverr_o,
    output logic [apb_pkg::DATA_WIDTH-1:0] dataout
);
    import apb_pkg::*;

    // Declare master and slave interfaces
    apb_master_if_t master_out;
    apb_slave_if_t slave_if1, slave_if2;
    apb_slave_if_t selected_slave_if; // Selected slave interface for the master

    // Select the slave interface based on `slv_addr_in`
    always_comb begin
        selected_slave_if = (slv_addr_in == 2'b01) ? slave_if1 : slave_if2;
    end

    // Master module
    apb_m_top m1 (
        .pclk(pclk),
        .presetn(presetn),
        .slv_addr_in(slv_addr_in),
        .addrin(addrin),
        .datain(datain),
        .wr(wr),
        .newd(newd),
        .slave_if(selected_slave_if), // Pass selected slave interface
        .master_out(master_out),
        .dataout(dataout)
    );

    // Slave 1
    apb_s_top s1 (
        .pclk(pclk),
        .presetn(presetn),
        .paddr(master_out.addr),
        .psel(master_out.psel1),
        .penable(master_out.penable),
        .pwdata(master_out.wdata),
        .pwrite(master_out.pwrite),
        .prdata(slave_if1.rdata),
        .pready(slave_if1.pready),
        .pslverr(slave_if1.pslverr)
    );

    // Slave 2
    apb_s_top s2 (
        .pclk(pclk),
        .presetn(presetn),
        .paddr(master_out.addr),
        .psel(master_out.psel2),
        .penable(master_out.penable),
        .pwdata(master_out.wdata),
        .pwrite(master_out.pwrite),
        .prdata(slave_if2.rdata),
        .pready(slave_if2.pready),
        .pslverr(slave_if2.pslverr)
    );

    // Combine error signals from both slaves
    assign slverr_o = slave_if1.pslverr || slave_if2.pslverr;

endmodule

