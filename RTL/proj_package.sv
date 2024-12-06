package apb_pkg;

    // Constants for state machine states
    typedef enum logic [1:0] {
        IDLE   = 2'b00,
        SETUP  = 2'b01,
        ENABLE = 2'b10
    } apb_master_state_t;

    typedef enum logic [1:0] {
        SLAVE_IDLE  = 2'b00,
        SLAVE_WRITE = 2'b01,
        SLAVE_READ  = 2'b10
    } apb_slave_state_t;

    // Address and data widths
    localparam int ADDR_WIDTH = 4;
    localparam int DATA_WIDTH = 8;
    localparam int SLV_ADDR_WIDTH = 2;

    // Error handling signals
    typedef struct packed {
        logic addr_err;  // Address range error
        logic addv_err;  // Address value error
        logic data_err;  // Data range error
    } apb_error_t;

    // APB interface structure for master-slave communication
    typedef struct packed {
        logic [ADDR_WIDTH-1:0] addr;  // Address bus
        logic [DATA_WIDTH-1:0] wdata; // Write data
        logic pwrite;                // Write/read control
        logic penable;               // Enable signal
        logic psel1;                 // Slave 1 select
        logic psel2;                 // Slave 2 select
    } apb_master_if_t;

    typedef struct packed {
        logic [DATA_WIDTH-1:0] rdata; // Read data
        logic pready;                // Ready signal
        logic pslverr;               // Slave error signal
    } apb_slave_if_t;

    // Common macros for error checking
    `define APB_ADDR_VALID(addr) ((addr) < 16)
    `define APB_DATA_VALID(data) ((data) >= 0)

endpackage
