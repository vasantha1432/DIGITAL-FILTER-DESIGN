module FIR_Filter #(parameter N = 4)(
    input clk,
    input reset,
    input signed [7:0] x_in, 
    output reg signed [15:0] y_out 
);
    
    reg signed [7:0] coeffs [0:N-1];
    reg signed [7:0] delay_line [0:N-1]; 
    integer i;
    
    initial begin
       
        coeffs[0] = 1;
        coeffs[1] = 2;
        coeffs[2] = 3;
        coeffs[3] = 4;
    end
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            y_out <= 0;
            for (i = 0; i < N; i = i + 1) begin
                delay_line[i] <= 0;
            end
        end else begin
            // Shift the delay line
            for (i = N-1; i > 0; i = i - 1) begin
                delay_line[i] <= delay_line[i-1];
            end
            delay_line[0] <= x_in;
            
            // Compute FIR output
            y_out <= 0;
            for (i = 0; i < N; i = i + 1) begin
                y_out <= y_out + delay_line[i] * coeffs[i];
            end
        end
    end
endmodule

// Testbench for FIR Filter
module FIR_Testbench;
    reg clk, reset;
    reg signed [7:0] x_in;
    wire signed [15:0] y_out;
    
    FIR_Filter uut (.clk(clk), .reset(reset), .x_in(x_in), .y_out(y_out));
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end
    
    initial begin
        reset = 1;
        #10 reset = 0;
        
        // Test input sequence
        x_in = 8'd10; #10;
        x_in = 8'd20; #10;
        x_in = 8'd30; #10;
        x_in = 8'd40; #10;
        x_in = 8'd0;  #10;
        
        #100 $finish;
    end
    
    initial begin
        $monitor("Time=%0t | x_in=%d | y_out=%d", $time, x_in, y_out);
    end
endmodule
