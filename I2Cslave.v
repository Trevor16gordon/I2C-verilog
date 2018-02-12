//I2Cslave Module
// Trevor Gordon
// Feb 7 2018



module I2Cslave(
SCL, SDA, reg_out
);
// Constants
parameter my_address = 8'b1001111x; // Last x is a don't care so the read/write bit doesn't unmatch address


// Definitions
input SCL;					// Clock line in
inout wire SDA;					// Data line in
output [7:0] reg_out;		// Paralell register data out
// States ~ 20 States so 5 bit states
reg [4:0] cs, ns; // Current state / next state
reg idle, started_message, write;
reg [7:0] reg_out;
reg start;

// If data line gets pulled low when SCL is high advance to start
always@(negedge SDA) 
	begin
		if (SCL == 1)
			begin
				start = 1;
			end
	end


// Detect whether data is starting to be sent

always@(posedge start)
	begin		
			idle = 1'b0;			// Idle is now low
			started_message <= 1;	// This can only set started_message high, won't bring it low
			//bit_count = 7;			// Needed just to start I think.
	end


// Start bit
reg [3:0] bit_count;			//Count bits coming in
wire is_data_bit, is_ack_bit;	//First 8 bits are data and 9 is time to send ack
reg data_phase, add_phase;		//The 8 bits coming could be address or data
reg address_match, op_read;		// If op_read is one, read, otherwise write	

assign is_data_bit = ~bit_count[3];
assign is_ack_bit = bit_count[3];


//Deal with 2 way data line here
wire SDA_in, SDA_dir;
reg SDA_out;
assign SDA_in = SDA;
assign SDA = (SDA_dir) ? SDA_out : 1'bz;
assign SDA_dir = (idle) ? 0: (bit_count < 7);


// Read 8 Bits - Good for Address and Data Phase
always@(posedge SCL)
	if (~idle)
	begin
		begin
			if (started_message) 				// Only once per cycle
				begin
					started_message = 1'b0; 	// Set started_message low so next
					bit_count = 7; 				// Reset counter to 7
					add_phase = 1'b1;			// Start Address read phase
					data_phase = 1'b0;			// Ensure Data Phase is zero
					address_match = 1'b1;		// Any mismatched address bits will bring this low
				end
			else 
				begin								// Not the first loop
					if (is_data_bit)
						begin
							if (add_phase)		// Address Phase
								begin
									address_match = address_match&(SDA == my_address[bit_count]); 
									bit_count = bit_count + 4'b1111; // Subtract 1
								end
							if (data_phase & address_match & write)
								begin
									reg_out[bit_count] = SDA; 
									bit_count = bit_count + 4'b1111; // Subtract 1
								end
							
						end
					else // Ack Bit
						begin
							add_phase = 1'b0;			// Address read phase Over
							data_phase = 1'b1;			// Start Data Phase
							bit_count = 7;
							if (address_match)
								begin
									SDA_out = 1'b0;				// If we get to this point and it's our address, lets acknowledge
								end
						end
				end
		end
	end

always @(SCL)		// This will take the last bit from Address byte as the read/write bit
	begin
		if(add_phase & bit_count==0) op_read = SDA_in;
	end


// Determine if that address is us + Read/Write





// Send Acknowledge Bit






// Write -- change value of my regs






// Read -- Broadcast Bits on SDA







endmodule

