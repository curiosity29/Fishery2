
/*
 * movement speed for fish
 * remove boat
 * 
 */


model RandK

global
{
// system
	float map_size <- 100.0;
	float pi <- 3.141592;
	list range_arr <- [70,74,78,82,86,90,94,98,102,106,110,114, 118, 122, 126, 130];
	int len <- length(range_arr);
	list range_freq <- list_with(len+1, 0.0);
	list range_freq_move <- list_with(len+1, 0.0);
	
	int fish_cap <- 1000;

	int fish_number <- 5;
	float fish_reproduce_rate <- 0.1;				// r
	float fish_local_density_radius <- 10.0; 
	float fish_local_cap <- 30.0;						// local K
	float fish_speed <- 1.0;
	int fish_move_rate <- 5;
	list<float> agent_fish_arr;
	
	float range <- fish_local_cap/100;
	
	int height <- 10;
	int width <- 10;
	
	int nb_fish -> {length(fish)};
	init
	{
//		create my_equation;

		create fish number: fish_number 
		with: (location: {rnd(100.0), rnd(100.0)});
	}

	list range_freq_show <- list_with(len+1, 0.0);
	list range_freq_old;
	int avg_step <- 200;
	reflex freq_moving_avg_1
	{
		loop index from: 0 to: len
		{
			range_freq_move[index] <- range_freq_move[index] + range_freq[index]/avg_step; 
		}
	}
	reflex freq_moving_refresh when: cycle mod avg_step = 0
	{
		loop index from: 0 to: len
		{
			range_freq_show[index] <- range_freq_move[index];
		}

		range_freq_move <- list_with(len+1, 0.0);
	}

		reflex update
	{
//		agent_fish_arr <- agent_fish_arr + [nb_fish];
//		error <- error + (nb_fish - my_equation[0].N)^2;
		range_freq <- list_with(len+1, 0.0);
	}
}


grid my_cell width: width height: height
{
	
	list<fish> fishs_in_cell;
}


species my_equation { 	
	
	float E <- 0.3;
	float K <- 100.0;
	float r <- 0.5;
	float h <- 0.01;	// step size
	float E1 <- 5.0 * h;
	
	float N <- 10.0;
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
	int local_density <- 0;
	float adjust_factor <- 0.0;
	image_file my_icon <- image_file("../includes/data/fish2.png");
	rgb color <- #green;
	init
	{
		speed <- fish_speed;
	}

	aspect base {
		draw circle(0.5) color: color;
	}
	
	reflex change_color
	{
		if local_density > range*range_arr[len-3]
		{
			color <- #red;	
		}
		else if local_density < range*range_arr[2]
		{
			color <- #green;
		}
		else
		{
			color <- #blue;
		}
	}
	
	reflex move {
		loop times: fish_move_rate
		{do wander;}
	}
	
	aspect icon {
		draw my_icon size: 1.0;
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
	reflex to_freq_list
	{
		loop index from: 0 to: len-1
		{
			if local_density < range*range_arr[index]
			{
				range_freq[index] <- range_freq[index] + 1;
				return;
			}
		}
		range_freq[len] <- range_freq[len] + 1;
	}
}


experiment main_experiment type: gui
{
	
	output
	{
		display map
		{
			grid my_cell border: #black;

			species fish aspect:base;
		}
		display Population_information {
		chart "Number of fish" type: series size: {1,0.5} position: {0, 0} {
				data "Number of fish" value: nb_fish color: #blue;
			}	
			chart "Local density distribution" type: histogram size: {1, 0.5} position: {0, 0.5} 
			{
				data "< " + range_arr[0] + "%" value: range_freq_show[0] color: #blue;
				loop index from: 0 to: len-2
				{
					data ""+range_arr[index] + "-" + range_arr[index+1] + "%" value: range_freq_show[index] color: #blue; 
				}
				data "> " + range_arr[len-1] + "%" value: range_freq_show[len-1]  color: #blue;

			}

		}
	}
}



