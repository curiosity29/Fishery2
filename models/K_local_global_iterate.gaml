
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
	int simulation_index <-1;
	
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
	float fish_average <- 0.0;


	// observing variable
	int nb_fish -> {length(fish)};
	
	
	// parameter for model and optimization

	int cycle_max <- 1000;
	int cycle_min <- cycle_max/2;

	// others

	init
	{
		create fish number: fish_number 
		with: (location: {rnd(100.0), rnd(100.0)});
		
	}
	int cycle_passed <- 0;
	reflex update when: cycle > cycle_min
	{
//		agent_fish_arr <- agent_fish_arr + [nb_fish];
		cycle_passed <- cycle_passed + 1 ;
		fish_average <- (fish_average*(cycle_passed-1) + nb_fish)/ cycle_passed;
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


experiment "agent to equation" type: batch repeat: 4 keep_seed: false until: cycle > cycle_max
{
	
//	parameter "index of simulation" var: simulation_index min: 0 max: 4 step: 1;
	parameter "local capacity" var: fish_local_cap min: 35.5 max: 40.5 step: 0.5;
//	parameter "fish_local_density_radius" var: fish_local_density_radius min: 1.0 max: 5.5 step: 1.0;
	
	
	
	reflex save_result
	{
		string fileName <- "../includes/results/RandK/" + "fish_average_" +simulation_index+ ".csv";
//		save agent_fish_arr to: fileName type: "csv";
//		string fileName <- "../includes/results/RandK/" + "NbFish.csv";
		save [fish_local_cap, fish_average] to: fileName type: "csv" rewrite: false;
	}
}


experiment "optimization" type: batch until: cycle > cycle_max
{
	parameter "local capacity" var: fish_local_cap min: fish_local_cap_expected/5 max: fish_local_cap_expected*2;
//	parameter "fish_local_density_radius" var: fish_local_density_radius min: 1.0 max: 5.0 step: 0.5;
	
	method annealing  minimize: error;
}



