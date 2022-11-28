
model Combined1

global
{
	my_cell selected_cells;
	
	int fish_number <- 10;
	float fish_reproduce_rate <- 0.2;				// r
	float fish_local_density_radius <- 1.0; 
	float fish_local_cap <- 100.0;						// local K
	float fish_speed <- 1.0;
	
	int boat_number <- 5;
	float boat_speed <- 5.0;
	float boat_catch_prob <- 0.5;
	float boat_fishing_radius <- 10.0;
	float yeild_all <- 0.0;

	int height <- 16;
	int width <- 16;
	float nb_fish <- 0.0;
	
	init
	{
		
		selected_cells <- location as my_cell;
		ask selected_cells
		{
			fish_population <- fish_number;
		}
		create boat number: boat_number;

	

	}
	reflex reset_yeild
	{
		yeild_all <- 0.0;
		ask boat
		{
			yeild <- 0.0;
		}
		nb_fish <- 0.0;
	}
}

grid my_cell width: width height: height neighbors: 8
{
	float fish_population <- 0.0;
//	rgb color <- hsb(fish_population/200, 1.0, 1.0) update: hsb(fish_population,1.0,1.0);
	rgb color <- rgb(255 - fish_population/10 * 255, 255, 255) update: rgb(255 - fish_population/20 * 255, 255, 255);
	float fish_move_out;
    reflex diff 
    {
    	float local_fish <- 0;
    	loop cell over: neighbors
    	{
    		local_fish <- local_fish + cell.fish_population;
    	}
		float local_density <- local_fish;
		float reproduce_prob <- fish_reproduce_rate * max((1 - local_density/ fish_local_cap), 0);
		float fish_after <- fish_population * (1 + reproduce_prob);
		int nb <- length(neighbors);
		float fish_move_out <- fish_after * nb / (nb+1);
		fish_population <- fish_after - fish_move_out;
		nb_fish <- nb_fish + fish_population;
		loop cell over: neighbors
		{
			cell.fish_population <- cell.fish_population + fish_move_out/nb;
		}


    }
	
}

species boat skills: [moving]
{
  	init {
    	speed <- boat_speed;
   	}

	float yeild <- 0.0;
	image_file my_icon <- image_file("../includes/data/boat.png");
	reflex catch_fish
	{
		yeild <- 0.0;
		list<my_cell> cell_in_area <- my_cell at_distance boat_fishing_radius;
		int cell_num <- length(cell_in_area);
		yeild <- cell_num * boat_catch_prob;
		yeild_all <- yeild_all + yeild;
		loop cell over: cell_in_area
		{
			ask cell
			{
				cell.fish_population <- cell.fish_population * (1 - boat_catch_prob);
				
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
		}
		display Population_information {
			chart "Yeild" type: series size: {1,0.5} position: {0, 0} {
				data "Yeild" value: yeild_all color: #red;
			}	
		chart "Number of fish" type: series size: {1,0.5} position: {0, 0.5} {
				data "Number of fish" value: nb_fish color: #blue;
			}	
		}
		
	}
	
}

