///////////////////////////////////////////////////////////////////////////////////
//module name:	Electromagnetic_Acoustic
//file name:	Electromagnetic_Acoustic.v
//time:			2018-3-16
//Programmer:	ld
//======Introduction=======
//
//
//

`timescale    1ns/100ps

module    Electromagnetic_Acoustic(
//------------Global Signals------------------
    input    wire    clk_sys,
	 input	 wire		clk_100,
	 input	 wire		clk_100_delay,
	 input	 wire		clk_coder,
	 input	 wire		RESET_N,
	 output	 wire 	alarm_buzzer,		//alarm
//-------------ARM interface------------------
	 input	 wire    [7:0]    ARM_A,
	 inout	 wire    [15:0]	ARM_D,
	 input	 wire	   iARM_CE_N, 
	 input	 wire    iARM_OE_N,				  //nOE (Output Enable) indicates that the current bus cycle is a read cycle.
	 input	 wire		iARM_WE_N,				  //nWE (Write Enable) indicates that the current bus cycle is a write cycle.
	 input	 wire		iARM_DAC_ALARM,	
	 input	 wire		iARM_VAL_ALARM,	
	 input	 wire		iARM_LOGIC_RESET,	
	 //input		wire[ 1:0]	iWrite_Strobe,	  //unused
	 //input		wire[ 1:0]	iRead_Strobe,	  //unused
//------------DA0 interface-------------------	
	 output	  wire    oDA_SCLK,	
	 output	  wire	 oDA_DOUT,	
	 output	  wire	 oDA_SYNC_n,  
	 output    wire	 oDA_LDAC_n,  
//------------AD9215 interface----------------
	 input    wire    [9:0]    iAD0_DATA,		//AD collect data
	 output	 wire		oAD0_CLK,		         //max = 40Mhz
	//	input		wire			iAD0_otr,                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            		   //out of range
//-----------Coder interface------------------
    input    wire    CoderInputA,
	 input    wire		CoderInputB,		
//-----------T/R interface-----------------
	 input	 wire    protect_in,		         //protect
	 input	 wire		SensorOK,
	 output	 wire		oTrigger0,
	 output	 wire		oTrigger1,
	 output   wire    receive_amp_en,
	//	output	wire 			Probe_mode,
//-----------POWER interface-----------------
	 input	 wire 	pow_key_det,		//System Power Key Detect
	 output	 wire 	powen_sys,			//System POWER ON/OFF Control 1 --> ON; 0 --> OFF
	 output	 wire 	powen_mosfet,		//FPGA POWER(3.3V/2.5V/1.2V) control 1-->OFF; 0-->ON
	 output	 wire 	powen_lcd,			//
	 output	 wire    powen_HV,				//LCD/AD/T/R POWER(VLED/3V/+-5V/15V) Control: 1-->ON; 0-->OFF
//-----------pulsed Mega-----------------
	 output	 wire		pulsedMega_HV,			//
	 output	 wire		pulsedMega_tirgger		//
//-----------test-----------------
	//	output	wire 			AD_sample_en
	//	input		wire[ 1:0]	test1,			//unused
	//	output	wire[15:0]	test2				//unused
);
wire    signed[31:0]    CoderPosition;
wire    [7:0]           LightScale;
wire    [2:0]           burst_period;
wire    [9:0]           pulse_period;
wire    [5:0]           pulse_num;
wire    [11:0]          gain_codeA;
wire    [1:0]           AD_sample_flag;
wire    [9:0]           ARM_read_fifo_data;
wire    [9:0]           ARM_MAX_data;
wire                    PositionClear_n;
wire                    ARM_powdn_cmd;
wire                    ARM_read_over;
wire                    alarm_en;
wire                    ARM_read_fifo_rdreq;
wire                    ARM_data_ready;
wire                    protect_en;
wire                    SensorOK_en;
wire	                  LCDen;
wire                    pulse_out;
wire                    AD5322_en;
wire                    burst_syn;
wire                    clk_sample;
wire                    AD_sample_en;
wire                    AD_data_valid;

//XXXXXXXXXXXXXXXXXXXX ARM_interface XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
ARM_interface    U_ARM_interface(
    .clk_sys            (clk_sys            ),
	 .clk_coder          (clk_coder          ),
	 .RESET_N            (RESET_N            ),
    .iARM_CE_N          (iARM_CE_N          ),
	 .iARM_OE_N          (iARM_OE_N          ),
	 .iARM_WE_N          (iARM_WE_N          ),
	 .ARM_A              (ARM_A              ),
	 .ARM_D              (ARM_D              ),
	 .alarm_buzzer       (alarm_buzzer       ),
	 .ARM_powdn_cmd      (ARM_powdn_cmd      ),
	 .LightScale         (LightScale         ),
	 .burst_period       (burst_period       ),
	 .pulse_period       (pulse_period       ),
	 .pulse_num          (pulse_num          ),
	 .gain_codeA         (gain_codeA         ),
	 .AD_sample_flag     (AD_sample_flag     ),
	 .ARM_read_fifo_data (ARM_read_fifo_data ),
	 .ARM_MAX_data       (ARM_MAX_data       ),
	 .ARM_read_fifo_rdreq(ARM_read_fifo_rdreq),
	 .ARM_read_over      (ARM_read_over      ),
	 .ARM_data_ready     (ARM_data_ready     ),
	 .SensorOK_en        (SensorOK_en        ),
	 .PositionClear_n    (PositionClear_n    ),
	 .CoderPosition      (CoderPosition      ),
	 .protect_en         (protect_en         ),
	 .alarm_en           (alarm_en           )
	 
	
	);	
	
//XXXXXXXXXXXXXXX PowerDown XXXXXXXXXXXXXXXXXXXXXXXXX
PowerDown    U_PowerDown(
    .clk_sys      (clk_sys      ),
	 .RESET_N      (RESET_N      ),
	 .pow_key_det  (pow_key_det  ),
	 .ARM_powdn_cmd(ARM_powdn_cmd),
	 .powen_sys    (powen_sys    )
	
	);

//XXXXXXXXXXXXXXXXX AD XXXXXXXXXXXXXXXXXXXXXXXX
AD    U_AD(
    .clk_100         (clk_100                    ),
	 .RESET_N         (RESET_N                    ),
	 .reset_n         (RESET_N	&& iARM_LOGIC_RESET),
	 .clk_100_delay   (clk_100_delay              ),
	 .burst_syn       (burst_syn                  ),
	 .clk_sample      (clk_sample                 ),
	 .AD_sample_en    (AD_sample_en               ),
	 .AD_data_valid   (AD_data_valid              ),
	 .oAD0_CLK        (oAD0_CLK                   ),
	 .AD_sample_flag  (AD_sample_flag             )
	
	);

//XXXXXXXXXXXXXXXXXXXX signal XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
signal_pro    U_signal_pro(
    .clk						(clk_sample					      ),
	 .reset_n			   (RESET_N  && iARM_LOGIC_RESET	),	
	 .AD_data_in		   (iAD0_DATA				         ),
	 .AD_data_valid		(AD_data_valid			         ),
    .burst_period       (burst_period                 ),
	 .pulse_period		   (pulse_period	               ),
	 .ARM_read_fifo_data (ARM_read_fifo_data 	         ),
	 .ARM_MAX_data		   (ARM_MAX_data			         ),
	 .ARM_read_fifo_clk	(clk_sys					         ),
	 .ARM_read_fifo_rdreq(ARM_read_fifo_rdreq	         ),
	 .ARM_read_over		(ARM_read_over			         ),      
	 .ARM_data_ready		(ARM_data_ready		         )  
		
		);

//XXXXXXXXXXXXXXXXXXXXXX protect XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
protect    U_protect(	
    .clk			 (clk_100	),
	 .reset_n	 (RESET_N   ),
	 .protect_in (protect_in),
	 .SensorOK	 (SensorOK	),
	 .protect_en (protect_en),
	 .SensorOK_en(SensorOK_en)
		
	);
	
//XXXXXXXXXXXXXXXXXXXXXXXX Coder XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Coder    U_Coder(
    .clk			  (clk_coder	   ),
	 .reset_n	  (RESET_N		   ),
	 .CountClear_n(PositionClear_n),
	 .SignalA	  (CoderInputA		),
	 .SignalB	  (CoderInputB		),
	 .dout		  (CoderPosition  )
	
	);	
	
//XXXXXXXXXXXXXXXXXXXXXXXX LCD Lightness Control Logic XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
LCDENctrl    U_LCDENctrl(
    .clk			(clk_coder	),
	 .reset_n	(RESET_N		),
	 .LightScale(LightScale	),
	 .LCDen		(LCDen		)
	 
	);
//XXXXXXXXXXXXXXXXXXXXXXXX Burst Repeat Freq Control Logic XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX		
//Request:	Burst Repeat Freq--25,50,100,200,400,800Hz
//Input:		burst_period
//Output:	synchronizing signal
burst_syn_ctrl    U_burst_syn_ctrl(
    .clk_100		 	  (clk_100				),
	 .reset_n		 	  (RESET_N				),
	 .burst_period		  (burst_period		),
	 .burst_syn			  (burst_syn			),
	 .pulsedMega_HV	  (pulsedMega_HV		),		
	 .pulsedMega_tirgger(pulsedMega_tirgger)	
	 //.clk_sample	 	  (clk_sample			)
	 //.AD_sample_flag  (AD_sample_flag	   )
		
	);
	
//XXXXXXXXXXXXXXXXXXXXXXX pulse Control Logic XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX	
pulse_gen    U_pulse_gen(	
    .clk			  (clk_100		),
	 .RESET_N	  (RESET_N	   ),
	 .pulse_period(pulse_period),
	 .pulse_num	  (pulse_num	),
	 .burst_syn	  (burst_syn   ),
	 .protect_en  (1'b0			),
	 .pulse_out	  (pulse_out	)
	 //.AD_sample_flag(AD_sample_flag)
	 
	);

//XXXXXXXXXXXXXXXXXXXXXXXXX AD5322 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX			
AD5322    U_AD5322(
    .clk				(clk_sys   ),//less than 150MHz
	 .RESET_N		(RESET_N	  ),
	 .en				(AD5322_en ),
	 .ChannelA_data(gain_codeA),
	 .ChannelB_data(gain_codeA),
	 .sclk			(oDA_SCLK  ),
	 .dout			(oDA_DOUT  ),
	 .sync_n			(oDA_SYNC_n),
	 .ldac_n			(oDA_LDAC_n)	
	 
	);	

//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
//电源控制，在AD采样期间将电源关掉，由电容供电，其他时间将电源打开给电容充电	

    assign    oTrigger0      = pulse_out;// P
	 assign	  oTrigger1      = !pulse_out;// N
    assign    AD5322_en      = ~AD_sample_en; //在AD不采样的时间一直更新放大器增益
	 assign    powen_lcd      = LCDen & (~AD_sample_en);
	 assign    powen_mosfet   = ~AD_sample_en;
	 assign    powen_HV       = ~AD_sample_en;
	 assign    receive_amp_en = ~AD_sample_en;

endmodule