class transaction;

rand bit rst_n; 
rand bit wr_en; 
rand bit rd_en;
rand bit [7:0] data_in;
bit [7:0] data_out;
bit full; 
bit empty;

function void display();
    $display("Transaction:  \trst_n = %0b, wr_en = %0b, rd_en = %0b, data_in = %0d, data_out = %0d ", 
    rst_n, wr_en, rd_en, data_in, data_out);
endfunction

constraint c1 {rd_en != wr_en;}
//constraint rst {rst_n!=0;}


endclass