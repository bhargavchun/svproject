module tb_mul_slave;

    // Define testbench ports
    logic pclk = 0;
    logic presetn;
    logic [1:0] slv_addr_in;
    logic [3:0] addrin;
    logic [7:0] datain;
    logic wr;
    logic newd;
    logic slverr_o;
    logic [7:0] dataout;
    
    // Instantiate the mul_slave module
    mul_slave dut (
        .pclk(pclk),
        .presetn(presetn),
        .slv_addr_in(slv_addr_in),
        .addrin(addrin),
        .datain(datain),
        .wr(wr),
        .newd(newd),
        .slverr_o(slverr_o),
        .dataout(dataout)
    );
    
    always #10 pclk = ~pclk;  // Clock generation
    
    // Task to perform a write transaction
    task perform_write(input [1:0] slave_addr, input [3:0] address, input [7:0] data);
        begin
            slv_addr_in = slave_addr;
            addrin = address;
            datain = data;
            wr = 1;
            newd = 1;
            repeat(2) @(posedge pclk);
            newd = 1'b0;  // Clear new data flag
        end
    endtask

    // Task to perform a read transaction
    task perform_read(input [1:0] slave_addr, input [3:0] address);
        begin
            slv_addr_in = slave_addr;
            addrin = address;
            datain = 8'h00;  // Data is not needed for a read transaction
            wr = 0;
            newd = 1;
            repeat(2) @(posedge pclk);
            newd = 1'b0;  // Clear new data flag
        end
    endtask

    // Task to perform an invalid transaction
    task perform_invalid(input [1:0] slave_addr, input [3:0] address, input [3:0] data);
        begin
            slv_addr_in = slave_addr;
            addrin = address;
            datain = data;
            wr = 1;
            newd = 1;
            repeat(2) @(posedge pclk);
            newd = 1'b0;  // Clear new data flag
        end
    endtask

    initial begin
        // Reset sequence
        presetn = 0;  // Start with reset asserted
        repeat(5) @(posedge pclk);
        presetn = 1;  // Release reset
        
        // Perform write transactions to slave 1
        for (int i = 1; i < 10; i++) begin
            perform_write(2'b01, i, 5 * i);
        end

        // Perform write transactions to slave 2
        for (int i = 1; i < 10; i++) begin
            perform_write(2'b10, i, 10 * i);
        end

        // Perform read transactions from slave 1
        for (int i = 1; i < 10; i++) begin
            perform_read(2'b01, i);
        end

        // Perform read transactions from slave 2
        for (int i = 1; i < 10; i++) begin
            perform_read(2'b10, i);
        end

        // Perform invalid transactions for error checking
        // Uncomment to test invalid scenarios
        
        perform_invalid(2'b01, 4'bxx00, $urandom);  // Invalid address for slave 1
        perform_invalid(2'b01, $urandom, 4'b011x);  // Invalid data for slave 1
        perform_invalid(2'b10, 4'bxx00, $urandom);  // Invalid address for slave 2
        perform_invalid(2'b10, $urandom, 4'b011x);  // Invalid data for slave 2
       

        $stop;  // Stop simulation
    end

endmodule

