s.waitForBoot{
	fork{
		~path = "/home/pi/prynth/server/public/supercolliderfiles/";
                //POETASTER
		//(~path++"chime.scd").load;
		(~path++"1.scd").load;
	};
};
