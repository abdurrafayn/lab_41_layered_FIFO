
interface busI#(parameter DATA_WIDTH=8 )(input clk);

timeprecision 1ns;
timeunit 1ns;  


logic rst_n; 
logic wr_en; 
logic rd_en;
logic [DATA_WIDTH-1:0]  data_in;
logic [DATA_WIDTH-1:0] data_out;
logic full; 
logic empty;

endinterface