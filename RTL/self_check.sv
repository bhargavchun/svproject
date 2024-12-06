module tb_apb;

    // Define testbench signals
    logic pclk;              // Clock signal
    logic presetn;           // Reset signal
    logic [3:0] paddr;       // Address
    logic psel;              // Select signal
    logic penable;           // Enable signal
    logic [7:0] pwdata;      // Write data
    logic pwrite;            // Write control signal
    wire [7:0] prdata;       // Read data
    wire pready;             // Ready signal
    wire pslverr;            // Slave error signal
    
    // Instantiate the APB slave module (dut)
    apb_s_top dut (
        .pclk(pclk),
        .presetn(presetn),
        .paddr(paddr),
        .psel(psel),
        .penable(penable),
        .pwdata(pwdata),
        .pwrite(pwrite),
        .prdata(prdata),
        .pready(pready),
        .pslverr(pslverr)
    );
    
    // Clock generation
    always #5 pclk = ~pclk;

    // Task to perform a write transaction
    task perform_write(input [3:0] address, input [7:0] data);
        begin
            paddr = address;
            pwdata = data;
            pwrite = 1;
            psel = 1;
            penable = 0;
            #10; // Wait for the write address to be latched
            penable = 1;
            #10; // Wait for the data to be written
            psel = 0; // Deselect
        end
    endtask

    // Task to perform a read transaction
    task perform_read(input [3:0] address);
        begin
            paddr = address;
            psel = 1;
            penable = 0;
            pwrite = 0;
            #10; // Wait for the read address to be latched
            penable = 1;
            #10; // Wait for the data to be read
            psel = 0; // Deselect
        end
    endtask

    // Task to check for an error signal
    task check_error();
        begin
            if (!pslverr) begin
                $display("Error detected: pslverr = %b", pslverr);
            end else begin
                $display("No error detected");
            end
        end
    endtask

    // Initial block to drive the testbench
    initial begin
        // Initialize signals
        pclk = 0;
        presetn = 0;
        paddr = 0;
        psel = 0;
        penable = 0;
        pwdata = 0;
        pwrite = 0;

        // Apply reset
        $display("Applying reset...");
        repeat(2) @(posedge pclk);
        presetn = 1;

        // Perform write transactions
        $display("Performing valid write transactions...");
        perform_write(4'b0001, 8'hAA);  // Write 0xAA to address 0x1
        perform_write(4'b0010, 8'hBB);  // Write 0xBB to address 0x2
        perform_write(4'b0011, 8'hCC);  // Write 0xCC to address 0x3

        // Perform read transactions
        $display("Performing valid read transactions...");
        perform_read(4'b0001);  // Read from address 0x1
        perform_read(4'b0010);  // Read from address 0x2
        perform_read(4'b0011);  // Read from address 0x3

        // Perform invalid address transaction (pslverr should be triggered)
        $display("Performing invalid write to address 0x10 (out of range)...");
        perform_write(4'b1010, 8'hFF);  // Invalid address, should trigger error
        check_error();

        // Perform invalid read transaction (pslverr should be triggered)
        $display("Performing invalid read from address 0x10 (out of range)...");
        perform_read(4'b1010);  // Invalid address, should trigger error
        check_error();

        // End the simulation
        $stop;
    end

endmodule

