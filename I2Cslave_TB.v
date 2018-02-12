`include "I2Cslave.v"


module I2Cslave_TB();


reg clk, output_value_valid;

//Deal with 2 way data line here
inout wire SDA;
wire SDA_in;
reg data_val, SDA_dir;
assign SDA_in = SDA;
assign SDA = (SDA_dir) ? data_val : 1'bz;

wire [7:0] reg_out;


I2Cslave i2cslave_i(clk, SDA, reg_out);

always begin clk = ~clk; #3; end

initial		// Set slaves state values to zero
	begin
		i2cslave_i.idle = 1;
		i2cslave_i.started_message = 0;
		data_val = 1;
	end

initial
	begin
		clk = 1'b1;
		data_val = 1'b1;
		SDA_dir = 1;
		#1
		data_val = 1'b0;
		#3
		data_val = 1'b1; // First bit to translate
		#6					// Send another 1
		data_val = 1'b0; 	// 
		#6					// Send another 0
		#6					// Send another 0
		data_val = 1'b1; 	// 
		#6					// Send another 1
		#6					// Send another 1
		#6					// Send another 1
		#6					// Send another 1
		#6					// Send another 1
		SDA_dir = 0; 	// 
		#6					// Send High Impedance so someone else can drive the line
		SDA_dir = 1; 		// Back to sending values
		#6					// Send another 1
		#6					// Send another 1
		#10;
		$finish();
	end

// initial
// 	$monitor($time, "CLK=%d, SDA=%d, stmsg=%d, bitcnt=%d, isdatabit=%d, iddphase=%d, addmatch=%d", 
// 		clk, 
// 		data, 
// 		i2cslave_i.started_message, 
// 		i2cslave_i.bit_count,
// 		i2cslave_i.is_data_bit,
// 		i2cslave_i.add_phase,
// 		i2cslave_i.address_match
// 		);

initial
 begin
    $dumpfile("test.vcd");
    $dumpvars(0, I2Cslave_TB);
 end

endmodule