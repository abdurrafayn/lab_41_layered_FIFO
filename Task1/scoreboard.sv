class scoreboard;

transaction trans_gen, trans_mon;
generator gen;

mailbox gen2score, mon2score;
int error_count = 0;
logic [7:0] queu [$];
logic [7:0] rdata;
int count;


event complete;

function new(mailbox gen2score, mailbox mon2score);
    this.gen2score = gen2score;
    this.mon2score = mon2score;

    this.trans_gen = new();
    this.trans_mon = new();
    this.count = 0;
    
endfunction


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//                                    RUN Task
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


task run();
    forever 
        begin
            gen2score.get(trans_gen);
            mon2score.get(trans_mon);
            $display("Now Calling scoreboard for running tests");
            trans_mon.display();
            

            reset();
            full_write();
            read_full();

            half_write();
            read_half();
            random_write();
            random_read_write();
            write_all_read_all();
            count ++;
        end
        -> complete;
endtask


// ------------------------------------------------------------------------
//                         First doing the Reset Test, 
// ------------------------------------------------------------------------

task reset();
    if(trans_gen.rst_n == 0)
    assert ( trans_mon.empty == 1) 
    else begin
            $error("Reset Test Failed!");
            error_count++;
         end
    $display("Reset Test Successful");
endtask

// ------------------------------------------------------------------------
//                         Writing Full data in FIFO to check full flag
// ------------------------------------------------------------------------

task full_write();
    if(trans_gen.wr_en == 1 && trans_gen.rd_en == 0) begin
            if (trans_mon.full == 0)  begin 
                   $display("here");
                    queu.push_back(trans_gen.data_in);
                    $display("Data %0d pushed into Golden Model at the back", trans_gen.data_in);
            end 
                
            
            else if(trans_mon.full == 1)
                $display("FIFO is full, you cant put more data into it. ");
        end
endtask

// ------------------------------------------------------------------------
//                         Reading Full data in FIFO to check full flag and empty flag (Full flag should be 0 and empty flag should be 1) 
// ------------------------------------------------------------------------

task read_full();
    if(trans_gen.wr_en == 0 && trans_gen.rd_en == 1)
    begin
  
        if(queu.size()>0) begin 
            rdata = queu.pop_front();
            if (rdata !== trans_mon.data_out) begin
                $error("Data Mismatch: Expected %0d, Got %0d", rdata, trans_mon.data_out);
                error_count++;
                end else begin
                    $display("Data Match: %0d", rdata);
                end
            end 
    
    end

endtask

// ------------------------------------------------------------------------
//                         Writing Data to Half FIFO to check about Full Flag and Empty Flag, both should be 0
// ------------------------------------------------------------------------


task half_write();
    if(trans_gen.wr_en == 1 && trans_gen.rd_en == 0)
    begin
        
        if(trans_mon.full == 0 && trans_mon.empty == 0)
        $display("FIFO Is half full, FULL and EMPTY flag are correct here."); 
        else
            $display("Test Failed: Empty and Full flag are not correct here, FIFO is half full. ");
    end
endtask


// ------------------------------------------------------------------------
//                         Reading half data
// ------------------------------------------------------------------------


task read_half();
    if(trans_gen.wr_en == 0 && trans_gen.rd_en == 1)
    begin
        
        if(trans_mon.full == 0 && trans_mon.empty == 1)
        $display("FIFO Is Empty."); 
        else
            $display("Test Failed: Empty flag should be 1");
    end
endtask

// ------------------------------------------------------------------------
//                         Random Data Writing to check flags/ corner cases
// ------------------------------------------------------------------------



task random_write();
    if(trans_gen.wr_en == 1 && trans_gen.rd_en == 0)
        begin
        
            if(trans_mon.full == 1 )
            $display("FIFO Is full, FULL and EMPTY flag are correct here."); 
            else
            $display("Test Failed: Full flag should be 1. ");
        end

endtask


// ------------------------------------------------------------------------
//                         Random Read After Write
// ------------------------------------------------------------------------


task random_read_write();
    if(trans_gen.wr_en == 1 && trans_gen.rd_en == 1)
    begin
        if(trans_mon.rd_en == 1 && trans_mon.wr_en == 0 && (trans_gen.data_in == trans_mon.data_out))
					$display("Read After Write Data Matched!  Original Data = %0d, Expected Data = %0d\n",trans_gen.data_in, trans_mon.data_out);
				else
					$display("Read After Write Data Misatch!  Original Data = %0d, Expected Data = %0d\n",trans_gen.data_in, trans_mon.data_out);
    end
endtask

// ------------------------------------------------------------------------
//                         Writting all then reading all
// ------------------------------------------------------------------------


task write_all_read_all();
    if(trans_gen.wr_en == 1 && trans_gen.rd_en == 0) begin
            if (trans_mon.full == 0)  begin 
                   $display("here");
                    queu.push_back(trans_gen.data_in);
                    $display("Data %0d pushed into Golden Model at the back", trans_gen.data_in);
            end 
                
            
            else if(trans_mon.full == 1)
                $display("FIFO is full, you cant put more data into it. ");
        end

    if(trans_gen.wr_en == 0 && trans_gen.rd_en == 1)
    begin
  
        if(queu.size()>0) begin 
            rdata = queu.pop_front();
            if (rdata !== trans_mon.data_out) begin
                $error("Data Mismatch: Expected %0d, Got %0d", rdata, trans_mon.data_out);
                error_count++;
                end else begin
                    $display("Data Match: %0d", rdata);
                end
            end 
    
    end

    if(trans_gen.wr_en == 1 && !trans_mon.empty) begin
        if(trans_mon.data_out == rdata)
        $display("Data Matched, Expected %0d, got Data_Read = %0d", rdata, trans_mon.data_out);
        else
            $display("Data MisMatched, Expected %0d, got Data_Read = %0d", rdata, trans_mon.data_out);
        end

endtask
endclass