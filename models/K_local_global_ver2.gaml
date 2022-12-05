

model RandK

global
{
// system
	int cycle_max <- 1000;
	int cycle_min <- cycle_max/2;
	int simulation_index <-1;
	float map_size <- 100.0;
	float pi <- 3.141592;


	int fish_cap <- 1000;


	int fish_number <- 5;
	float fish_reproduce_rate <- 0.1;				// r
	float fish_local_density_radius <- 10.0; 
	float fish_local_cap <- 30.0;						// local K
	float fish_speed <- 1.0;
	int fish_move_rate <- 5;
	list<float> agent_fish_arr;
	
	int height <- 10;
	int width <- 10;
	
	int nb_fish -> {length(fish)};
	init
	{
//		create my_equation;

		create fish number: fish_number 
		with: (location: {rnd(100.0), rnd(100.0)});
	}

	list range_freq_old;
	int avg_step <- 200;

		reflex update
	{
//		agent_fish_arr <- agent_fish_arr + [nb_fish];
//		error <- error + (nb_fish - my_equation[0].N)^2;
	}
	
	float fish_average <- 0.0;
	int cycle_passed <- 0;
	reflex update when: cycle > cycle_min
	{
//		agent_fish_arr <- agent_fish_arr + [nb_fish];
		cycle_passed <- cycle_passed + 1 ;
		fish_average <- (fish_average*(cycle_passed-1) + nb_fish)/ cycle_passed;
	}
	
}


grid my_cell width: width height: height
{
	
	list<fish> fishs_in_cell;
}


species fish skills: [moving] parallel: true
{
	int local_density <- 0;
	float adjust_factor <- pi * fish_local_density_radius^2;
	rgb color <- #green;
	init
	{
		speed <- fish_speed;
	}

	aspect base {
		draw circle(0.5) color: color;
	}
	
	
	
	reflex move {
		loop times: fish_move_rate
		{do wander;}
	}
	
	float area;
	reflex reproduce
	{
		float x <- self.location.x;
		float y <- self.location.y;
		float dx <- 0.0; float dy <- 0.0;
		float R <- fish_local_density_radius;
		area <- pi * R^2;
		if x < R or x > map_size - R
		{
			dx <- min(x, map_size - x);
		}

		if y < R or y > map_size - R
		{
			dy <- min(y, map_size - y);
		}

		if dx > 0.0 and dy >0.0
		{
			if R^2 < dx^2 + dy^2
			{
				area <- R^2/2 * (360 - 90 - acos(dx/R) - acos(dy/R))/180 * pi 
				+ dx*sqrt(R^2 - dx^2)/2 + dy*sqrt(R^2 - dy^2)/2 + dx*dy;
			}
			else
			{
				area <- R^2/2 * (360 - acos(dx/R) - acos(dy/R)) /180*pi
				+ dx*sqrt(R^2 - dx^2) + dy*sqrt(R^2 - dy^2);
			}
		}
		else if max(dx, dy) > 0.0
		{
			float d <- max(dx,dy);
			area <- R^2/2 * (360 - 2 * acos(d/R))/180 * pi  + d*sqrt(R^2 - d^2);
//			write(acos(d/R));
		}
		
		adjust_factor <- area / pi / R^2;
		
		local_density <- length(fish at_distance fish_local_density_radius) / adjust_factor;
		float reproduce_prob <- fish_reproduce_rate * (1 - local_density/ fish_local_cap);
		if reproduce_prob > 0
		{
			if flip(reproduce_prob)	
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
	parameter "local capacity" var: fish_local_cap min: 36.5 max: 41.5 step: 0.5;
//	parameter "fish_local_density_radius" var: fish_local_density_radius min: 1.0 max: 5.5 step: 1.0;
	reflex save_result
	{
		string fileName <- "../includes/results/RandK/" + "fish_average_ver2_" +simulation_index+ ".csv";
//		save agent_fish_arr to: fileName type: "csv";
//		string fileName <- "../includes/results/RandK/" + "NbFish.csv";
		save [fish_local_cap, fish_average] to: fileName type: "csv" rewrite: false;
	}

}
	
	



