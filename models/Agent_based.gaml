
model Agentbased

global
{
	
	
	int fish_number <- 50;
	float fish_reproduce_rate <- 0.1;				// r
	float fish_local_density_radius <- 10.0; 
	float fish_local_cap <- 100.0;						// local K
	float fish_speed <- 1.0;
	
	int boat_number <- 5;
	float boat_speed <- 5.0;
	float boat_catch_prob <- 0.2;
	float boat_fishing_radius <- 10.0;
	float yeild_all <- 0.0;

	int height <- 10;
	int width <- 10;
	
	int nb_fish -> {length(fish)};
	init
	{
//		fish_speed <- 1.0;
		create fish number: fish_number 
		with: (location: {rnd(100.0), rnd(100.0)});
		
		create boat number: boat_number;
		create fish number: fish_number;
//		ask fish
//		{
//			location <- {rnd(height), rnd(width)};
//		}
	


	}
	
	reflex reset_yeild
	{
		yeild_all <- 0.0;
		ask boat
		{
			yeild <- 0.0;
		}
	}
}



grid my_cell width: width height: height
{
	
	list<fish> fishs_in_cell;
	
}

species generic_species skills: [moving]

{
//	image_file my_icon;
	float size <- 1;
}

species fish parent: generic_species
{
  	init {
	    	speed <- fish_speed;
   	}

	reflex move {
		do wander;
	}
	image_file my_icon <- image_file("../includes/data/fish2.png");
	
	aspect base {
		draw circle(1) color: color;
	}

	aspect icon {
		draw my_icon size: 1.0;
	}
	
	reflex reproduce
	{
		int local_density <- length(fish at_distance fish_local_density_radius);
		float reproduce_prob <- fish_reproduce_rate * (1 - local_density/ fish_local_cap);
		if flip(reproduce_prob)	// currently not die when rate < 0
		{
			create fish with: (location: self.location);
		}
	}
	
}

species boat parent: generic_species
{
  	init {
    	speed <- boat_speed;
   	}

	float yeild <- 0;
	image_file my_icon <- image_file("../includes/data/boat.png");
	reflex catch_fish
	{
		float yeild <- 0;
		list<fish> fish_in_area <- fish at_distance boat_fishing_radius;
		int fish_num <- length(fish_in_area);
		loop times: fish_num
		{
			if flip(boat_catch_prob)
			{
				yeild_all <- yeild_all + 1;
				yeild <- yeild + 1;
				ask one_of (fish_in_area) { do die; }
			}
		}

	}
	aspect base {
		draw circle(boat_fishing_radius) color: color;
	}

	aspect icon {
		draw my_icon size: 4.0;
	}
	
	reflex move {
    do wander;
    }
}

experiment main_experiment type: gui
{
	parameter "Initial number of fishs: " var: fish_number min: 0 max: 1000 category: "Fish";
	parameter "Fish local density radius" var: fish_local_density_radius min: 0.0 max: 30.0 category: "Fish";
	parameter "Fish reproduce rate" var: fish_reproduce_rate min: 0.0 max: 20.0 category: "Fish";
	parameter "Fish local population capacity" var: fish_local_cap min: 0.0 max: 500.0 category: "Fish";
	parameter "Fish's movement speed " var: fish_speed min: 0.0 max: 30.0 category: "Fish";
	
	parameter "Initial number of boats: " var: boat_number min: 0 max: 30 category: "Boat";
	parameter "Effort / catch probability" var: boat_catch_prob min: 0.0 max: 1.0 category: "Boat";
	parameter "Catching radius" var: boat_fishing_radius min: 0.0 max: 30.0 category: "Boat";
	parameter "Boat's movement speed " var: boat_speed min: 0.0 max: 30.0 category: "Boat";
	
	parameter "Horizontal grid number" var: width min: 0 max: 30 category: "Model";
	parameter "Vertical grid number" var: height min: 0 max: 30 category: "Model";
	
	output
	{
		
		
		display map
		{
			grid my_cell lines: #black;
    		species boat aspect:base;
    		species boat aspect:icon;
			species fish aspect:icon;
		}
		display Population_information {
			chart "Yeild" type: series size: {1,0.5} position: {0, 0} {
				data "Yeild" value: yeild_all color: #red;
			}	
		chart "Yeild" type: series size: {1,0.5} position: {0, 0.5} {
				data "Number of fish" value: nb_fish color: #blue;
			}	
		}
		
	}
	
}

