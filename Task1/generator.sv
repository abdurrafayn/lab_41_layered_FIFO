class generator;

    transaction trans;
    mailbox gen2driver, gen2score;
    int count;
    event finished;

    function new(mailbox gen2driver, mailbox gen2score, int count, event finished);
        this.gen2driver = gen2driver;
        this.gen2score = gen2score;
        this.count = count;
        this.finished = finished;
        trans = new();
    endfunction


    task run();
        repeat(count) begin
            
        $display("Stating FIFO test sequences (GENERATOR)");


            // randomize: assert(trans.randomize());
            assert(trans.randomize());
            trans = new();
            
            reset();

            full_write();

            read_full();

            half_write();

            read_half();

            random_write();

            random_read_write();

            write_all_read_all();

            gen2driver.put(trans);
            gen2score.put(trans);
            // $display("Hello from Generator");
            trans.display();
        end
        -> finished;
    endtask


    // ---------------------------------------_Test Cases--------------------------------------

    task  reset();
        $display("Reset From ----Generator");
        trans.rst_n = 0;
        trans.wr_en = 0;
        trans.rd_en = 0;
        trans.data_in = 0;

        gen2driver.put(trans);
        gen2score.put(trans);

        trans.rst_n = 1;

        gen2driver.put(trans);
        gen2score.put(trans);

    endtask // reset test

    // Writing FUll FIFO test

    task full_write();
        $display("Full Write FIFO");
        trans.rst_n = 1;
        trans.rd_en = 0;
        for (int i = 0; i<8 ;i++ ) begin
            trans.wr_en = 1;
            trans.data_in = i+1;
            gen2driver.put(trans);
            gen2score.put(trans);
        end
    endtask

    // Read Full test

    task read_full();
        $display("Read Full FIFO");
        trans.wr_en = 0;
        trans.rd_en = 1;
        for (int i = 0; i<8; i++) begin
            gen2driver.put(trans);
            gen2score.put(trans);
        end
    endtask 


    task half_write();
        $display("Half Write FIFO");
            trans.rst_n = 1;
            trans.rd_en = 0;
                for (int i = 0; i<5 ;i++ ) begin
                    trans.wr_en = 1;
                    trans.data_in = i+1;
                    gen2driver.put(trans);
                    gen2score.put(trans);
            end
    endtask


    task read_half();
        $display("Read half FIFO");
        trans.wr_en = 0;
        trans.rd_en = 1;
        for (int i = 0; i<5; i++) begin
            gen2driver.put(trans);
            gen2score.put(trans);
        end
    endtask 


    task random_write();
        $display("Random data Writing to full");
        trans.rd_en = 0;
        trans.wr_en = 1;
        for (int i = 0; i<8 ;i++ ) begin
            if(trans.randomize()) begin
                trans.wr_en = 1;
                gen2driver.put(trans);
                gen2score.put(trans);
            end
        end
    endtask


    task random_read_write();
        $display("Randome Write + Read test");
        for (int i = 0; i< 5 ;i++ ) begin
            if(trans.randomize()) begin
                trans.wr_en = 1;
                trans.rd_en = 0;
                gen2driver.put(trans);
                gen2score.put(trans);

                trans.wr_en = 0;
                trans.rd_en = 1;
                gen2driver.put(trans);
                gen2score.put(trans);
            end
        end
    endtask

    task write_all_read_all();
        $display("Writing All and then readinn all values");
            //writing all

            trans.rd_en = 0;
            for (int i = 0; i<8 ;i++ ) begin
                if(trans.randomize()) begin
                trans.wr_en = 1;
                gen2driver.put(trans);
                gen2score.put(trans);
            end
            end
            //reading all
            trans.wr_en = 0;
            trans.rd_en = 1;
            for (int i = 0; i<5; i++) begin
            gen2driver.put(trans);
            gen2score.put(trans);
            end
    endtask

endclass