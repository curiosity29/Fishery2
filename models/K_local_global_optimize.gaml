
/*
 * movement speed for fish
 * remove boat
 * 
 */


model KLocalGlobal

global
{
//		float step <- 1 # s;

	// system
	float map_size <- 100.0;	// width and height
	
	// parameter for both models
	int fish_number <- 5;

	//equation parameter	
	float fish_cap <- 1000.0;

	// parameter for agent
	float fish_reproduce_rate <- 0.1;				// r
	float fish_local_density_radius <- 10.0;
	float fish_local_cap <- 3.141592 * fish_local_density_radius^2 / map_size^2 * fish_cap;
//	float fish_local_cap <- 61.4;
	float fish_local_cap_expected <- 3.141592 * fish_local_density_radius^2 / map_size^2 * fish_cap;
								// local K
		// behavior parameter
	int fish_speed <- 1.0;
	int fish_move_rate <- 5;
	list<float> agent_fish_arr;


	// observing variable
	int nb_fish -> {length(fish)};
	
	
	// parameter for model and optimization
	float error <- 0;
	int cycle_max <- 1000;

	// others
	int index <-10;

	init
	{
		create my_equation;

		create fish number: fish_number 
		with: (location: {rnd(100.0), rnd(100.0)});
		
	}
	reflex update when: cycle > cycle_max/2
	{
//		agent_fish_arr <- agent_fish_arr + [nb_fish];

		error <- error + (nb_fish - my_equation[0].N)^2/2^16;
	}
	reflex show_error when: cycle = cycle_max - 1
	{
		write("capacity: " + fish_local_cap + ",	error: " + error);
	}
}

species my_equation { 	
	
	float E <- 0.0;
	float K <- fish_cap;
	float r <- fish_reproduce_rate;
	float h <- 0.01;	// step size
	float E1 <- 5.0 * h;
	
	float N <- fish_number;
	float t;
	float Y;
	
	equation EQ {			
		diff(N, t) = r * N * (1 - N/K) - E * N;
	}

	reflex solving {
		solve EQ method: #rk4 step_size: h;
		
//		Y <- E * K  * (1 - E / r);
		Y <- E * N;
		N <- N - E1;
	}
}

species fish skills: [moving] parallel: true
{

	init
	{
		speed <- fish_speed;
	}

	reflex move {
		loop times: fish_move_rate
		{do wander;}
	}
	
	aspect base {
		draw circle(1) color: color;
	}

	
	reflex reproduce
	{
		int local_density <- length(fish at_distance fish_local_density_radius);
		float reproduce_prob <- fish_reproduce_rate * (1 - local_density/ fish_local_cap);

		if reproduce_prob > 0
		{
			if flip(reproduce_prob)	// currently not die when rate < 0
			{
				create fish with: (location: self.location);
			}			
		}
		else if flip(-reproduce_prob)
		{
			do die;
		}
	}
}

experiment "equation test" type: gui {
	output {
		display chartcontinuous {
			chart 'chart for population' type: series background: rgb('white') 
				x_serie: (my_equation[0]).t[]
				size: { 1.0, 0.5 } position: { 0.0, 0.0 }
			{
				data "Nt" value: (my_equation[0]).N[] color: # red marker: false;
			}

			chart 'chart for yeild' type: series background: rgb('white') size: { 1.0, 0.5 } position: { 0.0, 0.5 } {
				data "Yt" value: first(my_equation).Y color: rgb('red') marker: false;
			
			}
	
		}
	}
}

experiment "agent test" type: gui
{
	
	output
	{
		display map
		{


			species fish aspect:base;
		}

		display Population_information {
		chart "Number of fish" type: series {
				data "Number of fish" value: nb_fish color: #blue;
			}	
		}
		
	}
	
}

experiment "agent to equation" type: batch repeat: 4 keep_seed: false until: cycle > cycle_max
{
	
	parameter "index of simulation" var: index min: 0 max: 4 step: 1;
	parameter "local capacity" var: fish_local_cap min: 10.0 max: 50.0 step: 1.0;
	parameter "fish_local_density_radius" var: fish_local_density_radius min: 1.0 max: 5.0 step: 0.5;
	
	
	
	reflex save_result
	{
		string fileName <- "../includes/results/RandK/" + "NbFish_" + index + "_.csv";
//		save agent_fish_arr to: fileName type: "csv";
//		string fileName <- "../includes/results/RandK/" + "NbFish.csv";
		save agent_fish_arr to: fileName type: "csv" rewrite: index = 0;
	}
}


experiment "optimization" type: batch until: cycle > cycle_max
{
	parameter "local capacity" var: fish_local_cap min: fish_local_cap_expected/5 max: fish_local_cap_expected*2;
//	parameter "fish_local_density_radius" var: fish_local_density_radius min: 1.0 max: 5.0 step: 0.5;
	
	method hill_climbing  minimize: error;
}



